classdef AcousticEnvironment
% AcousticEnvironment class hasall info for Acoustic Toolbox runs
% 
% Environments consist of basic options, a surface layer, profiles for
% each media, a bottom layer, sources, and recievers. 
% 
% author: [Russell Shomberg](rshomberg@uri.edu)
% date: 

% TODO document all properties and options in detail
    
    properties
        % TODO validation
        % https://www.mathworks.com/help/matlab/matlab_oop/property-validator-functions.html
        
        name(1,:) char;                 % Name used for outputs

        % Environmental limits
        maxRange(1,1) double;          % Range of simulation field (m)
        maxDepth(1,1) double;          % Depth of simulation field (m)
        cHigh(1,1) double = 1800;       % Max soundspeed (m/s)
        cLow(1,1) double = 1400;        % Min soundspeed (m/s)
        
        % Layers
        surfaceBdry AcousticBoundary;   % Acoustic surface object
        layers(:,1) AcousticLayer;       % Acoustic layer object array
        bottomBdry AcousticBoundary;% Acoustic bottom object

        % Sources and recievers
        source AcousticSource;    % Acoustic source object
        reciever AcousticReciever;% Acoustic reciever object

        % Options
        attenuationUnits (1,:) char = 'dB/wavelengh'; % Attenuation units
                
    end

    properties (Dependent)
        
        file_base(1,:) char;            % TODO: write getter/setter
        Nmedia(1,1) int;                % TODO: write getter
        topOpts(1,6) char = '''    ''';  % TODO: write getter/setter
        botOpts(1,4) char = '''  ''';    % TODO: write getter/setter
        runTypeCode(1,3) char = ''' ''';    % TODO: write getter/setter
        freq(1,1) double;               % TODO: write getter/setter

    end

    methods(Access=public)

        function obj = AcousticEnvironment(name,maxDepth,maxRange, ...
                                           surfaceBdry,layers,bottomBdry)
            % AcousticEnvironment builds the acoustic environment.

            obj.name = name;
            obj.maxDepth = maxDepth;
            obj.maxRange = maxRange;
            obj.surfaceBdry = surfaceBdry;
            obj.layers = layers;
            obj.bottomBdry = bottomBdry;

            % TODO: define source and reviever later
            %obj.source = source;
            %obj.reciever = reciever;

        end
        
    end
    
    methods(Access=private)             
        
        % TODO: set to be static
        function write_boundary(boundary)
        % WRITE_BOUNDARY writes the boundary
            error('not implimented')
        end
        
        % TODO: set to be static
        function write_layer(layer,nmesh)
        % WRITE_LAYER writes the profile for a single media
            error('not implimented')
        end
        
        function opts = gen_top_options(obj)
        % GEN_TOP_OPTIONS creates the top option line

            opts = '    ';

            switch obj.layer(1).interpFunc
              case 'c-linear'
                opts(1) = 'C';
              case 'n2-linear'
                opts(1) = 'N';
              case 'cubic-spline'
                opts(1) = 'S';
              case 'analytic'
                opts(1) = 'A';
              otherwise
                error('Layer interp function not valid')
            end
            
            switch obj.boundary.type
              case 'vacuum'
                opts(2) = 'V';
              case 'halfspace'
                opts(2) = 'A';
              otherwise
                % TODO: add more options
                error('Boundary type not valid')
            end            
                
            switch obj.boundary.attenuationUnits
              case 'dB/wavelength'
                opts(3) = 'W';
              otherwise
                % TODO: add more options
                error('Boundary attenuation units not valid')
            end
            
            switch obj.robustRootFinder
              case true
                opts(4) = '.';
              case false
                opts(4) = ' ';
              otherwise
                error('Invalid value for root finder');
            end
            
        end
        
    end
    
    methods                             % getters/setters
        
    end

end

