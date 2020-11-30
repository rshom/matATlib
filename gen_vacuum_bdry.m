function bdry = gen_vacuum_bdry()
% gen_vacuum_bdry creates a vacuum AcousticBoundary
% 
% TODO: document
    
    cp = NaN;
    cs = NaN;
    rho = NaN;
    alpha = NaN;
    beta = NaN;
    depth = NaN;
    
    bdry = AcousticBoundary('vacuum',cp,cs,rho,alpha,beta,depth);
 
end