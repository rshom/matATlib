function [env] = gen_iso_env(cp,depth,range)
% gen_iso_env creates an AcousticEnvironment with an iso velocity.
% 
% TODO: document
    
    name = 'iso-env';
    maxRange = max(range);              % m
    maxDepth = max(depth);              % m

    surfaceBdry = gen_vacuum_bdry();
    upperLimit = [0 0];
    lowerLimit = [depth depth];

    waterCol = gen_iso_layer(cp,upperLimit,lowerLimit);

    bottomBdry = gen_vacuum_bdry();

    env = AcousticEnvironment(name,maxDepth,maxRange, ...
                              surfaceBdry,waterCol,bottomBdry);
    
end