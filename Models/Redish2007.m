function agent = Redish2007(par,agent,world)
% Redish (2017) model of learning
% Input:
%      par   = structure of parameters
%      agent = structure of variables tracked by agent
%      world = structure of variables generate from task/world
% Output:
%      agent  = updated structure of variables tracked by agent

% Warning about multidimensional rewards
if par.D~=1
    disp('Warning: model is not defined for multidimensional rewards') 
end

% Warning about bandit tasks
if par.A~=1
    disp('Warning: cues are assumed to be trivial (i.e. constant) for bandit tasks') 
end

%-------------------------------------------------------------------------
% Initialization of agent
if isempty(agent)   

    % Initialize agent
    agent = InitializeAgent(par.C, par.A);    
    
    % Initialize associative strength 
    agent.V = zeros(1,par.C);
    
    % Initialize last win as 0
    agent.win = 0;
    
    % Initialize last arm to be 1
    agent.arm = 1;
    
    % Initialize softmax parameter
    agent.tau = par.tau;
    
    % Initialize latent states
    agent.lsb = 1;
    
%-------------------------------------------------------------------------
% Update of agent    
else
    
    % Build world state
    S.R      = agent.win*100;         % Last win
    S.cues   = world.c_vec(:,:,1,:);  % Cues
    S.win    = world.win;             % Possible outcomes by arm
    S.action = agent.arm;             % Last action
    
    % Adjust for bandit tasks (trivial cue)
    if par.A > 1
    
        % Trivial cue, add in last reward, and time to last reward
        S.cues = [1*100,S.R,0];

        % Cycle agent
        agent = CycleAgent(agent,S);

        % Store value function as "associative strength" (rescaled)
        agent.V = agent.vX(:)'/100;
        
    else
        S.cues = [S.cues*100,S.R,0]; % Rescale, add in reward & time to last reward

        % Cycle agent
        agent = CycleAgent(agent,S);

        % Adjust last win
        S.R    = agent.win*100;
        
        % Store value of current state
        agent.mu = agent.vX(agent.agentState,1)/100;
 
        % Cycle agent to "associative strengths" per cue
        for i=1:par.C

            % Use standard base vector as cues
            ei               = zeros(1,par.C+2);
            ei([i,par.C+1])  = 1*100; % Scale by 100
            S.cues           = ei; 
        
            % Pretend to "cycle" agent with reward
            tmp1        = CycleAgent(agent, S);
            
            % Pretend to "cycle" agent with no reward
            ei(par.C+1) = 0;
            S.cues      = ei; 
            tmp2        = CycleAgent(agent, S);
            
            % Store average value function of agent state (rescaled)
            agent.V(1,i) = tmp1.vX(tmp1.agentState,1)/200 + ...
                           tmp2.vX(tmp2.agentState,1)/200;

        end
    end
end


function A = CycleAgent(A, S)

lastAgentState = A.agentState;

% CUES
if S.R>0 
    A.TSLR = 0; 
else
    A.TSLR = A.TSLR + 1; 
end
cues = S.cues; 
cues(end) = A.TSLR;
if A.nM == 1
	A.cue_memory = cues + A.cue_noise * randn(size(cues));
	cues         = A.cue_memory';
else
	A.cue_memory(1:(end-1), :) = A.cue_memory(2:end,:);
	A.cue_memory(end,:)        = cues + A.cue_noise * randn(size(cues));
	cues                       = A.cue_memory(:);
end
	
% delta bar effects
db = -tanh(A.deltaBar/A.zetaDB);
cue_weight = 1 * db + (1-db) * A.cue_weight;
THORNrho = A.THORNrho;

D2 = zeros(A.nX,1);
pX = zeros(A.nX,1);

