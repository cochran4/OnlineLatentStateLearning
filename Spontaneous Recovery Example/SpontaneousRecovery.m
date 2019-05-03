function out = SpontaneousRecovery(step,par)
% Functions needed to run renewal example 
% Input: 
%        step    = task step ('Initialize','Randomize')
%        par     = structure containing parameters
%        mu      = expectations per arm
% Output:
%        out     = output depending on task step

switch step
    
    % Initialize parameters
    case 'Initialize'
        
        % Other parameters
        par.A          = 1;                   % Number of arms
        par.D          = 1;                   % Dimension of outcomes
        par.C          = 1;                   % Dimension of cues
        par.ntrials    = 50;                  % Number of trials
        par.L          = 1;                   % Initial number of latent states
        par.center     = 1/2;                 % Intial  reward centering
        par.r0         = 1;                   % Reward value
      
        % Phase shift
        shft = [20,40];      
        
        % Loop through trials
        for i=1:par.ntrials
            % Acquisition
            if i<= shft(1)   
                par.trialorder(i,1) = 1;
            % Extinction
            elseif i > shft(1) && i <= shft(2) 
                par.trialorder(i,1) = 2;
            % Renewal
            elseif i > shft(2)
                par.trialorder(i,1) = 1;
            end
        end
        
        %  Rewards + cues encoded in a vector
        par.outcomes = [  1,1; ...      % Cue +
                          0,1 ];        % Cue
        
        % Add in irregular time between trial (delay between extinction and renewal)
        par.time                = (1:par.ntrials+1);
        par.time(shft(2)+1:end) = par.time(shft(2)+1:end) + par.case(1)-1;
                      
        % Output parameters
        out = par;
                      
    % Generate rewards
    case 'Randomize'
        
        % Current trial reward
        R    = par.outcomes(par.trialorder(par.t),1);
       
        % Identical cue vector per latent state
        c_vec = zeros(par.D,par.C,par.L*par.ls.ncop,par.A);
        for l=1:par.L*par.ls.ncop
            c_vec(1,:,l,1) = par.outcomes(par.trialorder(par.t),2:end);
        end
        
        % Output data
        out.win   = double(R);
        out.c_vec = c_vec;
               
                
end