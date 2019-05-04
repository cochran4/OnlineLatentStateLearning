function  [par,dta] = AdjustParameters(param,par,Approach,dta)

% Exploration-exploitation
par.tau       = param(1)+param(2);
threatWeight  = param(2)/par.tau;
dta.R         = (1-threatWeight)*dta.R(:,1) + threatWeight*dta.R(:,2);

% Switch parameter setting depending on model
switch Approach
    case 'RescorlaWagner' 
    
        par.alpha = param(3);           % Learning rate
    
    case 'Hybrid'
    
        par.kappaHybrid   = param(3);   % Associative strength learning rate
        par.etaHybrid     = param(4);   % Associability learning rate
    
    case 'fRLDecay'
       
        par.etaFRLDecay   = param(3);   % Learning rate
        par.dFRLDecay     = param(4);   % Decay 
    
    case 'LatentState'
        
        par.ls.alpha0 = param(3);       % Learning rate
        par.ls.alpha1 = param(4);       % Learning rate
        par.ls.alpha2 = param(3);       % Learning rate
        par.ls.sigma0 = param(5);       % Initial standard deviation
        par.ls.gamma  = param(6);       % Transition
        
        % Fixed initial expectations to favor an arm
        par.initialex = reshape( [ [0.9 0.1 0.1 0.1 0.9 0.1 0.1 0.1 0.9 ]'-0.5;...
                                   zeros(par.C*(par.ls.ncop-par.L),1) ],par.D,par.C,par.ls.ncop); 
                               disp([])
    case 'Gershman2017'
        
        par.opts.alpha = param(3);      % Concentration parameter
        par.opts.eta   = param(4);      % Learning rate
        par.opts.sr    = param(5);      % Reward variance      
        
end
