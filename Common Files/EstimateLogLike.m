function [logL,MU,var,L0,L0All] = EstimateLogLike(par,dta,approach) %#ok<INUSL>
% Estimate log-likelihood
%   Input:
%           par      = structure of parameters
%           dta      = structure containing experimental data
%           approach = name of learning model 
%   Output:
%           logL     = likelihood of participant behavior by trial
%           MU       = Expected mean outcome by arm and reward dimensions
%           var      = structure of all variables
%           logL     = log-likelihood of participant behavior

% Initialize variables 
var      = eval([approach,'(''Initialize'',par)']);
logL   = 0;

% Loop through trials
for t = 1:par.ntrials

    % Get rewards and feature vector
    par.t         = t;           % Add in current time
    var(t).c_vec  = reshape( dta.c_vec(t,:),par.D,par.C,par.L*par.ncop,par.A );
        
    % Get expectations per arm
    mu       = eval([approach,'(''Estimate'',par,var)']);
            
    % Save mu
    MU(t,:) = mu(:)';
    
    % Soft-max probability
    p   = exp( par.tau*mu );
    p   = p/sum(p);
    
    % Get relevant information
    var(t).win = dta.R(t,:);
    var(t).arm = dta.arm(t);
    
    % Log-probability / probability of arm choices
    logL       = logL + log( p( dta.arm(t) ) );
    L0(t,1)    = p( dta.arm(t) );
    L0All(t,:) = p;
    
    % Update variables
    var(t+1) =  eval([approach,'(''Update'',par,var)']); 

end

disp([])
