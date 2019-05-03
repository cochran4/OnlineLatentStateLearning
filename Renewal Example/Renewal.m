function out = Renewal(step,par)
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
        par.C          = 3;                   % Dimension of cues
        par.nphases    = 3;                   % Number of task phases (blocks)
        par.ntrials    = 50;                  % Number of trials
        par.L          = 1;                   % Initial number of latent states
        par.center     = 1/2;                 % Intial  reward centering
        par.r0         = 1;                   % Reward value
        
       % Loop through trials
        for i=1:par.ntrials
            % Acquisition
            if i<= 20   
                par.trialorder(i,1) = 1;
            % Extinction
            elseif i > 20 && i <= 40 
                par.trialorder(i,1) = par.case(1)+1;
            % Renewal
            elseif i > 40
                par.trialorder(i,1) = 1;
            end
        end
        
        %  Rewards + cues encoded in a vector
        par.outcomes = [  1,1,0,1; ...      % Context A, Cue +
                          0,1,0,1; ...      % Context A, Cue
                          0,0,1,1];         % Context B, Cue
                          
        
        % Treat context as specific hypotheses in latent-state model
        if contains(par.modelname,'LatentState')
            % Adjust for context
            par.C          = 1;
            par.outcomes   = par.outcomes(:,[1,4]);
            
            % Context shift
            if par.case(1)==2
                par.context = [21,41]; 
            end
        end
                      
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