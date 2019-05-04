function agent = LatentState(par,agent,world)
% Latent-state learning approach
% Input:
%      par   = structure of parameters
%      agent = structure of variables tracked by agent
%      world = structure of variables generate from task/world
% Output:
%      agent  = updated structure of variables tracked by agent

%-------------------------------------------------------------------------
% Initialization of agent
if isempty(agent)   

    % Special case: all variables are already initialized
    if isfield(par,'initialV')
        agent = par.initialV;
    else
    
        % Initial expectations (neutral, unless otherwise specified)
        if isfield(par,'initialex')
            agent.V = par.initialex;
        else
            agent.V = zeros(par.D,par.C,par.ls.ncop);
        end

        % Each hypothesis is initially active
        agent.Lmax  = par.L; 

        % Change point statistic
        agent.q = 0;   

        % Initial log-beliefs (evenly divided among initial hypotheses)
        agent.lsb          = zeros(1,par.ls.ncop);
        if isfield(par,'lsb0')
            agent.lsb(1:par.L) = par.lsb0;
        else
            agent.lsb(1:par.L) = 1/par.L;
        end

        % Initial B matrix (identity) for cues per dimension & state 
        agent.B = zeros(par.C,par.C,par.D,par.ls.ncop);
        for d=1:par.D
            for l=1:par.ls.ncop
                agent.B(:,:,d,l) = eye(par.C);
            end
        end

        % Initial variance matrix of expected mean
        agent.sigmasq = par.ls.sigma0^2;
      
    end
%-------------------------------------------------------------------------
% Update of agent    
else
    %--------------------------------
    % Get variables
    %--------------------------------
    V         = agent.V;              % Associative strength
    lsb       = agent.lsb;            % Latent state beliefs
    B         = agent.B;              % Effort matrix
    Lmax      = agent.Lmax;           % No. of copies of latent states
    q         = agent.q;              % Change point statistic
    sigmasq0  = agent.sigmasq;        % Variance    
    win       = world.win-par.center; % Outcome
    c_vec     = world.c_vec;          % Cue vector     
    %--------------------------------
    % Context or temporal shift
    %-----------------------------------    
    
    lsb = ContextShift(lsb,Lmax,par);
    
    %-----------------------------------    
    % Choice behavior
    %-----------------------------------    
    
    % Value function per arm, latent state
    mu  =  reshape(sum(V.*c_vec,2), par.D,par.ls.ncop,par.A); 
    
    % Value function per arm
    mu0 = reshape(sum(mu.*lsb,2),par.D,par.A);
    
    % Choose arm and update relevant variables based on arm
    if ~isfield(world,'arm')
        arm   = SoftMaxChoice(mu0,par);
    else
        arm   = world.arm;
    end
    win   = win(:,arm);
    mu    = mu(:,:,arm);
    c_vec = c_vec(:,:,:,arm);

    
    %-----------------------------------    
    % Updates
    %-----------------------------------    

    % Update likelihood
    LL = LogLikelihood(win,mu,sigmasq0,Lmax,par.ls.ncop);

    % Approximate bayesian filter of latent-state beliefs 
    lsb = LatentStateBeliefs(lsb,Lmax,LL,par);
    
    % Add new state
    [V,lsb,Lmax,q] = NewState(V,lsb,Lmax,c_vec,win,LL,q,par);
    
    % Update other variables
    [V,B,sigmasq] = Update(V,B,sigmasq0,lsb,Lmax,c_vec,win,par);
    
    %--------------------------------
    
    % Output updated variables
    agent.V       = V;
    agent.lsb     = lsb;
    agent.B       = B;
    agent.sigmasq = sigmasq;
    agent.Lmax    = Lmax;
    agent.q       = q;
    agent.arm     = arm;
    agent.win     = win;
    agent.mu      = mu0;
end

%--------------------------------------------------------------------------
function lsb = ContextShift(lsb,Lmax,par)

% Temporal shift
if par.t~=1 && isfield(par,'time')
    prob_stay   = (1-par.ls.gamma).^(par.time(par.t)-par.time(par.t-1)-1);
    lsb(1:Lmax) = lsb(1:Lmax)*prob_stay + (1-prob_stay)/Lmax;
end

% Shift based to old context re-initialize beliefs
if isfield(par,'context') && any( par.context(:) == par.t )
    lsb(1:Lmax) = 1;
    lsb         = lsb/sum(lsb);
