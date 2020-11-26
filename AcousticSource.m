classdef AcousticSource
% AcousticSource array for an AcousticEnvironment.

    properties
        z(:,1) double;                  % Depth array in meters
    end
    
    properties(Dependent)
        N(1,1) int16;
    end
    
    methods(Access=public)
        function obj = AcousticSource(z);
        % Construct AcousticSouce array.
            obj.z = z;
        end
    end
    
    methods
        function value = get.N(obj)
        % N number of sources
            value = length(obj.z);
        end
    end
    

end
