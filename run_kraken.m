function [shade,modes] = run_kraken(env,src,rcv,modes)
% run_kraken returns results from running the KRAKEN model.
% 
% run_kraken writes the KRAKEN input files, runs the FORTRAN binary,
% and reads the output files into a useable result. See
% https://oalib-acoustics.org/AcousticsToolbox/manual/node47.html for
% more information.

% Prepare files
    write_envfil(env,src,rcv);

    write_flpfil(env,src,rcv);          
    % TODO: write other files if needed
    % brcfil = fopen([fileBase+'.brc'], 'w');
    % trcfil = fopen([fileBase+'.trc'], 'w');
    % ircfil = fopen([fileBase+'.irc'], 'w');    
    
    if length(env.lyrs(1).r)>1          % Range dependent SSP
        error('Range dependent SSP not yet supported');
    end
    
    if length(env.flr.r)>1              % Range dependent depth
        error('Range dependent depth not yet supported');
    end
    
    % Run acoustic toolbox
    model = 'kraken.exe';
    runmodel = which( model );

    if ( isempty( runmodel ) )
        error( '%s not found in your Matlab path', model );
    else
        eval( [ '! "' runmodel '" ' env.fileBase ] );
    end
    
    field(env.fileBase, modes);                % from AT may need to rewrite
    
    % read results
    % TODO: rewrite read files

    modes = read_modes([env.fileBase '.mod'], src.freq, modes);
    [ ~, ~, shade.freqVec,~,~, shade.pos, shade.p ] = read_shd([env.fileBase '.shd.mat']);
    shade.TL = -20*log10(abs(shade.p));

    % Clean up files

end

function write_envfil(env,src,rcv)
% Write acoustic toolbox env file for kraken
    
    envfil = fopen([env.fileBase '.env'],'w');
    
    fprintf(envfil,'%s \t ! TITLE \n',env.name);
    fprintf(envfil,'%0.6f \t ! FREQ (Hz) \n',src.freq); 
    fprintf(envfil,'%d \t ! NMEDIA \n',length(env.lyrs));

    fprintf(envfil,'''%s'' \t ! SSP Options \n', env.topOpts);
    
    for lyr=env.lyrs'
        fprintf(envfil, ...
                '%d %0.6f %0.6f \t ! NMESH SIGMA ZMAX \n',...
                0, lyr.sigma, lyr.z(end));
        for idx =1:length(lyr.z)        % TODO: better than loop
            fprintf(envfil, ...
                    '\t%0.6f %0.6f %0.6f %0.6f /\t! Z CP CS RHO \n', ...
                    lyr.z(idx,1), lyr.cp(idx,1), lyr.cs(idx,1), lyr.rho(idx,1));
        end
    end
    % fprintf(enfil,'\n');                % ???
    
    botOpts = '  ';                    % Placeholder
    botOpts(2) = ' ';                  % Kraken cannot be range dependent

    switch env.flr.type
      case 'vacuum'
        botOpts(1) = 'V';
        fprintf(envfil,'''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                botOpts,env.flr.sigma);
        % Vacuum only has one lines
      case 'halfspace'
        botOpts(1) = 'A';
        fprintf(envfil, ...
                '''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                botOpts,env.flr.sigma);
        fprintf(envfil, ...
                '\t %0.6f %0.6f %0.6f %0.6f / \t ! Z CP CS RHO \n', ...
                env.flr.z(1), env.flr.cp(1), env.flr.cs(1), env.flr.rho(1)/1000);
      otherwise
        error('Bottom boundary type not implemented');
    end

    % TODO: Kraken options
    fprintf(envfil,'%0.6f %0.6f \t ! CLOW CHIGH (m/s)\n', env.cLow,env.cHigh);
    fprintf(envfil,'%0.6f \t ! RMAX (km) \n',env.maxRange/1000);
    
    % Source information
    fprintf(envfil,'%d \n \t ',length(src.z));
    fprintf(envfil,'%0.6f ',src.z);
    fprintf(envfil, '\t ! NSD SD(1:NSD) \n');
    
    % Reciever information
    % fprintf(envfil,'%d \n \t ',length(rcv.z));
    fprintf(envfil,'%d \n \t ',length(rcv.z));
    fprintf(envfil,'%0.6f ',rcv.z);
    % fprintf(envfil,'0 %0.6f',max(rcv.z));
    fprintf(envfil, '/ \t ! NRD RD(1:NRD) \n');
    fprintf(envfil,'\n');

    fclose(envfil);
    
end


function write_flpfil(env,src,rcv)
% Write the field parameters file.
% 
% TODO: document
% TODO: add options

    flpfil = fopen([env.fileBase '.flp'],'w');

    fprintf(flpfil,'/ \t ! TITLE \n',env.name);

    fprintf(flpfil,'''RA'' \t ! R/X (coord), Pos/Neg/Both \n' ); % TODO: add options
    fprintf(flpfil,'%d \t ! NModes \n', 9999);% TODO: add options
    fprintf(flpfil,'%d \t ! NProfile \n', 1);% TODO: add options
    fprintf(flpfil,'%d \t ! RProfile (km) \n', 0);% TODO: add options    

    % Reciever range information
    fprintf(flpfil,'%d \n',length(rcv.r));
    fprintf(flpfil,'%0.6f ',rcv.r);
    fprintf(flpfil, '! RR(1:NRR) (km)  \n');

    % Source information
    fprintf(flpfil,'%d \n',length(src.z));
    fprintf(flpfil,'%0.6f ',src.z);
    fprintf(flpfil, '\t ! SD(1:NSD) \n');
    
    % Reciever depth information
    fprintf(flpfil,'%d \n',length(rcv.z));
    fprintf(flpfil,'%0.6f ',rcv.z);
    fprintf(flpfil, '\t ! RD(1:NRD) \n');
    % fprintf(flpfil,'%0.6f %0.6f',0,env.lyrs(1).z(end));

    % ???: reciever range displacement
    fprintf(flpfil,'%d \n', 501); 
    fprintf(flpfil,'1 0 / \t ! RRD(1:NRRD) \n');

    fprintf(flpfil,'\n');
    
    fclose(flpfil);

end