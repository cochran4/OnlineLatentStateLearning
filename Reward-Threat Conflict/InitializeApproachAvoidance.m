function [par,dta,pts,pts0,lb,ub] = InitializeApproachAvoidance(result,Approach)
% Setup parameters to run estimation for approach-avoidance task
%--------------------------------------------------------------------------


% Initialize patient parameters
%--------------------------------------------------------------------------
par = PatientParameters;

% Add in example-specific parameters
%--------------------------------------------------------------------------
par.ntrials  = 150;            % Number of trials
par.A        = 3;              % Number of arms
par.D        = 1;              % Dimension of outcomes 
par.C        = 3;              % Number of cues
par.L        = 1;              % Initial number of latent states
par.center   = 0;              % Reward centering value
par.sigma0   = 1/2;            % Initial standard deviation
pts          = 150;            % Number of start points

% Build (trivial) cue vector for example
%--------------------------------------------------------------------------
dta.c_vec = zeros(par.D,par.C,par.ls.ncop,par.A);
for d=1:par.D
    for c=1:par.C
        for l=1:par.ls.ncop
            for a = 1:par.A
                dta.c_vec(d,c,l,a) = (a==c);  % Encode which arm is pulled
            end
        end
    end
end
dta.c_vec = repmat( dta.c_vec(:)', par.ntrials, 1 );

% Add in other parts of data structure
dta.R     = result.reward_outcomes;
dta.T     = result.threat_outcomes;
dta.arm   = result.choices;

% Initialize parameters needed for estimating parameters
%--------------------------------------------------------------------------
% Initialize initial points and upper/lower bounds for parameters per model
if strcmp(Approach,'RescorlaWagner')
    pts0          = [1  1  0.1]';
    lb            = [0  0    0]';
    ub            = [40 40   1]';  
elseif strcmp(Approach,'Hybrid')
    pts0          = [1  1  0.1 0.8]';
    lb            = [0  0    0   0]';
    ub            = [40 40   1   1]';       
elseif strcmp(Approach,'fRLDecay')
    pts0          = [1  1  0.14 0.45]';
    lb            = [0  0    0   0]';
    ub            = [40 40   1   1]';   
elseif strcmp(Approach,'Gershman2017')    
    pts0 = [ 1  1    0.1    0.3   0.4];
    lb   = [ 0  0    0      0     0.0]';
    ub   = [40  40   100    1     1]';
else  % Latent-state learning
    
    % Adjust cue vector for latent-state learning model
    par.L    = 3; 
    par.D    = 1;

    % Build (trivial) cue vector for example
    %--------------------------------------------------------------------------
    dta.c_vec = zeros(par.D,par.C,par.ls.ncop,par.A);
    for d=1:par.D
        for c=1:par.C
            for l=1:par.ls.ncop
                for a = 1:par.A
                    dta.c_vec(d,c,l,a) = (a==c);  % Encode which arm is pulled
                end
            end
        end
    end
    dta.c_vec = repmat( dta.c_vec(:)', par.ntrials, 1 );

    % Initialize lower and upper bound for parameters
    pts0 = [ 1  1  0.1   0.1  0.5 0.01];
    lb   = [ 0  0  0.02  0.02 0.1 0]';
    ub   = [40  40 1     1    0.9 1]';
    
end

