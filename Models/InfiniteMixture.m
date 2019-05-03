function agent = InfiniteMixture(par,agent,world)
% Infinite-mixture model of learning from Gershman and Niv (2012)
% Input:
%      par   = structure of parameters
%      agent = structure of variables tracked by agent
%      world = structure of variables generate from task/world
% Output:
%      agent  = updated structure of variables tracked by agent
% WARNING: 
%       Cues & rewards need to be binary;
%       Rewards can be multidimensional, but have to be mutually-exclusive
%       e.g., rewards such as [1 0] and [0 1] are ok; but [1 1] is not 


%-------------------------------------------------------------------------
% Initialization of agent
if isempty(agent)       
        
    % Initial variables needed for imm learning
    agent.N   = sparse(par.imm.M,par.imm.K*(par.C+par.D));  % Feature-cluster co-occurence counts
    agent.B   = sparse(par.imm.M,par.imm.K*(par.C+par.D));  % Feature-cluster co-occurence counts
    agent.Nk  = sparse(par.imm.M,par.imm.K);                % Cluster counts
    agent.V   = ones(par.D,par.C)/2;                        % Associative strength per cue and outcome
    agent.lsb = [1,zeros(1,par.imm.K-1)];                   % Beliefs
    
%-------------------------------------------------------------------------
% Update of agent    
else
        
    % Variables from IMM
    Nk    = agent.Nk;
    N     = agent.N;
    B     = agent.B;
    win   = world.win;                      % Outcome
    c_vec = world.c_vec;                    % Cue vector
    
    % calculate CRP prior
    prior = Nk;
    for m = 1:par.imm.M
        prior(m,find(prior(m,:)==0,1)) = par.imm.alpha;
    end
    prior = bsxfun(@rdivide,prior,sum(prior,2));
    
    % Mean per arm, latent state, and outcome
    mu = zeros(par.D,par.A);
    for a = 1:par.A
        cue = c_vec(1,:,1,a);
        for d=1:par.D
            % Vector for a given reward
            solereward    = zeros(1,par.D);
            solereward(d) = 1;
            % Reward prediction for a given set of cues
            mu(d,a) =  RewardPrediction(solereward,cue,prior,Nk,N,B,par);   
        end
    end
        
    % Choose arm
    arm = SoftMaxChoice(mu,par);
    
    % Get relevant entries based on arm
    win   = reshape( win(:,arm), [], par.D);
    c_vec = squeeze( c_vec(:,:,1,arm) );        
    mu    = mu(:,arm)';
    
    % Initialize V (reward prediction)
    V = zeros(par.D,par.C); 

    % Likelihood
    lik       = N;
    ix        = reshape( (1:par.imm.K)' + (find([win,c_vec]==0)-1)*par.imm.K,1,[]);
    lik(:,ix) = B(:,ix);
    lik       = reshape( full( lik ),[],par.imm.K,par.C+par.D);
    lik       = bsxfun(@rdivide,lik+1,Nk+2);

    % (Partial) posterior of reward given cues only
    post  = prior.*squeeze(prod(lik(:,:,2:par.C+1),3));

    %-----------------------------------------------------------------
    % Edited part ... get expected outcome given each cue
    for c=1:par.C

        % Vector for a given cue
        solecue    = zeros(1,par.C);
        solecue(c) = 1;

        for d=1:par.D

            % Vector for a given reward
            solereward    = zeros(1,par.D);
            solereward(d) = 1;

            % Prediction reward given cues (averaged over particles)
            V(d,c)   = RewardPrediction(solereward,solecue,prior,Nk,N,B,par);           
        end
    end
        
    %-----------------------------------------------------------------

    % Add in reward outcomes to posterior; normalize; average over
    % particles
    post = post.*squeeze(lik(:,:,1));
    post = bsxfun(@rdivide,post,sum(post,2));
    post = mean(post);

    % Update particles
    for m = 1:par.imm.M
        [~, k] = histc(rand,[0 cumsum(full(post))]); %multinomial sample
        Nk(m,k) = Nk(m,k) + 1;
        N(m,k+(find([win,c_vec]==1)-1)*par.imm.K) = N(m,k+(find([win,c_vec]==1)-1)*par.imm.K) + 1;
        B(m,k+(find([win,c_vec]==0)-1)*par.imm.K) = B(m,k+(find([win,c_vec]==0)-1)*par.imm.K) + 1;
    end  

    % Output updated variables
    agent.V    = V;
    agent.Nk   = Nk;
    agent.N    = N;
    agent.B    = B;
    agent.lsb  = post; % Probability at end of trial
    agent.arm  = arm;
    agent.win  = win;
    agent.mu   = mu;
end
       


function V = RewardPrediction(r,x,prior,Nk,N,B,par)
% Predict reward outcome r given current estimates and cues x

% Likelihood of given cue/reward given latent state
tmplik        = N;
ix            = reshape( (1:par.imm.K)' + (find([r,x]==0)-1)*par.imm.K,1,[]);
tmplik(:,ix)  = B(:,ix);
tmplik        = reshape( full( tmplik ),[],par.imm.K,par.C+par.D );
tmplik        = bsxfun(@rdivide,tmplik+1,Nk+2);

% Posterior of latent cause given cues only and prior
tmppost  = prior.*squeeze(prod(tmplik(:,:,par.D+(1:par.C)),3));
tmppost0 = bsxfun(@rdivide,tmppost,sum(tmppost,2));

% Prob. of reward given cues only (averaged over particles)
V   = tmppost0(:)'*reshape(squeeze( prod(tmplik(:,:,1:par.D),3) ),[],1)./par.imm.M;                
