function ssp = gen_munk_profile(z,zmin,cmin)
% GEN_MUNK_LAYER constructs a AcousticLayer with munk profile ssp
% 
% TODO finish function

    z = z(:);                           % ensure column vector
    zt = 2*(z-zmin)/zmin;

    epsilon  = .00737;             % ??? something to do with munk profile
    ssp.cp = cmin*(1+epsilon*(zt-1+exp(-zt)));
    

    ssp.cs = zeros(length(z),1);
    ssp.rho = ones(length(z),1)*1000.0;
    ssp.alpha = zeros(length(z),1);
    ssp.beta = zeros(length(z),1);
    
    ssp.z = z;

end