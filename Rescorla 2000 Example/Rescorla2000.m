function out = Rescorla2000(step,par)
% Functions needed to run rescorla-wagner (2000) experiments
% Input: 
%        step    = task step ('Initialize','Randomize','Pull Arm')
%        par     = structure containing parameters
% Output:
%        out     = output depending on task step

switch step
    
    % Initialize parameters for context task
    case 'Initialize'

        % Random seed
        rng(1)
        
         % Other parameters
        p1             = 100;
        par.A          = 1;           % Number of arms
        par.D          = 1;           % Dimension of outcomes
        par.C          = 10;          % Dimension of context
        par.nphases    = p1+10;       % Number of task phases (blocks)
        par.ntrials    = p1*5+8+4;    % Number of trials
        par.L          = 1;           % Initial number of latent states
        par.center     = 1/2;         % Reward centering (neutral expectations)
        
        % Initialize trial order
        par.trialorder = [];
        for p=1:par.nphases
            % Initial conditioning
           if p<=p1
               % Random order of cue presentation
               ix = randperm(5)';
           % Compound conditioning
           elseif p>p1 && p<=p1+8
               % AB+ (Experiment 1) or AB-(Experiment 2)
               ix = 5 + par.case;
           % Test
           else
               % Random order of test compound (AD- or BC-)
               ix = randperm(2)' + 7;
           end
           
           % Append to trial order
           par.trialorder = [par.trialorder; ix];

        end

        %  Rewards + cues encoded in a vector
        par.outcomes = [  1,1,0,0,0,0,0,0,0,0,0; ...   % A+
                          1,0,0,1,0,0,0,0,0,0,0; ...   % C+
                          1,0,0,0,0,1,0,0,0,0,0; ...   % X+
                          0,0,1,0,0,1,1,0,0,0,0; ...   % BX-
                          0,0,0,0,1,1,0,1,0,0,0; ...   % DX-
                          1,1,1,0,0,0,0,0,1,0,0; ...   % AB+
                          0,1,1,0,0,0,0,0,1,0,0; ...   % AB-
                          0,1,0,0,1,0,0,0,0,1,0; ...   % AD-
                          0,0,1,1,0,0,0,0,0,0,1];      % BC-
        
        % Remove encoding of compound cues if not latent-state learning
        if ~contains(par.modelname,'LatentState')
            par.outcomes(:,7:end) = [];
            par.C                 = 5;
        end

        % Output parameters
        out = par;
        
    % Generate rewards and arm pull -> expectation mapping
    case 'Randomize'
        
        % Current trial reward                         
        R    = par.outcomes(par.trialorder(par.t),1);

        % Identical feature vector per latent state
        c_vec = zeros(par.D,par.C,par.L*par.ls.ncop);
        for l=1:par.L*par.ls.ncop
            c_vec(1,:,l)  = par.outcomes(par.trialorder(par.t),2:end);
        end
        
        % Output data
        out.win   = double(R);
        out.c_vec = c_vec;
        
        
end