end

%--------------------------------------------------------------------------
function LL = LogLikelihood(win,mu,sigmasq,Lmax,ncop)
% Log-likelihood of each latent state

% Initialize
LL             =  zeros(1,ncop);
LL(Lmax+2:end) = -Inf;

% Index of activated states
ix = 1:Lmax;

% Log-likelihood (up to a constant)
LL(:,ix) = sum( -( win - mu(:,ix) ).^2 / (2*sigmasq), 1 );
       
%--------------------------------------------------------------------------
function lsb = LatentStateBeliefs(lsb,Lmax,LL,par)
% Update latent state beliefs

% LR hypothesis test for new states
ix1 = 1:Lmax;

% Current (scaled) likelihood
tmp      = zeros(1,par.ls.ncop);
tmp(ix1) = ((1-par.ls.gamma)*lsb(ix1)+par.ls.gamma/Lmax).*exp(LL(ix1)-max(LL(ix1)));

% Normalize
lsb  = tmp/sum(tmp);

function [V,lsb,Lmax,q] = NewState(V,lsb,Lmax,c_vec,win,LL,q,par)
% Check if new state should be added

% Check if there is room to add more states
if Lmax < par.ls.ncop    

    % Initialize
    tmp      = zeros(1,par.ls.ncop);

    % Consider what would happen next
    ix1      = (1:Lmax);
    ix2      = Lmax+1;
    mx       = max(exp(LL([ix1,ix2])));
    tmp(ix1) = ((1-par.ls.gamma)*lsb(ix1)+par.ls.gamma/Lmax).*exp(LL(ix1)-mx);

    % Current (scaled) likelihood
    l0    = sum( tmp );
    
    % (Scaled) likelihood if adding new states
    l1 = exp( LL(ix2(1))-mx );
    
    % Update change point statistic
    q = max( q + log(l1) - log(l0) - par.ls.delta, 0 );    

    % Check if new state is activated
    if q >= par.ls.eta

        % Update number of copies of latent states
        Lmax  = Lmax + 1;

        % Reset change point statistic
        q = 0;
        
        % Update beliefs
        tmp([ix1,ix2]) = ((1-par.ls.gamma)*lsb([ix1,ix2])+par.ls.gamma/Lmax).*exp(LL([ix1,ix2]));
        
        % Add in new associative strength        
        Vnew        = c_vec(:,:,Lmax).*win(:)./sum(c_vec(:,:,Lmax).^2,2);
        V(:,:,Lmax) = Vnew;

        % Normalize
        lsb  = tmp/sum(tmp);

    end
end


function [V,B,sigmasq] = Update(V,B,sigmasq,lsb,Lmax,c_vec,win,par)
% Update variables V and cov

% Number of iterations
if par.t == par.ntrials || ~isfield(par,'time')
    nIter = 1;
else
    nIter = min(par.ls.chi,round(par.time(par.t+1)-par.time(par.t)));
end          

% Save current value
sigmasq0 = sigmasq;
  
% Get expectations
mu  = reshape(sum(V.*c_vec,2),par.D,par.ls.ncop); 

% Loop through reward dimensions
for d=1:par.D
    
    % Loop through active latent states
    for l=1:Lmax
        
        % Weighted covariance
        B(:,:,d,l)  = B(:,:,d,l) + ... 
                       par.ls.alpha2*(lsb(l)*c_vec(d,:,l)'*c_vec(d,:,l)-B(:,:,d,l)); 

        % Associability
        tmp = par.ls.alpha0*lsb(l)*((B(:,:,d,l)+10^(-12)*eye(par.C))\c_vec(d,:,l)')';

        % Temporal difference
        TD         = ( win(d) - mu(d,l) );

        % Associative strength update
        V(d,:,l) = V(d,:,l)  + tmp*TD;

        % Part of variance update
        sigmasq = sigmasq + par.ls.alpha1*lsb(l)*TD^2;

        % Rumination steps
        for n=1:nIter-1

            % Expectations
            mu  = reshape(sum(V.*c_vec,2),par.D,par.ls.ncop); 

            % Temporal difference
            TD         = ( win(d) - mu(d,l) );

            % Associative strength update
            V(d,:,l) = V(d,:,l)  + tmp*TD;                
        end
    end
end
    
% Finish variance update
sigmasq = sigmasq - par.ls.alpha1*sigmasq0;
    
