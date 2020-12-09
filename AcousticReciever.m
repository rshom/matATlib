classdef AcousticReciever
% AcousticReciever array for an AcousticEnvironment.
% 
% Recievers can be point recievers, line arrays, or mesh arrays. Array
% elements must be evenly spaced in range and evenly spaced in depth.
    
    properties
        % TODO: add propery descriptions somehow
        r(1,:) double
        z(:,1) double
    end
    
    properties(Dependent)
        N(1,1) int16;
        depthString(1,:) char;
        rangeString(1,:) char;
    end
    
    methods(Access=public)
        function obj = AcousticReciever(r,z);
        % Define array acoustic recievers.
            obj.r = r;
            obj.z = z;
        end
    end
    
    methods
        % function value = get.N(obj)
        % % N number of recievers
        %     value = length(obj.r)*length(obj.z);
        % end
        
        % function value = get.depthString(obj)
        % % Getter for depth string for env file
            
        %     value = sprintf('%d \t %0.6f \ \t ! NSD SD(1:NSD) (m) \n', ...
        %                     length(obj.z), obj.z);            

        % end

        % function value = get.rangeString(obj)
        % % Getter for range string for env file
            
        %     value = sprintf('%d \t %0.6f \ \t ! NRD RD(1:NRD) (m) \n', ...
        %                     length(obj.r), obj.r);

        % end

    end

end
