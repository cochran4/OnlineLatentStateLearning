function Sens = SensitivityAnalysis(expName,cases)

% Sensitivity analysis ....
parList = {'alpha','alpha2','gamma','sigma0','eta','delta','chi'};

% Loop through list
for i=1:length(parList)
        
    for j=1:2
        
        % Get parameters
        par = PatientParameters;
                
        % Vary by +/- 10% 
        vary = ( (j-1)*20 - 10 )/100;
        
        if i==1
            par.ls.alpha0 = par.ls.alpha0*(1+vary);
            par.ls.alpha1 = par.ls.alpha1*(1+vary);
        elseif i==7
            par.ls.chi = par.ls.chi - 1 + 2*(j-1);
        else
            eval(['par.ls.',parList{i},'= par.ls.',parList{i},'*(1+vary);'])
        end
        
        % Run example
        RunExample(expName,{'LatentState'},1,cases,par)
        
        % Store data
        Sens(1,i+(j-1)*length(parList)) = TargetEstimate(expName);
        
    end
end



% Load data
function h = TargetEstimate(expName,cases)
% Get target estimate for a given experiment

% Load data
load(['Results_',expName])

switch expName
    
    case 'Rescorla2000'
        % Difference in change in associative strength from stage 1 to 2
        h1 = V{1,1}([501,509],1);  h1 = h1(2)-h1(1);
        h2 = V{1,1}([501,509],2);  h2 = h2(2)-h2(1);
        h  = h2 - h1; 
        
    case 'WilsonBoumphreyPearce'
        
        % Difference in associative strength of light at end
        h = V{1,2}(end,1,1) - V{1,1}(end,1,1);
        
    case 'Blocking'
        switch cases{1}
            case 'Blocking'
                % Difference in associative strength between ("blocked") cue B and cue C
                h = V{1,1}(end,2,1)-V{1,1}(end,3,1);
            case 'Overexpectation'
                % Change in associative strength of cue A from stage 1 to 2
                h = V{1,1}(end,1,1)-V{1,1}(end-10,1,1);                
            case 'Conditioned Inhibition'
                % Associative strength of cue B at end
                h = V{1,1}(end,2,1);                              
            case 'Backwards Blocking'
                % Change associative strength of cue B from stage 1 to 2
                h = V{1,1}(end,2,1) - V{1,1}(end-8,2,1);                              
        end
    case 'PREE'
        % Partial reinforcment leads to slower extinction
        h = V{1,1}(end,1,1)-V{1,2}(end,1,1); 
    case 'Renewal'
        
        % Renewal -> fast return of fear, especially with context changes
        if length(cases)==1
            h = MU{1,1}(end-8,1,1)-MU{1,1}(2,1,1);         
        else
            h = MU{1,2}(end-8,1,1)-MU{1,1}(end-8,1,1);                     
        end
        
    case 'SpontaneousRecovery'
        
        % Renewal -> fast return of fear, especially with context changes
        h = V{1,2}(end-9,1,1)-V{1,1}(end-9,1,1);       
        
    case 'MonfilsSchiller'
        
        % Retrival trial -> reduced fear response
        h = V{1,2}(end-1,1,1)-V{1,1}(end-1,1,1);       
        
end