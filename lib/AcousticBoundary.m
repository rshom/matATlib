classdef AcousticBoundary
% AcousticBoundary
% 
% Parameters of the acoustic boundary are not automatically set. Use
% gen_type_bdry functions to produce boundary layers.o
    
    properties
        % Options
        type (1,:) char = 'vacuum';
        
        % Properties
        cp(1,1) double;           % Pressure wave speed (m/s)
        cs(1,1) double;           % Shear wave speed (m/s)
        rho(1,1) double;          % Density (kg/m3)
        alpha(1,1) double;        % Pressure wave attenuation
        beta(1,1) double;         % Shear wave attenuation
        sigma(1,1) double = 0;          % Roughness (m)

        % Range Dependence        
        r(1,:) double = [0];            % Boundary depth ranges (m)
        z(1,:) double = [0];            % Boundary depth (m)
        interpFunc (1,:) char = 'linear';% Depth interp function
    end
    
    properties (Dependent)
        field double;                   % TODO: document
    end
    
    methods(Access=public)
        function bdry = AcousticBoundary(type,depths,ranges,varargin);
        % Construct AcousticBoundary
        % 
        % type = 'vacuum'
        % 
        % type = 'halfspace'

            
            bdry.type = type;
            bdry.z = depths;
            bdry.r = ranges;
            switch bdry.type
              case 'vacuum'
                bdry.cp = 0;
                bdry.cs = 0;
                bdry.rho = 0;
                bdry.alpha = 0;
                bdry.beta = 0;
              case 'halfspace'
                vals = varargin{1};
                bdry.cp = vals.cp;
                bdry.cs = vals.cs;
                bdry.rho = vals.rho;
                bdry.alpha = vals.alpha;
                bdry.beta = vals.beta;
              otherwise
                error('Boundary type not recognized');
            end

        end
    end
    
    methods                             % getter/setter
        
        function field = get.field(bdry) % ???: does this get used
        % Return acoustic field profiles

            field.r = bdry.r;
            field.z = bdry.z;

            % Basement values are constant
            field.cp = bdry.cp*ones(size(field.z));
            field.cs = bdry.cs*ones(size(field.z));
            field.rho = bdry.rho*ones(size(field.z));
            field.alpha = bdry.alpha*ones(size(field.z));
            field.beta = bdry.beta*ones(size(field.z));
            
        end
        
    end



    
end
