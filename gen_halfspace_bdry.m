function bdry = gen_halfspace_bdry(depth,cp,cs,rho,alpha,beta)
% gen_halfspace_bdry creates a acoustic halfspace AcousticBoundary
% 
% TODO: document

    bdry = AcousticBoundary('halfspace',cp,cs,rho,alpha,beta,depth);
     
end