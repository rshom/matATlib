function [env] = gen_iso_env(cp,depth,range)
% gen_iso_env creates an AcousticEnvironment with an iso velocity.
% 
% TODO: document
    
    name = 'iso-env';
    maxRange = max(range);              % m
    maxDepth = max(depth)*1.1;          % m

    surfaceBdry = gen_vacuum_bdry(0);
    upperLimit = 0;
    lowerLimit = depth;

    waterCol = gen_iso_layer(cp,upperLimit,lowerLimit,maxRange);
    bottomBdry = gen_vacuum_bdry(depth);

    env = AcousticEnvironment(name,maxDepth,maxRange, ...
                              surfaceBdry,waterCol,bottomBdry);
    
end