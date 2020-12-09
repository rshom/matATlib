function field = run_padepe(env,src)
% RUN_PE returns a parabolic equation model of an AcousticEnvironment
% 
% Custom PE model written entirely in MATLAB.
% 
% author: [Russell Shomberg](rshomberg@gmail.com)
% date:   2020
    
% TODO clean up naming conventions (repeat names)
% TODO error handling
% TODO initialize parameters (using AcousticEnvironment)
% TODO plotting functions for AcousticEnvironment and results
    
    % Constant parameters TODO: set up to change
    np = 4;                  % ??? pade parameters use between 4 and 8
    ns = 0;                             % ??? stability factors
    nu = 0;                             % ???
    
    % Build acoustic field
    disp('generating field')
    field = env.field;
    % field.rho = field.rho./1000.0
    field.p = zeros(size(field.cp));    % acoustic pressure
    field.TL = zeros(size(field.cp));   % transmission loss
    
    % Frequency and wave number
    omega = 2*pi*src.freq;     % freq in radians
    cpRef = interp1(field.z(:,1),field.cp(:,1),src.z);
    k0 = omega./cpRef;

    eta = (40*pi*log10(exp(1)))^-1;
    field.k = (1+1i*eta.*field.beta)*omega./field.cp; % ??? beta or alpha
    field.ksq = field.k.^2 - k0^2;

    % Generate Pade Coefficients
    [gamma, beta] = epade(np,0,0,k0*env.dr,1);
    
    % Initialize pressure field  
    u = sqrt(k0) * exp(-(k0^2/2) * (field.z(:,1) - src.z).^2); % ???
    field.p(:,1) = u;

    for ridx = 2:size(field.p,2)         % March forward
        % disp(sprintf("Range: %f%",field.r(1,ridx)/field.r(1,end)))

        alpha = sqrt(field.rho(:,ridx).*field.cp(:,ridx));

        for iPade = 1:np
            
            R = matrc(field.rho(:,ridx), alpha, ...
                      field.ksq(:,ridx), k0, env.dz, beta(iPade));

            S = matrc(field.rho(:,ridx), alpha, ...
                      field.ksq(:,ridx), k0, env.dz, gamma(iPade));
            u = R\(S*u);                % eq. 10
            
        end
        
        u = exp(1i*k0*env.dr) .* u;     % eq. 8
        field.p(:,ridx) = u.*alpha;     % eq. 10

    end
    field.TL = -20*log10(abs(field.p./sqrt(field.r)));% TODO: check this
    % field.TL = -20*log10(abs(field.p*diag(sqrt(1./field.r(1,:)))));
end


function XX = matrc(rho,alpha,ksq,k0,dz,coef)
% matrc2 builds pade matrix 
% 
% TODO: document
    
    % alpha = sqrt(rho.*cp);
    
    dzsq = dz^2;

    rhoP = circshift(rho,1);
    rhoN = circshift(rho,-1);
    alphaP = circshift(alpha,1);
    alphaN = circshift(alpha,-1);
    ksqP = circshift(ksq,1);
    ksqN = circshift(ksq,-1);

    rhoP(1) = rho(1);
    alphaP(1) = alpha(1);
    ksqP(1) = ksq(1);

    rhoN(end) = rho(end);
    alphaN(end) = alpha(end);
    ksqN(end) = ksq(end);

    % Define diagonals
    a = +alphaP./(2*dzsq).*(rho./alpha).*(1./rhoP+1./rho)+(ksqP+ksq)./12;
    
    b = -alpha./(2*dzsq).*(rho./alpha).*(1./rhoP+2./rho+1./rhoN) ...
        +(ksqP+6.*ksq+ksqN)./12;
    
    c = +alphaN./(2*dzsq).*(rho./alpha).*(1./rho+1./rhoN)+(ksq+ksqN)./12;
    
    % Build tri-diagonal matrix
    XX = diag(2*k0^2/12 + coef.*c(1:end-1),  1)+ ...
         diag(8*k0^2/12 + coef.*b,           0)+ ...
         diag(2*k0^2/12 + coef.*a(2:end),   -1); % ??? use spdiags to create

end


function [gamma, beta] = epade(np,nu,alp,sig,ns)
% function [gamma beta]=epade(np,nu,alp,sig,ns)
%    np = number of pade terms
%    nu = only in self-starter (= 1)
% alpha = only in self-starter (= -0.25)
% sigma = k0*dr
%    ns = number of stability constraints (0, 1, or 2)
%
% Example 1: split step   
%       ==> nu = 0, alpha = 0, sigma = k0*dr, & ns = 1;
% Example 2: self-starter 
%       ==> nu = 1, alpha = -0.25, sigma = k0*dr, & ns = 2.
%
% Note that deriv.m is packaged as a subfunction in this file  
%   
% From Joe Lingevitch, Feb 2002
% Email: jfl@aslan.nrl.navy.mil
    
