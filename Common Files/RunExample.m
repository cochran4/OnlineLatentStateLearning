function RunExample(exnme,mdls,nrep,cases,par)
% Run example from one of the tasks
% Input: 
%       exnme  = string containing example name
%       mdls   = cell containing model names
%       nrep   = number of simulated replicates
%       cases  = cell containing case names
%       par    = structure of patient-specific model parameters
%-------------------------
% Design choices 

% Loop through design parameters
for i=1:length(mdls)

    % Display which model is running
    disp(['Running ... ',mdls{i}])
    
    % Loop through cases
    for k=1:length(cases)
    
        % Clear prior data
        clear MU0 LSB0 V0 WINS0 
    
        % Add in case  
        par.case = cases{k};
        
        % Add in model name
        par.modelname = mdls{i};
        
        % Loop through replications of simulation runs
        for r = 1:nrep
    
            clear mu v lsb
            
            % Display simulation show count
            if mod(r,10)==0
                disp(['   Run #',num2str(r)])
            end
            
            % Simulate task
            [mu,v,lsb,~,par] = RunTask(par,exnme,mdls{i});
            
            % Total number of latent states
            par.Lmax = par.ls.ncop*par.L;
            
            % Store variables
            if contains(mdls{i},'LatentState')
                
                % Sum of beliefs over replicates of a hypothesis
                nrm = sum( reshape( lsb,[],1, par.L,par.ls.ncop ), 4);
                
                % Mean associative strengths over replicates of a hypothesis
                v  = reshape( sum( ...
                     reshape( v, [], par.D*par.C, par.L,par.ls.ncop ).*...
                     reshape( lsb,[],           1, par.L,par.ls.ncop ), 4)./nrm,...
                       [],par.D*par.C*par.L ); % Average over copies of latent-states
                                
                % Store latent-state beliefs  
                LSB0(:,:,r) = lsb;
                
            elseif contains( mdls{i},'InfiniteMixture')
                
                % Beliefs
                LSB0(:,:,r) = lsb;
                    
                
            elseif contains(mdls{i},'Gershman2017')
                
                
                % Average over latent-states
                v = sum( reshape(v,[],par.C,par.gershman.K).*...
                         reshape(lsb,[],1,par.gershman.K), 3 );
                
                % Store latent-state beliefs  
                LSB0(:,:,r) = lsb;
                
            elseif contains(mdls{i},'Redish2007')
                LSB0(:,:,r) = lsb;
            else
                LSB0(:,:,r) = 0;
            end
            
            % Save variables (rewards, associative strengths)
            MU0(:,:,r) = mu;
            V0(:,:,r)  = v;

        end

        % Save mean and standard deviation across simulation instances
        MU{i,k}(:,:,1)  = mean( MU0,  3 );
        MU{i,k}(:,:,2)  = std(  MU0,  [], 3 );
        LSB{i,k}(:,:,1) = mean( LSB0, 3 );
        LSB{i,k}(:,:,2) = std(  LSB0, [], 3 );
        V{i,k}(:,:,1)   = mean( V0, 3 );
        V{i,k}(:,:,2)   = std(  V0, [], 3 );
        
    end
end
clear i k r v mu lsb MU0 LSB0 V0 nrm t var mu0

% Save results
save(['Results_',exnme])