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
        z(1,:) double = [0];            % Boundary depth (m)
        r(1,:) double = [0];            % Boundary depth ranges (m)
        interpFunc (1,:) char = 'linear'; % TODO: document
        
    end
    
    properties (Dependent)
        field double;                   % TODO: document
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

            % Error check
            obj.z = depth(1,:);
            if size(depth,1)==2
                obj.r = depth(2,:);
            else
                obj.r = 0;
            end

        end
       
    end
    
    methods                             % getter/setter
        
        function field = get.field(obj)
        % Return acoustic field profiles

            field.r = obj.r;
            field.z = obj.z;

            % Basement values are constant
            field.cp = obj.cp*ones(size(field.z));
            field.cs = obj.cs*ones(size(field.z));
            field.rho = obj.rho*ones(size(field.z));
            field.alpha = obj.alpha*ones(size(field.z));
            field.beta = obj.beta*ones(size(field.z));
            
            
        end
        
    end



    
end
