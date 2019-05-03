function agent = Gershman2017(par,agent,world)
% Latent cause modulated Rescorla-Wagner model of Gershman et al (2017)
% Input:
%      par   = structure of parameters
%      agent = structure of variables tracked by agent
%      world = structure of variables generate from task/world
% Output:
%      agent  = updated structure of variables tracked by agent
% WARNING: inter-trial intervals are assumed constant except memory example

% Warning about multidimensional rewards
if par.D~=1
    disp('Warning: model is not defined for multidimensional rewards') 
end

% Parameters
T     = par.ntrials; % Number of trials

%-------------------------------------------------------------------------
% Initialization of agent
if isempty(agent)   
    
    % Initialize variables
    agent.Z    = zeros(T,par.gershman.K);
    agent.lsb  = [1,zeros(1,par.gershman.K-1)]; 

    % Initialize associative strength
    agent.V = zeros(1,par.C,par.gershman.K) + par.gershman.w0;

    % Cue matrix
    agent.X = [];
    
%-------------------------------------------------------------------------
% Update of agent    
else
    
    % Get variables
    Z     = agent.Z;
    X     = agent.X;
    t     = par.t;                          % Current trial
    W     = reshape( agent.V, par.C, [] );  % Associative strength      
    post  = agent.lsb;                      % Latent state beliefs
    win   = world.win;                      % Possible outcomes
    c_vec = world.c_vec;                    % Cue vector
        
    % Expectations per arm
    mu = post*W'*reshape( c_vec(1,:,1,:) , par.C, par.A );
                
    % Choose arm
    arm = SoftMaxChoice(mu,par);
    
    % Get relevant entries based on arm
    win   = win(:,arm);
    c_vec = squeeze( c_vec(:,:,1,arm) ); 
    mu    = mu(arm);
    
    % Add in latest cue vector 
    X = [X; c_vec(:)'];
        
    % Inter-arrival time
    if isfield(par,'time')
        ITI   = par.time(t) - par.time(1:t-1);
    else
        ITI   = (t-1:-1:1); 
    end    
    
    % Determine number of EM iterations
    if par.t == par.ntrials || ~isfield(par,'time')
        nIter = 1;
    else
        nIter = min(par.gershman.EMSteps,round(par.time(par.t+1)-par.time(par.t)));
    end          
    
    % (Unnormalized) posterior, excluding reward
    N                   = sum(Z(1:t-1,:),1);                     % cluster counts
    prior               = ITI.^(-par.gershman.g)*Z(1:t-1,:);     % ddCRP prior
    prior(find(N==0,1)) = par.gershman.alpha;                    % probability of new cluster
    L                   = prior./sum(prior);                     % normalize prior
    lsb                 = L;                                     % Store prior
    xsum                = X(1:t-1,:)'*Z(1:t-1,:);                % [C x K] matrix of feature sums
    nu                  = par.gershman.sx./(N+par.gershman.sx) + par.gershman.sx;

    % Loop through cues
    for c = 1:par.C
        xhat = xsum(c,:)./(N+par.gershman.sx);
        L    = L.*normpdf(X(t,c),xhat,sqrt(nu)); % likelihood
    end

    % reward prediction, before feedback
    post = L./sum(L);

    % loop over EM iterations
    for iter = 1:nIter
        V = X(t,:)*W;                                     % Predicted reward
        post = L.*normpdf(win,V,sqrt(par.gershman.sr));   % Unnormalized posterior with reward
        post = post./sum(post);                           % Normalized posterior
        rpe  = repmat((win-V).*post,par.C,1);             % Reward prediction error
        x    = repmat(X(t,:)',1,par.gershman.K);
        W    = W + par.gershman.eta.*x.*rpe;              % Weight update            
    end

    % cluster assignment
    [~,k] = max(post);                  % maximum a posteriori cluster assignment
    Z(t,k) = 1;

    % Save variables
    agent.Z    = Z;
    agent.X    = X;
    agent.V    = reshape( W, 1, par.C, [] );
    agent.lsb  = post; % Probability at end of trial
    agent.arm  = arm;
    agent.win  = win;
    agent.mu   = mu;
 
end
       