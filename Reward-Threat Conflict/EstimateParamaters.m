function param = EstimateParamaters(p,dta,par,pts,pts0,lb,ub,Approach)
% Estimate parameters for a single patient
%--------------------------------------------------------------------

% Finish building data matrix for specific patient
dta.R     = [ dta.R(p,:)'/20, ...
              1-dta.T(p,:)'-1/2]; % Center threat
dta.arm   =   dta.arm(p,:)';


% Optimize parameters using multistart
%--------------------------------------------------------------------
ms      = MultiStart;
problem = createOptimProblem('fmincon','x0',pts0,...
    'objective',@(param) Fun2EstimateLogLike(param,par,dta,Approach),'lb',lb,'ub',ub);
[xmin0,fmin0,~,~,~] = run(ms,problem,pts);

% Transform exploration-exploitation parameters
%--------------------------------------------------------------------
xmin0([1,2])     = [ xmin0(1)+xmin0(2), xmin0(2)/(xmin0(1)+xmin0(2) ) ];
xmin0            = xmin0([1,3:end,2]); % Re-order
%--------------------------------------------------------------------

% Store parameters and performance
%--------------------------------------------------------------------
param =  [ xmin0(:)', exp(-fmin0/150)];