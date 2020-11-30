classdef AcousticLayer
% AcousticLayer definition for AcousticEnvironment.
% 
% A layer can either be the water column or a bottom layer. 
% TODO document
    
    properties
        
        % Options
        interpFunc (1,:) char = 'linear';
        Nmesh(1,1) double = 0.0;        % 0 to auto calculate

        % Properties
        sigma (1,1) double = 0.0;       % Surface roughness
        z (:,1) double;                 % Profile depths
        r (1,:) double;                 % Profile ranges
        cp double;                      % Pressure wave speed
        cs double;                      % Shear wave speed
        rho double;                     % Density
        alpha double;                   % Pressure wave attenuation
        beta double;                    % Shear wave attenuation
        
        upperLimit(1,:) double;             % Range dependent surface
        lowerLimit(1,:) double;             % Range dependent depth
    end
    
    properties (Dependent)
        field double;                   % Acoustic field
    end        

    methods(Access=public)
        function obj = AcousticLayer(depth,cp,cs,rho,alpha,beta,...
                                     range,upperLimit,lowerLimit)
        % AcousticLayer constructs a simple acoustic layer profile.
            
            obj.z = depth;
            obj.r = range;
            obj.cp = cp;
            
            % TODO: Define remaining values
            obj.cs = cs;
            obj.rho = rho;
            obj.alpha = alpha;
            obj.beta = beta;
            
            obj.upperLimit = upperLimit;
            obj.lowerLimit = lowerLimit;
            
        end

    
    end
    
    methods                             % getter/setter
        function field = get.field(obj)
        % Return acoustic field of profiles
            
            [field.r,field.z] = meshgrid(obj.r,obj.z);
            field.r = field.r';
            idx = and(field.z<=obj.lowerLimit,field.z>=obj.upperLimit);
            
            function x = build_field(x,idx)
            % Convert parameter to full field
                if size(x)==size(idx)
                    x(~idx) = NaN;
                elseif size(x)==[size(idx,1) 1]
                    x = repmat(x,1,size(idx,2))
                elseif size(x)==[1 1];
                    x = ones(size(idx)).*x.*idx;
                else
                    error('Profile incorrect size')
                end
                x(~idx) = NaN;
            end

            field.cp = build_field(obj.cp,idx);
            field.cs = build_field(obj.cs,idx);
            field.rho = build_field(obj.rho,idx);
            field.alpha = build_field(obj.alpha,idx);
            field.beta = build_field(obj.beta,idx);
            
        end
        
    end        
    

end
