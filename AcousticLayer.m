classdef AcousticLayer
% AcousticLayer definition for AcousticEnvironment.
% 
% A layer can either be the water column or a bottom layer. 
    
    properties
        
        % Options
        interpFunc (1,:) char = 'linear';
        Nmesh(1,1) double = 0.0;
        
        % Properties
        sigma (1,1) double = 0.0;
        z (:,1) double;
        cp (:,1) double;
        cs (:,1) double;
        rho (:,1) double;
        alpha (:,1) double;
        beta (:,1) double;
        
        depth (1,1) double;
    end

    methods(Access=public)
        function obj = AcousticLayer(z,cp);
        % AcousticLayer constructs a simple acoustic layer profile.
            
            obj.z = z;
            obj.cp = cp;
            
            % Define remaining values
            obj.cs = zeros(size(z));
            obj.rho = zeros(size(z));
            obj.alpha = zeros(size(z));
            obj.beta = zeros(size(z));
            
            obj.depth = max(z);
            
        end
    end

end
