function out = WilsonBoumphreyPearce(step,par)
% Functions needed to run example from Wilson, Boumphrey, Pearce
% Input: 
%        step    = task step ('Initialize','Randomize')
%        par     = structure containing parameters
%        mu      = expectations per arm
% Output:
%        out     = output depending on task step

switch step
    
    % Initialize parameters for context task
    case 'Initialize'
        
         % Other parameters
        par.A          = 1;     % Number of arms
        par.D          = 1;     % Dimension of outcomes
        par.C          = 2;     % Dimension of context
        par.nphases    = 9;     % Number of task phases (blocks)
        par.ntrials    = 60;    % Number of trials
        par.L          = 1;     % Initial number of latent states
        par.center     = 1/2;   % Reward centering
        
        % Four outcomes (US,light,tone,lightxtone): 
        %        1=(1,1,1,1) or 2=(0,1,1,1) or 3=(0,1,0,0) or 4=(1,1,0,0) 
        par.outcomes = [1,1,1,1; 0,1,1,1; 0,1,0,0; 1,1,0,0];
        switch par.case
            case 'E'
                par.trialorder = [repmat([1,2],1,5),repmat([1,3],1,20),repmat(4,1,10)];
            case 'C'
                par.trialorder = [repmat([1,2],1,25),repmat(4,1,10)];
        end
        
        % Remove interactions for other models
       if ~contains(par.modelname,'LatentState')
            par.outcomes(:,4:end) = [];
       else
            par.C = 3;
       end
        
        % Output parameters
        out = par;
        
    % Generate rewards and arm pull -> expectation mapping
    case 'Randomize'
        
        % Generate reward (food) per arm (US,light,tone) ... (stim,CS-,CS+)
        R    = par.outcomes(par.trialorder(par.t),1);

        % Constant feature vector
        f = zeros(par.D,par.C,par.L*par.ls.ncop);
        for l=1:par.L*par.ls.ncop
            f(1,:,l)  = par.outcomes(par.trialorder(par.t),2:end);
        end        
        
        % Output data
        out.win   = double(R);
        out.c_vec = f;
        
end