function agent = fRLDecay(par,agent,world)
% fRL+delay approach from Niv et al.
% Input:
%      par   = structure of parameters
%      agent = structure of variables tracked by agent
%      world = structure of variables generate from task/world
% Output:
%      agent  = updated structure of variables tracked by agent

%-------------------------------------------------------------------------
% Initialization of agent
if isempty(agent) 
        
    % Initial associative strength
    if isfield(par,'initialex')
        agent.V = par.initialex;
    else
        agent.V = zeros(par.D,par.C);
    end
              
%-------------------------------------------------------------------------
% Update of agent    
else      
     
    % Get variables
    V     = agent.V;              % Associative strength
    win   = world.win;            % Outcome
    c_vec = world.c_vec;          % Cue vector
    
    % Mean per outcome and arm
    mu = reshape( sum( V.*c_vec(:,:,1,:), 2 ), par.D, par.A); 

    % Choose arm
    arm = SoftMaxChoice(mu,par);
    
    % Get relevant entries based on arm
    win   = win(:,arm);
    mu    = mu(:,arm);
    c_vec = c_vec(:,:,1,arm); 
        
    %--------------------------------------
    % Update pulled arms

    % Loop through outcomes
    for d=1:par.D
        % Learning rate
        tmp = par.fRLDecay.eta*c_vec(d,:);

        % Temporal difference
        TD  = ( win(d,1) - mu(d) );

        % Update
        V(d,:)  = V(d,:)  + tmp*TD;
        ix      = c_vec(d,:) == 0;
        V(d,ix) = (1-par.fRLDecay.d)*V(d,ix); 
    end

    % Output updated variables
    agent.V       = V;
    agent.arm     = arm;
    agent.win     = win;
    agent.mu      = mu(:)';
end
       