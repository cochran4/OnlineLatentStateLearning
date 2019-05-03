function RunSensitivity
% Sensitivity of target effect to +/- 5% changes in parameters

% List of experiments
expName = {'Blocking','Blocking','Blocking','Blocking',...
           'Rescorla2000','Rescorla2000','WilsonBoumphreyPearce',...
           'PREE','PREE','Renewal','Renewal','SpontaneousRecovery',...
           'MonfilsSchiller'};
       
% List of conditions/cases per experiment
cases   = {{'Blocking'},{'Overexpectation'},{'Conditioned Inhibition'},...
           {'Backwards Blocking'},{1},{2},{'C','E'},{1,2},{3,4},{1},{1,2},...
           {1,2},{1,5}};
       
% Loop through experiments + conditions/cases
for i=1:length(expName)
    % Run sensitivity analysis for given experiment and case
    Sens(i,:) = SensitivityAnalysis(expName{i},cases{i});
end

xlswrite('Sens',Sens)