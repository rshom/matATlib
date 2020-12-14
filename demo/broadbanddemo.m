% BROADBANDDEMO runs an example of a broadband source in a KRAKEN model

clear;
close all;

% Build Acoustic Environment
cmin = 1500;
zmin = 1300;
ssp = gen_munk_profile([0:5:5000],zmin,cmin);
lyr1 = AcousticLayer(ssp);

srf = AcousticBoundary('vacuum',0,0);

flr.cp = 1800;
flr.cs = 0;
flr.rho = 2000;
flr.alpha = 0;
flr.beta = 0;
flr = AcousticBoundary('halfspace',5000,0,flr);

env = AcousticEnvironment('munk',srf,lyr1,flr);
env.maxRange = 100e3;                    % m

env.cHigh = 2000;

rcv = AcousticReciever(0:1000:env.maxRange,[0:1:env.maxDepth]); % ranges,depths

% Set up frequency spectrum
T = 4;                                  % time window (s)
Q = 3;                                 % Quality (frequency/bandwidth)
fc = 250;                               % Hz
bw = fc/Q;                              % bandwidth
fs = 4*fc;                              % sampling frequency
dt = 1/fs;                              % time resolution
N = fs*T;                               % FFT length
df = fs/N;                              % frequency resolution
freqs = [df:df:bw];
res.freqVec = [-fliplr(freqs) 0 freqs]+fc;
nf = length(res.freqVec);
nyqst = ceil((nf+1)/2);

for ifreq = 1:length(res.freqVec)
    disp(ifreq/length(res.freqVec))
    src = AcousticSource(res.freqVec(ifreq),zmin);% freq,depth

    [shade,modes] = run_kraken(env,src,rcv,[1:999]);  % TODO
    res.pos = shade.pos;                % useless overwrite after second freq
    res.p(ifreq,1,:,:) = squeeze(shade.p);

end

% Perform FFT to get into time domain
p = squeeze(res.p(:,1,:,end));
TL = fliplr(-20*log10(abs(ifft(p'))));

% Plot
taxis = [0:N-1]/fs;
imagesc(taxis,res.pos.r.z,TL);
colorbar;