for iX = 1:A.nX
	D2(iX) = (cue_weight .* (cues - A.pXC_mu(iX,:)'))' * A.pXC_sigmaI{iX} * (cue_weight .* (cues - A.pXC_mu(iX,:)'));
	pX(iX) = exp(-0.5 * D2(iX)) / (2*pi)^(length(cues)/2) / sqrt(A.pXC_detSigma(iX));
end

% WARNING
if any(pX>1)
	%warning('pX is not a probability!');
	pX(pX>1) = 1;
end

[mX, A.agentState] = max(pX);
if (mX > THORNrho) % found an acceptable match
	A.pXC_history{A.agentState}(end+1,:) = cues;
	A.pXC_mu(A.agentState,:)             = mean(A.pXC_history{A.agentState});
	if size(A.pXC_history{A.agentState},1) > A.min_cue_memory_for_measuring_information
		A.pXC_sigmaI{A.agentState}   = cov(A.pXC_history{A.agentState})^-1;
		A.pXC_detSigma(A.agentState) = det(cov(A.pXC_history{A.agentState}));
	end
else % too far away
	A.agentState = A.nX+1;
	A.nX         = A.nX+1;
	A.pXC_mu(A.agentState,:)     = cues;
	A.pXC_sigmaI{A.agentState}   = eye(length(cues),length(cues))/A.sigma0;
	A.pXC_detSigma(A.agentState) = det(eye(length(cues),length(cues))*A.sigma0);

	A.pXC_history{A.agentState} = cues';
	A.vX(end+1,:) = 0;
end

% Save indicator of agent state
A.lsb               = zeros(1,A.nX);
A.lsb(A.agentState) = 1;

% cues
A.cue_history(end+1,:) = cues;
if size(A.cue_history,1) > A.min_cue_memory_for_measuring_information
	A.cue_weight = cue_MI(A.cue_history, A.pXC_history)';
	A.cue_weight = 0.5 + 0.5 * tanh((A.cue_weight-0.5)*A.CW_zeta);  % rescale it
end

eta = A.eta; %eta = (1-db) * A.eta;
% delta
if ~isempty(S.action)
	% value and delta
	A.delta = A.gamma * max(A.vX(A.agentState,:)) + S.R - A.vX(lastAgentState,S.action);
	
    A.deltaBar = A.zeta0 * A.deltaBar + A.zeta1 * min(0,A.delta);
    
    A.vX(lastAgentState,S.action) = A.vX(lastAgentState,S.action) + eta * A.delta;
end

% decide on next action
par.tau = A.tau;
A.arm   = SoftMaxChoice(A.vX(A.agentState,:),par);

% Get win
A.win   = S.win(:,A.arm);

function A = InitializeAgent(nC, nA)

% constructor for agent state
A.nC = nC+2;
A.nA = nA;
A.nM = 1;

A.eta      = 0.05; % learning rate
A.sigma0   = 25;   % initial size of RBF
A.THORNrho = 1e-8; % threshold for creating a new state
A.gamma    = 0.25; % discount factor

% states
A.nX              = 1;
A.mX              = 0;
A.pXC_mu          = zeros(A.nX,A.nM*A.nC);
A.pXC_sigmaI{1}   = eye(A.nM*A.nC,A.nM*A.nC)/A.sigma0;  % assume cues independent
A.pXC_detSigma(1) = det(eye(A.nM*A.nC,A.nM*A.nC)*A.sigma0); 
A.pXC_history     = {zeros(A.nM*A.nC)};
A.agentState      = 1;

% value
A.vX             = zeros(A.nX, A.nA);
A.delta          = 0;
A.deltaBar       = 0;
A.TSLR           = 0;

A.fixAtThreshold = 10;

A.zeta0  = 0.9999;
A.zeta1  = 1.5;
A.zetaDB = 1;
A.zetaR  = 1;

% cues
A.cue_weight      = 0.5*ones(A.nM * A.nC,1);
A.cue_history     = [];
A.cue_memory      = NaN(A.nM, A.nC);
A.cue_memory(end) = 0;

A.cue_noise = 1;
A.CW_zeta   = 3;
A.min_cue_memory_for_measuring_information = 100; % min samples before use samples to estimate parameters

%--------------------------------------
% CUE MI
function CW = cue_MI(cue_memory, pXC_memory)
nC = size(cue_memory,2);
nX = length(pXC_memory);
H = zeros(1, nX); CW = zeros(1, nC);
for iC = 1:nC
    C = cue_memory(:,iC);
    h = histc(C, (0:100:500)-50); h = h/sum(h);
    H0 = - sum(h .* log2(h + eps));
    for iX = 1:nX
		if ~isempty(pXC_memory{iX})
			C = pXC_memory{iX}(:,iC);
			h = histc(C,(0:100:500)-50); 
            if sum(h)>0, h = h/sum(h); end
			H(iX) = - sum(h .* log2(h + eps));
		else
			H(iX) = 0;
		end
    end
    CW(iC) = H0 - sum(H);
end

