function [logL,MU,agent,logL0,lsb] = EstimateLogLike(par,dta,approach) %#ok<INUSL>
% Estimate log-likelihood
%   Input:
%           par      = structure of parameters
%           dta      = structure containing experimental data
%           approach = name of learning model 
%   Output:
%           logL     = log-likelihood of participant behavior given
%           parameters

% Initialize variables 
agent  = eval([approach,'(par,[])']);
logL   = 0;

% Loop through trials
for t = 1:par.ntrials

    % Get rewards and feature vector
    par.t        = t;           % Add in current time
    world.c_vec  = reshape( dta.c_vec(t,:),par.D,par.C,par.ls.ncop,par.A );
    world.win    = reshape( repmat(dta.R(t,:),1,par.A), par.D, par.A );        
    world.arm    = dta.arm(t);
    
    % Update agent
    agent        = eval([approach,'(par,agent,world)']);
    
    % Get probability of arm choice
    [~,p]        = SoftMaxChoice(agent.mu,par);
    
    
    % Log-probability of picked arm
    logL       = logL + log( p( world.arm ) );
    logL0(t,1) = p( world.arm );
    
    % Save expectations
    MU(t,:) = agent.mu(:)';
    
    % Save beliefs
    if isfield(agent,'lsb')
        lsb(t,:) = agent.lsb(:)';
    end

end

disp([])
