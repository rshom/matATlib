function res = run_bellhop(env,src,rcv,runType)
% run_bellhop returns results from running the BELLHOP model.
%   
% run_bellhop writes the BELLHOP input files, runs the FORTRAN
% binary, and reads the output files into a useable result. 
% 
% TODO: include information about bellhop in this documentation
    
    % Prepare files
    write_envfil(env,src,rcv,runType);

    if length(env.lyrs(1).r)>1          % Range dependent SSP
        % write_sspfil(env)        
        error('Range dependent SSP not yet supported'); % TODO
    end
    
    if length(env.flr.r)>1              % Range dependent depth
        % write_btyfil(env)
        error('Range dependent depth not yet supported'); % TODO
    end
    
    % Run acoustic toolbox
    model = 'bellhop.exe';
    runmodel = which( model );

    if ( isempty( runmodel ) )
        error( '%s not found in your Matlab path', model );
    else
        eval( [ '! "' runmodel '" ' env.fileBase ] );
    end

    % Read results
    switch runType
      case 'ray'
        res = read_rayfile([env.fileBase '.ray']); % TODO: rewrite function
      case 'eigen'
        res = read_rayfile([env.fileBase '.ray']); % TODO: rewrite function
      % case 'coherent'
      %   shd = read_shdfil([env.fileBase '.shd.mat']);
      % case 'incoherent'
      %   shd = read_shdfil([env.fileBase '.shd.mat']);
      % case 'semicoherent'
      %   shd = read_shdfil([env.fileBase '.shd.mat']);
      otherwise
        error('Runtype not impimented'); % TODO
    end

    % TODO: Clean up files

end
    

