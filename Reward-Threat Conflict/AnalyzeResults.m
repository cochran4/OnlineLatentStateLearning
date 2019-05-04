function AnalyzeResults(Approach)

% Load parameter results
load(['Results_',Approach])

% Load data and transform
load('AAT_data')

% Set-up task
[par,dta0] = InitializeApproachAvoidance(result,Approach);
dta.c_vec  = dta0.c_vec;

% Loop through patients
for p=1:length(result.sub)

    % Finish building data matrix for specific patient
    dta.R     = [ dta0.R(p,:)'/20, ...
                  1-dta0.T(p,:)'-1/2 ];
    dta.arm   =   dta0.arm(p,:)';

    %----------------------------------------------------------------------
    % Adjust parameters
    param0    = param(p,1:end-1);
    param0    = [param0(1)*[1-param0(end),param0(end)],param0(2:end-1)];
    [par,dta] = AdjustParameters(param0,par,Approach,dta);
    %----------------------------------------------------------------------
    
    % Run task with parameters
    [logL(p,1),MU(:,:,:,p),var,L0(:,p),lsb(:,:,p)] = EstimateLogLike(par,dta,Approach);
    
end

% Save results
save(['Analysis_',Approach])

