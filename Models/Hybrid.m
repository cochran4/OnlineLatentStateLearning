function agent = Hybrid(par,agent,world)
% Hybrid model from Li et al
% Input:
%      par   = structure of parameters
%      agent = structure of variables tracked by agent
%      world = structure of variables generate from task/world
% Output:
%      agent  = updated structure of variables tracked by agent

%-------------------------------------------------------------------------
% Initialization of agent
if isempty(agent)   
        
    % Initial associative strength (neutral, unless otherwise specified)
    if isfield(par,'initialex')
        agent.V = par.initialex;
    else
        agent.V = zeros(par.D,par.C);
    end

    % Initial associativity
    agent.alpha = par.hybrid.alpha*ones(par.D,par.C);
        
%-------------------------------------------------------------------------
% Update of agent    
else        
    
    % Get variables
    V     = agent.V;              % Associative strength
    alpha = agent.alpha;          % Associativity
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
        
    % Update
    for d=1:par.D

        % Temporal difference
        TD    = win(d,1) - mu(d,1);
        
        % Expectation update
        V(d,:) = V(d,:)  + ...
                 par.hybrid.kappa*alpha(d,:).*c_vec(d,:)*TD;

        % Associability update
        alpha(d,:) = alpha(d,:) + ...
                     par.hybrid.eta*c_vec(d,:,1).*(abs(TD)-alpha(d,:));

    end
                
    % Output updated variables
    agent.V       = V;
    agent.alpha   = alpha;
    agent.arm     = arm;
    agent.win     = win;
    agent.mu      = mu(:)';
end
       