function write_envfil(env, src, rcv, runType)
% Write acoustic toolbox env file for bellhop
    
    switch lower(runType)
      case 'ray'
        runCode = 'R';
      case 'eigen'
        runCode = 'E';
      case 'coherant'
        runCode = 'C';
      case 'incoherant'
        runCode = 'I';
      case 'semicoherant'
        runCode = 'S';
      otherwise
        error('Run type (%s) not valid',runType);
    end

    envfil = fopen([env.fileBase '.env'], 'w');

    fprintf(envfil,'''%s'' \t ! TITLE \n',env.name);
    fprintf(envfil,'%0.6f \t ! Dummy Var \n',src.freq);% FREQ not used
    fprintf(envfil,'%d \t ! Dummy Var \n',1);% NMEDIA not used
    fprintf(envfil,'''%s'' \t ! SSP Options \n', env.topOpts);
    
    lyr = env.lyrs(1);                % bellhop only uses the first layer
    fprintf(envfil, ...
            '%d %0.6f %0.6f \t ! NMESH SIGMA ZMAX \n',...
            0, lyr.sigma, lyr.z(end));
    for idx =1:length(lyr.z)        % TODO: better than loop
        fprintf(envfil, ...
                '\t%0.6f %0.6f %0.6f %0.6f /\t! Z CP CS RHO \n', ...
                lyr.z(idx,1), lyr.cp(idx,1), lyr.cs(idx,1), lyr.rho(idx,1));
    end

    botOpts = '  ';
    if length(env.lyrs)>1
        % if multiple layers, second layer becomes an acoustic halfspace
        botOpts(1) = 'A';
        fprintf(envfil, ...
                '''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                botOpts,env.flr.sigma);
        fprintf(envfil, ...
                '\t %0.6f %0.6f %0.6f %0.6f / \t ! Z CP CS RHO \n', ...
                env.flr.z(1,1), env.flr.cp(1,1), env.flr.cs(1,1), env.flr.rho(1,1)/1000);
    else
        switch env.flr.type
          case 'vacuum'
            botOpts(1) = 'V';
            fprintf(envfil,'''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                    botOpts,env.flr.sigma);
            % Vacuum only has one lines
          case 'halfspace'
            botOpts(1) = 'A';
            fprintf(envfil, ...
                    '''%s'' \t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                    botOpts,env.flr.sigma);
            fprintf(envfil, ...
                    '\t %0.6f %0.6f %0.6f %0.6f / \t ! Z CP CS RHO \n', ...
                    env.flr.z(1), env.flr.cp(1), env.flr.cs(1), env.flr.rho(1)/1000);
          otherwise
            error('Bottom boundary type not implemented');
    end
        
    end
    % Source information
    fprintf(envfil,'%d \n',length(src.z));
    fprintf(envfil,'%0.6f ',src.z);
    fprintf(envfil, '/ \t ! NSD SD(1:NSD) \n');
    
    % Reciever Depths
    fprintf(envfil,'%d \n', length(rcv.z) );
    fprintf(envfil,'%0.6f %0.6f ', min(rcv.z), max(rcv.z));
    fprintf(envfil, '/ \t ! NRD RD(1:NRD) \n' );

    % Reciever Ranges
    fprintf(envfil,'%d \n',length(rcv.r));
    fprintf(envfil,'%0.6f %0.6f ',min(rcv.r),max(rcv.r));
    fprintf(envfil, '/ \t ! NRR RR(1:NRR) \n');

    % Bellhop Options
    fprintf(envfil,'''%s'' \t ! Run-type ''R/C/I/S'' \n', runCode);
    fprintf(envfil,'%d \n',length(src.alpha));
    fprintf(envfil,'%0.6f %0.6f ',min(src.alpha), max(src.alpha));
    fprintf(envfil, '/ \t ! NBEAMS ALPHA(1:NBEAMS) (degrees) \n');

    % Mesh
    fprintf(envfil,'%0.6f %0.6f %0.6f \t ! STEP (m) ZBOX (m) RBOX (km)', ...
            0,env.maxDepth,env.maxRange/1000.0);
    
    fclose(envfil);
end

function rays = read_rayfile(fname)
    % Read data from ray file

    fid = fopen( fname, 'r' );   % open the file
    if ( fid == -1 )
        disp( fname );
        error( 'No ray file exists; you must run BELLHOP first (with ray ouput selected)' );
    end
    
    % read header stuff
    TITLE       = fgetl(  fid );
    FREQ        = fscanf( fid, '%f', 1 );
    Nsxyz       = fscanf( fid, '%f', 3 );
    NBeamAngles = fscanf( fid, '%i', 2 );
    
    DEPTHT      = fscanf( fid, '%f', 1 );
    DEPTHB      = fscanf( fid, '%f', 1 );
    
    Type        = fgetl( fid );
    Type        = fgetl( fid );
    
    Nsx    = Nsxyz( 1 );
    Nsy    = Nsxyz( 2 );
    Nsz    = Nsxyz( 3 );
    
    Nalpha = NBeamAngles( 1 );
    Nbeta  = NBeamAngles( 2 );
    
    % Extract letters between the quotes
    nchars = strfind( TITLE, '''' );   % find quotes
    TITLE  = [ TITLE( nchars( 1 ) + 1 : nchars( 2 ) - 1 ) blanks( 7 - ( nchars( 2 ) - nchars( 1 ) ) ) ];
    TITLE  = deblank( TITLE );  % remove whitespace
    
    nchars = strfind( Type, '''' );   % find quotes
    Type   = Type( nchars( 1 ) + 1 : nchars( 2 ) - 1 );
    %Type  = deblank( Type );  % remove whitespace
    
    rays = [ ];
    for isz = 1 : Nsz
        source = [ ];
        for ibeam = 1 : Nalpha
            alpha0    = fscanf( fid, '%f', 1 );
            nsteps    = fscanf( fid, '%i', 1 );
            
            NumTopBnc = fscanf( fid, '%i', 1 );
            NumBotBnc = fscanf( fid, '%i', 1 );
            if isempty( nsteps ); break; end
            switch Type
              case 'rz'
                ray = fscanf( fid, '%f', [2 nsteps] );
                
                beam.r = ray( 1, : );
                beam.z = ray( 2, : );
              case 'xyz'
                ray = fscanf( fid, '%f', [3 nsteps] );
                
                beam.xs = ray( 1, 1 );
                beam.ys = ray( 2, 1 );
                beam.r = sqrt( ( ray( 1, : ) - xs ).^2 + ( ray( 2, : ) - ys ).^2 );
                beam.z = ray( 3, : );
            end
            source = [source beam];
        end	% next beam
        rays = [rays; source];
    end % next source depth
    
end