% TODO rewrite to get rid of for loops

    n = 2*np;

    switch ns
      case 1
        %	disp('ns = 1')
      case 2
        %	disp('ns = 2')
      otherwise
        %	disp('ns = 0')
        ns = 0;                         % weird way to handle this
    end

    i = sqrt(-1);                       % unecessary
    fp = deriv(np,nu,alp,sig);          % subfunction

    a = zeros(n);                       % c = inv(a)*b;
    b = zeros(n,1);                     % c = inv(a)*b;

    for j = 1:n
        a(j,j) = -factorial(j);
    end;

    for j = 1:np
        for k = 1:j-1
            a(j,np+k) = nchoosek(j,k)*factorial(k)*fp(j-k);
        end;
        a(j,np+j) = factorial(j);
    end;

    for j = np+1:n-ns
        for k = 1:np
            a(j,np+k) = nchoosek(j,k)*factorial(k)*fp(j-k);
        end;
    end;

    for j = 1:n-ns
        b(j) = -fp(j);
    end;

    % stability constraint
    if ns == 1 | ns == 2 
        %set g(-3)=0.0
        mu = 0.0;
        x0 = -3;
        j = n;
        for k = 1:np
            a(j,k) = -x0^k;
        end;

        for k = 1:np
            a(j,k+np) = mu*x0^k;
        end;

        b(j) = 1-mu;
    end;

    if ns == 2 
        %set g(-1.5)=0.0
        mu = 0.0;
        x0 = -1.5;
        j  = n-1;
        for k = 1:np
            a(j,k) = -x0^k;
        end;

        for k = 1:np
            a(j,k+np)=mu*x0^k;
        end;
        b(j) = 1-mu;
    end;

    c = inv(a)*b;

    % roots
    rootsnum = roots([transpose(c(np:-1:1)) 1]);
    rootsden = roots([transpose(c(n:-1:np+1)) 1]);

    gamma = -1./rootsnum;
    beta = -1./rootsden;
end

function [gamma, beta] = epade2(np,nu,alp,sig,ns)
% Produce pade coefs
% 
% TODO rewrite to get rid of for loops and replace epade

    % assert ns = 0,1,2

    n = 2*np;

    fp = deriv(np,nu,alp,sig);          % subfunction (rewrite)

    b = zeros(n,1);                     % c = inv(a)*b;

    a = diag(-factorial([1:n]));

    
    % TODO: define upper diag w/o loop
    for j = 1:np
        for k = 1:j-1
            a(j,np+k) = nchoosek(j,k)*factorial(k)*fp(j-k);
        end;
        a(j,np+j) = factorial(j);
    end;

    % TODO: define lower diag w/o loop
    for j = np+1:n-ns
        for k = 1:np
            a(j,np+k) = nchoosek(j,k)*factorial(k)*fp(j-k);
        end;
    end;

    for j = 1:n-ns
        b(j) = -fp(j);
    end;

    b = -fp;                            % ??? check

    % stability constraint
    if ns == 1 | ns == 2 
        %set g(-3)=0.0
        mu = 0.0;
        x0 = -3;
        j = n;
        for k = 1:np                    % TODO: no loop
            a(j,k) = -x0^k;             % TODO: this gets over written
        end;

        for k = 1:np                    % TODO: no loop
            a(j,k+np) = mu*x0^k;% TODO: mu is 0 so this is overwritten
        end;

        b(j) = 1-mu;                    % TODO: mu is 0 so this is 1
    end;

    if ns == 2 
        %set g(-1.5)=0.0
        mu = 0.0;
        x0 = -1.5;
        j  = n-1;
        for k = 1:np
            a(j,k) = -x0^k;             % TODO: this gets overwritten
        end;

        for k = 1:np
            a(j,k+np)=mu*x0^k;          % TODO: mu is 0 so this is 0
        end;
        b(j) = 1-mu;                    % TODO: mu is 0 so this is 1
    end;

    % c = inv(a)*b;
    c = a\b;

    % roots
    rootsnum = roots([transpose(c(np:-1:1)) 1]);
    rootsden = roots([transpose(c(n:-1:np+1)) 1]);

    gamma = -1./rootsnum;
    beta = -1./rootsden;
end

function fp=deriv(np,nu,alp,sig)
% deriv(np,nu,alp,sig)
% deriv returns 2*np deriviative of f given nu, alp, sig
% by Joe Lingevitch
    
% TODO rewrite

    n = 2*np;

    f = 1;
    w = -2*nu+alp+i*sig/2;

    %compute 2n derivatives evaluated at x=0
    fp(1) = f*w;

    for j = 1:2*n
        wp(j) = -2*factorial(j)*nu^(j+1)+(-1)^j*alp*factorial(j)+ ... 
                1i*sig*(-1)^(j)*prod(1:2:2*j-1)/2^(j+1);
    end

    for j = 2:n
        fp(j) = wp(j-1)*f+w*fp(j-1);
        for k = 1:j-2
            fp(j) = fp(j)+nchoosek(j-1,k)*wp(j-k-1)*fp(k);
        end
    end

end
