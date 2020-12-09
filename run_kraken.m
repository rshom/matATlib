function res = run_kraken(env,src,rcv)
% run_kraken returns results from running the KRAKEN model.
% 
% run_kraken writes the KRAKEN input files, rusn the FORTRAN binary,
% and reads the output files into a useable result.
% 
% See https://oalib-acoustics.org/AcousticsToolbox/manual/node47.html
% for more information.

    % Prepare files
    write_envfil(env,src,rcv);
    % TODO: write other files if needed
    write_flpfil(env,src,rcv);
    
    % Run acoustic toolbox
    model = 'kraken.exe';
    runmodel = which( model );

    if ( isempty( runmodel ) )
        error( '%s not found in your Matlab path', model );
    else
        eval( [ '! "' runmodel '" ' env.fileBase ] );
    end
    
    field(env.fileBase);                % from AT may need to rewrite
    
    plotshd([env.fileBase '.shd.mat']);
    
    % Read results
    % modes = read_modefile([env.fileBase '.mod']);
    [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure ] = read_shd([env.fileBase '.shd.mat']);

    % Clean up files

end

function write_envfil(env,src,rcv)
% Write acoustic toolbox env file for kraken
    
    envfil = fopen([env.fileBase '.env'],'w');
    
    fprintf(envfil,'%s \t ! TITLE \n',env.name);
    fprintf(envfil,'%0.6f \t ! FREQ (Hz) \n',src.freq); 
    fprintf(envfil,'%d \t ! NMEDIA \n',length(env.layers));

    fprintf(envfil,'''%s'' \t ! SSP Options \n', env.topOpts);
    
    for lyr=env.layers
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

    bdry = env.bottomBdry;
    switch bdry.type
      case 'vacuum'
        botOpts(1) = 'V';
        fprintf(envfil,'''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                botOpts,bdry.sigma);
        % Vacuum only has one lines
      case 'halfspace'
        botOpts(1) = 'A';
        fprintf(envfil, ...
                '''%s''\t%0.6f\t ! BOTOPTS BOTROUGHNESS \n', ...
                botOpts,bdry.sigma);
        fprintf(envfil, ...
                '\t %0.6f %0.6f %0.6f %0.6f / \t ! Z CP CS RHO \n', ...
                bdry.z(1), bdry.cp(1), bdry.cs(1), bdry.rho(1)/1000);
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
    fprintf(envfil,'%d \n \t ',1001);
    fprintf(envfil,'0 %0.6f',max(rcv.z));
    fprintf(envfil, '/ \t ! NSD RD(1:NRD) \n');
    fprintf(envfil,'\n');

    fclose(envfil);
    
end


function write_flpfil(env,src,rcv)
% Write the field parameters file.
% 
% TODO: document
% TODO: add options

flpfil = fopen([env.fileBase '.flp'],'w');

    fprintf(flpfil,'''%s'' \t ! TITLE \n',env.name);

    fprintf(flpfil,'''RA'' \t ! R/X (coord), Pos/Neg/Both \n' ); % TODO: add options
    fprintf(flpfil,'%d \t ! NModes \n', 9999);% TODO: add options
    fprintf(flpfil,'%d \t ! NProfile \n', 1);% TODO: add options
    fprintf(flpfil,'%d \t ! RProfile (km) \n', 0);% TODO: add options    

    % Reciever range information
    % fprintf(flpfil,'%d \n \t ',max(length(rcv.z),length(rcv.r)));
    fprintf(flpfil,'%d \t ! NRR \n',1000);
    fprintf(flpfil,'%0.6f %0.6f',0,env.maxRange/1000);
    fprintf(flpfil, '/ ! RR(1:NRR) (km)  \n');

    % Source information
    fprintf(flpfil,'%d \t ! NSD \n',length(src.z));
    fprintf(flpfil,'%0.6f ',src.z);
    fprintf(flpfil, '\t /! SD(1:NSD) \n');
    
    % Reciever depth information
    % fprintf(flpfil,'%d \n \t ',max(length(rcv.z),length(rcv.r)));
    fprintf(flpfil,'%d \t ! NSD \n',501);
    % fprintf(flpfil,'%0.6f %0.6f',min(rcv.z),max(rcv.z));
    fprintf(flpfil,'%0.6f %0.6f',0,env.layers(1).z(end));
    fprintf(flpfil, '\t /! SD(1:NSD) \n');

    % ???: reciever range displacement
    fprintf(flpfil,'%d \t ! NRRD \n', 501); 
    fprintf(flpfil,'0 0 \t ! RRD(1:NRRD) \n');

    fprintf(flpfil,'\n');
    
    fclose(flpfil);

end