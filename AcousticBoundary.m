classdef AcousticBoundary
% AcousticBoundary
    
    properties
        % Options

        type (1,:) char = 'vacuum';
        attenuationUnits (1,:) char = 'dB/wavelengh';
        

        % Properties
        
        cp(1,1) double = NaN;           % Pressure wave speed (m/s)
        cs(1,1) double = NaN;           % Shear wave speed (m/s)
        rho(1,1) double = NaN;          % Density (kg/m3)
        
        alpha(1,1) double = NaN;        % Pressure wave attenuation
        beta(1,1) double = NaN;         % Shear wave attenuation
        
        %sigma(1,1) double = NaN;

        % Range Dependence        

        depth(1,:) double;
        interpFunc (1,:) char = 'linear';
    end
    
    methods(Access=public)
        function obj = AcousticBoundary(depth);
        % Construct simple vacuum boundary at a depth

            obj.depth = depth;
            
        end
    end
    
    
end
