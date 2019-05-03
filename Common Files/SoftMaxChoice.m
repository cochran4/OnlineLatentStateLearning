function [arm,p] = SoftMaxChoice(mu,par)

% Soft-max probability
p   = exp( par.tau*mu - max(par.tau*mu) );
p   = p/sum(p);

% Pick arm
arm = find( rand < cumsum(p) , 1, 'first' );  
disp([])