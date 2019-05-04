function CollectParameters

% List of models
mdl_lst = {'LatentState_FixedEffort_d','LatentState_FixedEffort_e','LatentState_FixedEffort_f'};
   
% Description of models
modeldescription = {'Latent-state (vary gamma)','Latent-state (vary sigma)','Latent-state (vary sigma + gamma)'};   
mdl_lst = mdl_lst(end-2:end);
modeldescription = modeldescription(end-2:end);
                
%--------------------------------------------------------------------------
% Loop through models
for i=1:length(mdl_lst)
    
        
    % Load data
    load(['Analysis_',mdl_lst{i}])
    
    
    
    % Get parameter labels
    clear lbl
    lbl{1} = 'SoftMax';
    if strcmp(Approach,'RescorlaWagner') 
        if strcmp(Case,'a')
            lbl{2} = 'LearningRateReward';
            lbl{3} = 'LearningRateThreat';
        elseif strcmp(Case,'b')
            lbl{2} = 'LearningRatePos';
            lbl{3} = 'LearningRateNeg';
        elseif strcmp(Case,'c')
            lbl{2} = 'LearningRateRewardPos';
            lbl{3} = 'LearningRateRewardNeg';
            lbl{4} = 'LearningRateThreatPos';
            lbl{5} = 'LearningRateThreatNeg';
        else
           lbl{2} = 'LearningRate';
        end
    else
        lbl{2}  = 'LearningRate';
        if strcmp(Case,'d')
            lbl{3}  = 'TransitionRate';
        elseif strcmp(Case,'e')
            lbl{3}  = 'InitialSD';
        elseif strcmp(Case,'f')
            lbl{3}  = 'TransitionRate';
            lbl{4}  = 'InitialSD';
        end
    end
    lbl{end+1}  = 'ThreatWeighting';
    lbl{end+1}  = 'MeanLikelihood';

    
    % Collect parameters into table
    PAR(i).ModelDescription = modeldescription{i};
    
    % Add in participant ID
    PAR2.sub = result.sub(:);
    PAR(i).sub = result.sub;

    
    % Loop through parameters
    for j=1:length(lbl)
        eval(['PAR(i).',lbl{j},' = param(:,j);']);
        eval(['PAR2.',lbl{j},'_Model',num2str(i),'=param(:,j);'])
    end
    

   
end

save('AAT_ModelParameters','PAR')

% Save parameters as excel form
writetable(struct2table(PAR2),'AAT_ModelParameters_NewModels.xlsx')
