function out = Blocking(step,par)
% Functions needed to run blocking and other examples
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
        par.C          = 4;           % Dimension of context
        par.L          = 1;           % Initial number of latent states
        par.center     = 1/2;         % Reward centering value
                
        % Switch through various examples
        switch par.case
        
            % Blocking example
            case 'Blocking'
                
                par.nphases    = 28;          % Number of task phases (blocks)
                par.ntrials    = 36;          % Number of trials
                
                % Initialize trial order
                par.trialorder = [];
                for p=1:par.nphases
                    % Initial conditioning
                   if p<=20
                       % A+ conditioning
                       ix = 1;
                   % Compound conditioning
                   else
                       % Intermixed AB+ and CD+
                       ix = [3,4]';
                   end

                   % Append to trial order
                   par.trialorder = [par.trialorder; ix];

                end
                
                % Save trial order
                par.trialorders{1} = par.trialorder;
                
          case 'Backwards Blocking'
                
                par.nphases    = 28;          % Number of task phases (blocks)
                par.ntrials    = 28;          % Number of trials
                
                % Initialize trial order
                par.trialorder = [];
                for p=1:par.nphases
                   % Initial conditioning
                   if p<=20
                       % AB+ conditioning
                       ix = 3;
                   % Compound conditioning
                   else
                       % A+ conditioning
                       ix = 1; 
                   end

                   % Append to trial order
                   par.trialorder = [par.trialorder; ix];

                end
                
                % Save trial order
                par.trialorders{1} = par.trialorder;
                
                
            % Overexpecation
            case 'Overexpectation'
                
                
                par.nphases    = 60;           % Number of task phases (blocks)
                par.ntrials    = 110;          % Number of trials

                
                % Initialize trial order
                par.trialorder = [];
                for p=1:par.nphases
                    % Initial conditioning
                   if p<=50
                       % A+,B+ conditioning
                       ix = [1,2]';
                   % Compound conditioning
                   else
                       % AB+ compound
                       ix = 3;
                   end

                   % Append to trial order
                   par.trialorder = [par.trialorder; ix];

                end

                % Save trial order
                par.trialorders{2} = par.trialorder;

                
            % Conditioned inhibition
            case 'Conditioned Inhibition'
                
                
                par.nphases    = 100;          % Number of task phases (blocks)
                par.ntrials    = 200;          % Number of trials

                
                % Initialize trial order
                par.trialorder = [];
                for p=1:par.nphases
                   % A+,ABweak+ conditioning
                   ix = [1,5]';
                   
                   % Append to trial order
                   par.trialorder = [par.trialorder; ix];

                end

                % Save trial order
                par.trialorders{3} = par.trialorder;
                
        end

       % Rewards + cues with interactions
       par.outcomes = [   1,  1,0,0,0,0,0; ...   % A+
                          1,  0,1,0,0,0,0; ...   % B+
                          1,  1,1,0,0,1,0; ...   % AB+
                          1,  0,0,1,1,0,1; ...   % CD+
                          1/2,1,1,0,0,1,0];      % ABweak+
       
       % Remove interactions 
       if ~contains(par.modelname,'LatentState')
            par.outcomes(:,6:end) = [];
            par.C                 = 4;
       else
            par.C = 6;
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