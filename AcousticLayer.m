classdef AcousticLayer
% AcousticLayer definition for AcousticEnvironment.
% 
% A layer can either be the water column or a bottom layer. 
% TODO document
    
    properties
        
        % Options
        name(1,:) char = '';            % Layer name
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
        envString char;                 % TODO:
    end        

    methods(Access=public)
        function obj = AcousticLayer(depth,range,cp,cs,rho,alpha,beta,...
                                     upperLimit,lowerLimit)
        % AcousticLayer constructs a simple acoustic layer profile.

        % TODO: error check
        
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

        function val = get.envString(obj)
        % envString 
            
            val = '';
            val = [val sprintf('0\t0.0\t%0.6\t/\t \n',obj.z(end))];
            if length(obj.cp)==1
                val = [val sprintf('%0.6f\t%0.6f\t/\t\n', obj.z(1), obj.cp)];
                val = [val sprintf('%0.6f\t%0.6f\t/\t\n', obj.z(end), obj.cp)];
            else
                for idx=1:length(obj.z)
                    val = [val sprintf('%0.6f\t%0.6f\t/\t\n', obj.z(idx), obj.cp(idx))];
                end
            end
            

        end


        function field = get.field(obj)
        % Return acoustic field of profiles
            
            [field.r,field.z] = meshgrid(obj.r,obj.z);
            
            idx = and(field.z<=obj.lowerLimit,field.z>=obj.upperLimit);
            
            function x = build_field(x,idx)
            % Convert parameter to full field
                
                [m,n]=size(idx);
                
                if size(x)==[1 1];      % constant
                    x = ones(size(idx)).*x;
                elseif size(x)==[1 n]   % range dependent
                    x = repmat(x,m,n);
                elseif size(x)==[m 1]   % depth dependent
                    x = repmat(x,1,n);
                elseif size(x)==[m,n]   % full field
                    x = x;
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
