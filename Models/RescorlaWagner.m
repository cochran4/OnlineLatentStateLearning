function agent = RescorlaWagner(par,agent,world)
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
        
    % Initial expectations (neutral, unless otherwise specified)
    if isfield(par,'initialex')
        agent.V = par.initialex;
    else
        agent.V = zeros(par.D,par.C);
    end
                
%-------------------------------------------------------------------------
% Update of agent    
else        
    
    % Get variables
    V         = agent.V;              % Associative strength
    win       = world.win;            % Outcome
    c_vec     = world.c_vec;          % Cue vector
    
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

        % Associability
        tmp = c_vec(d,:);

        % Temporal difference
        TD  = ( win(d,1) - mu(d,1) );

        % Adjust learning rate if applicable (can be specified to be 
        % dependent on reward dimension and sign of error)
        sgn     = (TD>=0)*1 + (TD<0)*2;
        [n1,n2] = size(par.rw.alpha); 
        alpha   = par.rw.alpha(min(d,n1),min(sgn,n2));

        % Expectation update
        V(d,:) = V(d,:)  + alpha*tmp*TD;

    end

    % Output updated variables
    agent.V       = V;
    agent.arm     = arm;
    agent.win     = win;
    agent.mu      = mu(:)';
end
       