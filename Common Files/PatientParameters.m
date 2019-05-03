function par = PatientParameters
% Patient parameters that can be modified or fixed

% Soft max parameter (for all models)
par.tau              = 10;        % Exploration-exploitation parameter

% Latent-state learning
par.ls.alpha0        = 0.05;      % Learning rate for associative strength     
par.ls.alpha1        = 0.05;      % Learning rate for variance
par.ls.alpha2        = 0.05;      % Learning rate for covariance
par.ls.gamma         = 0.05;      % Transition probability between states
par.ls.ncop          = 10;        % Maximum number of replicates of latent states                                
par.ls.eta           = 0.2;       % Threshold to activate new state
par.ls.delta         = 0.6;       % Constant involved in change point statistic
par.ls.chi           = 5;         % Number of rumination updates
par.ls.sigma0        = 1/2;       % Initial standard deviation

% Additional parameters for Recorla-Wagner learning
par.rw.alpha          = 0.15;   % Learning rate

% Additional parameters for Hybrid model
par.hybrid=struct('kappa',0.3,'eta',0.857,'alpha',0.926);

% Additional parameters for fRL decay model
par.fRLDecay = struct('eta',0.15,'d',0.45);

% Additional parameters for infinite mixture model
par.imm = struct('alpha',1,'M',100,'K',15);   % Number of particles

% Additional parameters for memory modification model
par.gershman = struct('alpha',0.1,'g',1,'eta',0.3,...        
                  'w0',0,'sr',0.4,'sx',1,'K',15,'EMSteps',3);

