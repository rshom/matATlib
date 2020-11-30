function res = run_bellhop(env,opts)
% run_bellhop returns results from running the BELLHOP model.
%   
% run_bellhop writes the BELLHOP input files, runs the FORTRAN
% binary, and reads the output files into a useable result. 
% 
% TODO: include information about bellhop.
    
    
    % Prepare files
    write_envfil(env,opts);
    % TODO: write other files if needed
    % brcfil = fopen([fbase+'.brc'], 'w');
    % trcfil = fopen([fbase+'.trc'], 'w');
    % ircfil = fopen([fbase+'.irc'], 'w');    
    
    % Run acoustic toolbox
    model = 'bellhop.exe';
    runmodel = which( model );

    if ( isempty( runmodel ) )
        error( '%s not found in your Matlab path', model );
    else
        eval( [ '! "' runmodel '" ' fbase ] );
    end
    
    % Read results
    rays = read_rayfile([env.fbase '.ray']) % TODO
    % TODO: read other results if necessary
    
    % TODO: Clean up files
    

end
    

function write_envfil(env, opts.runType)
% Write acoustic toolbox env file for bellhop
    
    switch lower(opts.runType)
      case 'ray'
        runCode = 'R';
      case 'coherant'
        runCode = 'C';
      case 'incoherant'
        runCode = 'I';
      case 'semicoherant'
        runCode = 'S';
      otherwise
        error('Run type (%s) not valid',opts.runType);
    end

    envfil = fopen([env.fbase+'.env'], 'w');

    fprintf(envfil,'%s \t ! TITLE \n',env.title);
    fprintf(envfil,'%0.6f \t ! Dummy Var \n',0); % FREQ not used
    fprintf(envfil,'%d \t ! Dummy Var \n',1);  % NMEDIA not used
    fprintf(envfil,'''%s'' \t ! SSP Options \n', env.topOpts);
    fprintf(envfil,'%s \n', env.layer(1).envString);% TODO
    fprintf(envfil,'%s \n', env.bottomBdry.envString);% TODO
    fprintf(envfil,'%s \n', env.source.depthString);% TODO
    fprintf(envfil,'%s \n', env.reciever.depthString);% TODO
    fprintf(envfil,'%s \n', env.reciever.rangeString);% TODO
    fprintf(envfil,'''%s'' \t ! Run-type \n', runCode);
    fprintf(envfil,'%s \n', env.source.beamString); % TODO
    
    fclose(envfil)
end

