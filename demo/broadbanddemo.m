% BROADBANDDEMO runs an example of a broadband source in a KRAKEN model
% 
% TODO document

clear;
close all;

% Build Acoustic Environment
cmin = 1500;
zmin = 1300;
ssp = gen_munk_profile([0:5:5000],zmin,cmin);% TODO

% TODO: include a range dependent profile
% ssp.r = [0 10e3];
% ssp.cp = [ssp.cp 1500*ones(size(ssp.cp))];

lyr1 = AcousticLayer(ssp);              % TODO 

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
Q = 3;                                  % Quality (frequency/bandwidth)
fc = 250;                                % Hz
bw = fc/Q;                              % bandwidth
fs = 4*fc;                              % sampling frequency
dt = 1/fs;                              % time resolution
N = fs*T                                % FFT length
df = fs/N                               % frequency resolution
freqs = [df:df:bw];
res.freqVec = [-fliplr(freqs) 0 freqs]+fc;% TODO: improve spectrum
nf = length(res.freqVec);
nyqst = ceil((nf+1)/2);
% wind = sinc((res.freqVec-fc)/bw);


for ifreq = 1:length(res.freqVec)
    src = AcousticSource(res.freqVec(ifreq),zmin)% freq,depth
    
    % Run model
    [shade,modes] = run_kraken(env,src,rcv,[1:999]);  % TODO
    res.pos = shade.pos;                % useless overwrite after second freq
    res.p(ifreq,1,:,:) = squeeze(shade.p);

end


% Perform FFT to get into time domain
p = squeeze(res.p(:,1,:,end));
% data = wind.*conj(p)
% data = [data(nyqst:nf), zeros(1,N-nf), data(1:nyqst-1)];

taxis = [0:N-1]/fs;
TL = fliplr(-20*log10(abs(ifft(p'))));
imagesc(taxis,res.pos.r.z,TL);
colorbar;
