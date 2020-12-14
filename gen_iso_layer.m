function layer = gen_iso_layer(cp,upperLimit,lowerLimit)
% gen_iso_layer creates an AcousticLayer with a constant sound speed.
% 
% TODO: document
% TODO assert errors

    r = 0                               % range
    z = [max(upperLimit) max(lowerLimit)];
    
    cp = [cp;cp];
    cs = zeros(size(cp));
    rho = ones(size(cp))*1e3;
    alpha = zeros(size(cp));
    beta = zeros(size(cp));
    
    layer = AcousticLayer(z,r,cp,cs,rho,alpha,beta, ...
                          upperLimit,lowerLimit);    
    
    layer.name = 'iso-layer';
end
