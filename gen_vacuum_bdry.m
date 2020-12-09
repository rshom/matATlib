function bdry = gen_vacuum_bdry(depth)
% gen_vacuum_bdry creates a vacuum AcousticBoundary
% 
% TODO: document
    
    cp = NaN;                           % TODO: set to 0?
    cs = NaN;
    rho = NaN;
    alpha = NaN;
    beta = NaN;
    depth = depth;
    
    bdry = AcousticBoundary('vacuum',cp,cs,rho,alpha,beta,depth);
 
end