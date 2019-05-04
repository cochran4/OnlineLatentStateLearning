function RunEstimation(Approach)
% Estimate parmeters for a given learning model 'Approach'

% Load data and transform
load('AAT_data')

% Set-up task
[par,dta,pts,pts0,lb,ub] = InitializeApproachAvoidance(result,Approach);

% Loop through patients and estimate parameters
parfor p=1:length(result.sub)    
    param(p,:) = EstimateParamaters(p,dta,par,pts,pts0,lb,ub,Approach);
end

% Save results
save(['Results_',Approach])



