classdef AcousticBoundary
% AcousticBoundary
% 
% Parameters of the acoustic boundary are not automatically set. Use
% gen_type_bdry functions to produce boundary layers.o
    
    properties
        % Options

        type (1,:) char = 'vacuum';
        
        % Properties
        % TODO: create better default values (probably 0?)
        cp(1,1) double;           % Pressure wave speed (m/s)
        cs(1,1) double;           % Shear wave speed (m/s)
        rho(1,1) double;          % Density (kg/m3)
        
        alpha(1,1) double;        % Pressure wave attenuation
        beta(1,1) double;         % Shear wave attenuation
        
        sigma(1,1) double = 0;          % Roughness (m)

        % Range Dependence        
        depth(1,:) double = [0];        % Boundary depth (m)
        interpFunc (1,:) char = 'linear';
        
    end
    
    methods(Access=public)
        function obj = AcousticBoundary(type,cp,cs,rho,alpha,beta,depth);
        % Construct simple vacuum boundary at a depth

            obj.type = type;
            obj.cp = cp;
            obj.cs = cs;
            obj.rho = rho;
            obj.alpha = alpha;
            obj.beta = beta;
            obj.depth = depth;

        end
    end
    
end
