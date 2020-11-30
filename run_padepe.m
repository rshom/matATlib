function TL = run_padepe(env,src,depths,ranges)
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
    
    np = 4;                  % ??? pade parameters use between 4 and 8
    ns = 0;                             % ??? stability factors
    nu = 0;                             % ????
    
    rangeStep = ranges(2)-ranges(1);
    depthStep = depths(2)-depths(1);

    omega = 2*pi*src.freq;     % freq in radians
    
    env.layers(1).z;
    env.layers(1).cp;

    if length(env.layers(1))==1
        cpRef = env.layers(1).cp;
    else
        cpRef = interp1(env.layers(1).z,env.layers(1).cp,env.source.z);
        % TODO: interp1 does not work because it is an iso env which means
        % there are duplicates    
    end
    
    k0 = omega./cpRef;
    
    field = zeros( length(depths),length(ranges) );      % Allocate field
    
    % TODO: build field profiles for cp,cs,rho, alpha, and so on. This
    % will replace the profile function or use it.
    
    [gamma, beta] = epade(np,nu,0,k0*rangeStep,2);% ???
    [ksq, rho, alpha] = profl(env,src,depthStep);
    
    % Initialize pressure field    
    pressureField = field;
    pressure = sqrt(k0) * exp(-k0^2 / 2 * (depths' - src.z).^2);

    for idx = 2:size(ranges,2)
        for iPade = 1:np
            R = matrc(rho, alpha, ksq, k0, beta(iPade));
            S = matrc(rho, alpha, ksq, k0, gamma(iPade));
            pressure = R\(S*pressure);  % eq. 10
        end
        pressure = exp(i*k0*rangeStep) .* pressure;% eq. 8
        pressureField(:,idx) = pressure.*alpha';% eq. 10
    end
    %TL = -20*log10(abs(pressureField*diag(sqrt(1./ranges))));% TODO
    TL = -20*log10(abs(pressureField));
end

function X = galerkins_method()
% ??? eq.14 build some kind of matrix at some point



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

    n = 2*np;

    switch ns
      case 1
        %	disp('ns = 1')
      case 2
        %	disp('ns = 2')
      otherwise
        %	disp('ns = 0')
        ns = 0;
    end

    i = sqrt(-1);
    fp = deriv(np,nu,alp,sig);

    a = zeros(n);
    b = zeros(n,1);

    for j = 1:np
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

    %debugging code

    debug = 0;
    if debug == 1
        x = -1:0.01:1;

        for j = 1:size(x,2)
            num = 1.0;
            den = 1.0;
            for k = 1:np
                num = num+c(k)*x(j)^k;
                den = den+c(k+np)*x(j)^k;
            end;
            g(j) = num/den;
        end

        num = 1.0;
        den = 1.0;
        for k = 1:np
            num = num+c(k)*x0^k;
            den = den+c(k+np)*x0^k;
        end;

        constraint = num/den

        f = (1-nu*x).^2.*(1+x).^alp.*exp(i*sig*(sqrt(1+x)-1));

        figure
        subplot(211)
        plot(x,real(f),'k-','linewidth',1);hold on
        set(gca,'linewidth',1.,'fontsize',11)
        plot(x,real(g),'r--','linewidth',1)
        title1 = ['f(x) = (1-\nu x)^2 (1+x)^{\alpha} exp({\it i} \sigma ((1+x)^{1/2}-1)) \approx g(x)'];
        title2 = ['                             np = ',...
                  int2str(np),', ns = ',int2str(ns),', \sigma: +',];
        txt = char(title1,title2); 
        title(txt,'fontsize',12)
        ylabel('Real part','fontsize',11)

        subplot(212)
        plot(x,imag(f),'k-','linewidth',1);hold on
        set(gca,'linewidth',1.,'fontsize',11)
        plot(x,imag(g),'r--','linewidth',1)
        xlabel('x','fontsize',11)
        ylabel('Imaginary part','fontsize',11)
        legend('f(x)','g(x)')

        newpp = [0.25 2.5 8 6];
        set(gcf,'Paperposition',newpp)              
        filename = ['padec_np',num2str(np),'_ns_',num2str(ns),...
                    '_sig',num2str(sign(sig)),'.eps']; 
        print('-depsc', filename)
    end;

end

function fp=deriv(np,nu,alp,sig)
% deriv(np,nu,alp,sig)
% deriv returns 2*np deriviative of f given nu, alp, sig
% by Joe Lingevitch

    n = 2*np;

    i = sqrt(-1);

    f = 1;
    w = -2*nu+alp+i*sig/2;

    %compute 2n derivatives evaluated at x=0
    fp(1) = f*w;

    for j = 1:2*n
        wp(j) = -2*factorial(j)*nu^(j+1)+(-1)^j*alp*factorial(j)+ ... 
                i*sig*(-1)^(j)*prod(1:2:2*j-1)/2^(j+1);
    end

    for j = 2:n
        fp(j) = wp(j-1)*f+w*fp(j-1);
        for k = 1:j-2
            fp(j) = fp(j)+nchoosek(j-1,k)*wp(j-k-1)*fp(k);
        end
    end

end

function [ksq, rho, alpha] = profl(env,src,dz)
   
    z = 0:dz:env.maxDepth;
    
    waterCol = env.layers(1);
    cp = waterCol.cp*ones(size(z));
    rho = waterCol.rho*ones(size(z));
    alpha = waterCol.alpha*ones(size(z));
        
    idx = z>=env.bottomBdry.depth;
    cp(idx) = env.bottomBdry.cp;
    alpha(idx) = env.bottomBdry.alpha;
    beta(idx) = env.bottomBdry.beta;

    % NOTE: stolen from orig
    eta = 1/(40*pi*log10(exp(1)));      % ???
    k_0 = 2*pi*src.freq / 1500;       % FIXME: depends on source depth
    k = (1 + 1i*eta*beta)*(2*pi*src.freq)./cp;    

    ksq = k.^2 - k_0^2;
    rho(idx) = env.bottomBdry.rho;
    alpha = sqrt(rho.*cp);          % ???: what is alpha here
    
end
    

function XX = matrc(rho, alpha, ksq, k_0, pade_coeff)
% TODO write my version
    XX = zeros(length(rho));
    
    a = zeros(length(rho), 1);
    b = zeros(length(rho), 1);
    c = zeros(length(rho), 1);
    
    a(1, :)= 2*k_0^2/12 + pade_coeff*(1/2 * (rho(1)/alpha(1)) + 1/12*(ksq(1)));
    b(1, :)= 8*k_0^2/12 + pade_coeff*(-1/2 * (rho(1)/alpha(1)) * (2/(rho(1)) + 1/(rho(1+1)))*alpha(1) + 1/12*(6*ksq(1)+ ksq(1 + 1)));
    c(1, :)= 2*k_0^2/12 + pade_coeff*(1/2 * (rho(1)/alpha(1)) * (1/(rho(1+1)) + 1/(rho(1)))*alpha(1+1) + 1/12*(ksq(1+1) + ksq(1)));
    
    for j = 2:length(rho) - 1
        
        a(j, :)= 2*k_0^2/12 + pade_coeff*(1/2 * (rho(j)/alpha(j)) * (1/(rho(j-1)) + 1/(rho(j)))*alpha(j-1) + 1/12*(ksq(j-1) + ksq(j)));
        b(j, :)= 8*k_0^2/12 + pade_coeff*(-1/2 * (rho(j)/alpha(j)) * (1/(rho(j-1)) + 2/(rho(j)) + 1/(rho(j+1)))*alpha(j) + 1/12*(ksq(j-1) + 6*ksq(j)+ ksq(j + 1)));
        c(j, :)= 2*k_0^2/12 + pade_coeff*(1/2 * (rho(j)/alpha(j)) * (1/(rho(j+1)) + 1/(rho(j)))*alpha(j+1) + 1/12*(ksq(j+1) + ksq(j)));
        
    end
    
    %a(length(rho), :) = a(length(rho) - 1, :);
    b(length(rho), :) = b(length(rho) - 1, :);
    %c(length(rho), :) = c(length(rho) - 1, :);
    
    main_diag = diag(b, 0);
    upper_diag = diag(a(1:end-1));
    lower_diag = diag(c(1:end-1));
    
    padding = zeros(1, length(b));
    
    upper_diag = [padding(1:end-1); upper_diag];
    upper_diag = [upper_diag , padding(1:end)'];
    
    lower_diag = [lower_diag; padding(1:end-1)];
    lower_diag = [padding(1:end)', lower_diag];
    
    XX = XX + main_diag + upper_diag + lower_diag;
    
end
