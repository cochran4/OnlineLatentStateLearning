function out = PREE(step,par)
% Functions needed to run PREE
% Input: 
%        step    = task step ('Initialize','Randomize')
%        par     = structure containing parameters
% Output:
%        out     = output depending on task step

switch step
    
    % Initialize parameters for context task
    case 'Initialize'
        
        % Other parameters
        par.A          = 1;           % Number of arms
        par.D          = 1;           % Dimension of outcomes
        par.C          = 1;           % Dimension of cues
        par.L          = 1;           % Initial number of latent states
        par.center     = 1/2;         % Reward centering value
        par.ntrials    = 30;          % Number of trials
                
        %  Rewards + cues encoded in a vector
        par.outcomes = [  1,1; ...   % A+
                          0,1 ];     % A  
        
        % Trial order
        if      par.case(1)==1  % PREE -> No reward
            par.trialorder = [ repmat([1,2],1,10), ...
                               2*ones(1,10) ];
        elseif par.case(1)==2   % Continous reinforcement -> No reward
            par.trialorder = [ repmat([1,1],1,10), ...
                               2*ones(1,10) ];
        elseif par.case(1)==3 % PREE -> reward -> No reward
            par.ntrials    = 50;
            par.trialorder = [ repmat([1,2],1,10), ...
                               1*ones(1,20),...
                               2*ones(1,10)];  
        elseif par.case(1)==4 % Cont.reward -> reward -> No reward
            par.ntrials    = 50;
            par.trialorder = [ repmat([1,1],1,10), ...
                               1*ones(1,20),...
                               2*ones(1,10)];                     
        end
        % Output parameters
        out = par;
        
    % Generate rewards and arm pull -> expectation mapping
    case 'Randomize'
        
        % Current trial reward                         
        R    = par.outcomes(par.trialorder(par.t),1);

        % Identical feature vector per latent state
        f = zeros(par.D,par.C,par.L*par.ls.ncop);
        for l=1:par.L*par.ls.ncop
            f(1,:,l)  = par.outcomes(par.trialorder(par.t),2:end);
        end
        
        % Output data
        out.win   = double(R);
        out.c_vec = f;
            
end