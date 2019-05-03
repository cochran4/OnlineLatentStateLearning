function [mu,V,lsb,agent,par] = RunTask(par,example,approach) %#ok<INUSL>
% Run Task
%   Input:
%           par      = structure of parameters
%           example  = name of example-specific function 
%           approach = name of learning model 
%   Output:
%           mu    = matrix of expected rewards per trial
%           V     = matrix of associative strength
%           lsb   = latent-state beliefs
%           agent = Last update of variables
%           par   = structure of parameters


% Initialize parameters
par   = eval([example,'(''Initialize'',par)']); 

% Initialize variables 
agent = eval([approach,'(par,[])']);

 % Save associative strength and latent state beliefs (if applicable)
V(1,:) = agent.V(:)';
if isfield(agent,'lsb')
    lsb(1,:) = agent.lsb;
else 
    lsb      = [];
end

% Loop through trials
for t = 1:par.ntrials

    % Adjust parameters
    par.t            = t;                          % Current time
    par.lastwin      = ~(t == 1 || agent.win==0);  % Outcome from last time point

    % Get rewards and cue vector
    world = eval([example,'(''Randomize'',par)']);     
        
    % Update variables
    agent  =  eval([approach,'(par,agent,world)']); 
    
    % Save associative strength and latent state beliefs (if applicable)
    V(t+1,:) = agent.V(:)';
    if isfield(agent,'lsb')
        lsb(t+1,1:length(agent.lsb)) = agent.lsb;
    else 
        lsb      = [];
    end
    if isfield(agent,'mu')
        mu(t,1:length(agent.mu)) = agent.mu;
    else
        mu = [];
    end

end

disp([])
