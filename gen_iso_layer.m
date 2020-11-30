function layer = gen_iso_layer(cp,upperLimit,lowerLimit)
% gen_iso_layer creates an AcousticLayer with a constant sound speed.
% 
% TODO: document
% TODO assert errors

    z = upperLimit(1);
    cp = cp;
    cs = zeros(size(cp));
    rho = ones(size(cp))*1e3;
    alpha = zeros(size(cp));
    beta = zeros(size(cp));
    
    range = 0;

    layer = AcousticLayer(z,cp,cs,rho,alpha,beta, ...
                          range,upperLimit,lowerLimit);    
end
