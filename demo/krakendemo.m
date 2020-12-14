% KRAKENDEMO runs KRAKEN on a simple pekeris wave guide.
% 
% The environment is a shallow water waveguide with a sediment layer
% and an acoustic halfspace ocean floor. 
% 
% TODO: document

% Build Acoustic Environment
ssp.r = 0;
ssp.z = [0; 100];                       % m
ssp.cp = 1500;                          % m/s
ssp.cs = 0;                             % m/s
ssp.rho = 1000;                         % kg/m3
ssp.alpha = 0;                          % db/wavelength
ssp.beta = 0;                           % db/wavelength
lyr1 = AcousticLayer(ssp);

btm.z = [101; 200];                     % m
btm.cp = 1700;                          % m/s
btm.cs = 0;                             % m/s
btm.rho = 1500;                         % kg/m3
btm.alpha = 0.5;                        % db/wavelength
btm.beta = 0.5;                         % db/wavelength
lyr2 = AcousticLayer(btm);

srf = AcousticBoundary('vacuum',0,0);

flr.cp = 1800;
flr.cs = 0;
flr.rho = 2000;
flr.alpha = 0;
flr.beta = 0;
flr = AcousticBoundary('halfspace',200,0,flr);

env = AcousticEnvironment('shallow',srf,[lyr1 lyr2],flr);
env.maxRange = 10e3;                    % m

src = AcousticSource(150,50);            % freq,depth
rcv = AcousticReciever([0:env.maxRange],[0:env.maxDepth]); % ranges,depths

% Run model
[shade,modes] = run_kraken(env,src,rcv,[1:7]);  % TODO: modes are not right
TL = squeeze(shade.TL);

% Display results
imagesc(shade.pos.r.r,shade.pos.r.z,TL)
colorbar;
caxis([0 50]);

% TODO: plot modes
% TODO: plot shade

