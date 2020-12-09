function bdry = gen_halfspace_bdry(cp,cs,rho,alpha,beta,depths)
% gen_halfspace_bdry creates a acoustic halfspace AcousticBoundary
% 
% TODO: document

    bdry = AcousticBoundary('halfspace',cp,cs,rho,alpha,beta,depths);
    
end