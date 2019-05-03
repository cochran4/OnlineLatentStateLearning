function agent = Gershman2017_alpha1(par,agent,world)
% Latent cause modulated Rescorla-Wagner model of Gershman et al (2017)
% but with alpha = 1

% Change alpha parameter to 1
par.gershman.alpha = 1;

% Run latent-cause model
if nargin > 2
    agent = Gershman2017(par,agent,world);
else
    agent = Gershman2017(par,agent,[]);
end