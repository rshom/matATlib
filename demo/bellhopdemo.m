% BELLHOPDEMO
% 
% TODO: document

% Build Acoustic Environment
cmin = 1500;
zmin = 1300;
ssp = gen_munk_profile([0:5:6000],cmin,zmin);% TODO

% TODO: include a range dependent profile
% ssp.r = [0 10e3];
% ssp.cp = [ssp.cp 1500*ones(size(ssp.cp))];

lyr1 = AcousticLayer(ssp);              % TODO 

srf = AcousticBoundary('vacuum',0,0);   % TODO

flr.cp = 1800;
flr.cs = 0;
flr.rho = 2000;
flr.alpha = 0;
flr.beta = 0;
bty.r = [0 2000 3000 4000];             % m
bty.z = [5000, 1000, 5000 5000];        % m

% flr = AcousticBoundary('halfspace',bty.z,bty.r,flr);
flr = AcousticBoundary('halfspace',6000,0,flr);

env = AcousticEnvironment('shallow',srf, lyr1,flr);
env.maxRange = 100e3;                    % m
env.maxDepth = 6001;

src = AcousticSource(100,zmin);         % freq,depth
rcv = AcousticReciever(env.maxDepth,env.maxRange);

% Run model
rays = run_bellhop(env,src,rcv,'ray');

% src.alpha = [-20:.01:20];
% rays = run_bellhop(env,src,rcv,'eigen');% TODO

% Display results
t = tiledlayout(1,4,'visible','on');
t.Title.String = ['Propagation model: ' env.name];

ax1 = nexttile;
t.TileSpacing = 'compact';
t.YLabel.String = 'Depth (m)';

plot(env.lyrs(1).cp,-env.lyrs(1).z,'k-');
title('Sound Speed');
xlabel('Speed (m/s)');

ax2 = nexttile([1,3]); hold on;
linkaxes([ax1,ax2],'y');
xlabel('Range (km)');
title('Ray Plot');
for ray = rays
    displayCode = 'k-';
    if min(ray.z)<0
        displayCode = 'k--';
    end
    if max(ray.z)>env.lyrs(1).z(end)
        displayCode = 'k:';
    end
    
    plot(ray.r./1000.0,-ray.z, displayCode);
    ylim([-env.maxDepth 0]);
    xlim([0 env.maxRange/1000]);
end

