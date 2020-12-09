function layer = gen_munk_layer(z,zmin,cmin)
% GEN_MUNK_LAYER constructs a AcousticLayer with munk profile ssp
% 
% TODO finish function

    zt = 2*(z-zmin)/zmin;

    epsilon  = .00737;             % ??? something to do with munk profile
    cp = cmin*(1+epsilon*(zt-1+exp(-zt)));

    cs = zeros(size(z));
    rho = ones(size(z))*1000.0;
    alpha = zeros(size(z));
    beta = zeros(size(z));
    
    range = 0;
    upperLimit = 0;
    lowerLimit = z(end);

    layer = AcousticLayer(z,range,cp,cs,rho,alpha,beta, ...
                          upperLimit, lowerLimit);

end