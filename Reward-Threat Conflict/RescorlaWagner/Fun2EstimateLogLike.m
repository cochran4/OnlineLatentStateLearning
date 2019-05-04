function nll = Fun2EstimateLogLike(param,par,dta,Approach)
% Auxillary function to get in correct format

[par,dta] = AdjustParameters(param,par,Approach,dta);

% Negative loglikelihood
nll   = -EstimateLogLike(par,dta,Approach);


