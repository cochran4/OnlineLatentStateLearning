function [out,out2] = MonfilsSchiller(step,par)
% Functions needed to run Monfils-Schiller example
% Input: 
%        step    = task step ('Initialize','Randomize')
%        par     = structure containing parameters
%        mu      = expectations per arm
% Output:
%        out     = output depending on task step
%        out2    = second output depending on task step

switch step
    
    % Initialize parameters
    case 'Initialize'
        
         % Other parameters
        par.A               = 1;        % Number of arms
        par.D               = 1;        % Dimension of outcomes
        par.C               = 1;        % Dimension of context
        par.L               = 1;        % Initial number of latent states
        par.center          = 1/2;      % Intial  reward centering
        par.ruminate        = 3;        % Number of rumination updates
                
        % Time indices
        N = [3 1 19 2];
        I = [0 20 par.case(1) 200];
        t = 1;
        Time = [];
        for i = 1:length(N)
            t = t + I(i);
            for j = 1:N(i)
                Time = [Time, t];
                t = t + 1;
            end
        end

        par.ntrials    = sum(N)-1;    % Number of trials
        par.time       = Time;        % Time values

        % Output parameters
        out = par;
        
    % Generate rewards and arm pull -> expectation mapping
    case 'Randomize'
        
        % Current phase
        if par.t <= 3
            R = 1;
        else 
            R = 0;
        end
        
        % Feature vector
        c_vec = ones(par.D,par.C,par.L*par.ls.ncop,par.A);
                
        % Output data
        out.win   = double(R);
        out.c_vec = c_vec;
        
end