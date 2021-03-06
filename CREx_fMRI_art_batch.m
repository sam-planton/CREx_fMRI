function CREx_fMRI_art_batch(normEPI, subName, outputDir)
    % Modified version of ART_BATCH - https://www.nitrc.org/projects/artifact_detect/
    % Modification : Batch processing of one subject from normalised EPI files (4D)
    % Create the config file 'art_config.cfg' and use ART_BATCH 
    % Author: Valérie Chanoine, Research Engineer at Brain and Language
    % Research Institute (http://www.blri.fr/)
    % Co-authors : Samuel Planton 
    % Date: October 10, 2016

    % IN INPUT
    % normEPI : [1 x nSession cell] list of normalised EPI files (4D)
    % subName : [1 x n char]subject's name
    % outputDir : [1 x n char] output path
   
    
    %%================ Default ART parametres =============================

    ART.global_mean=1;                % global mean type (1: Standard 2: User-defined Mask)
    ART.motion_file_type=0;           % motion file type (0: SPM .txt file 1: FSL .par file 2:Siemens .txt file)
    ART.global_threshold=9.0;         % threshold for outlier detection based on global signal
    ART.motion_threshold=2.0;         % threshold for outlier detection based on motion estimates
    ART.use_diff_motion=1;            % 1: uses scan-to-scan motion to determine outliers; 0: uses absolute motion
    ART.use_diff_global=1;            % 1: uses scan-to-scan global signal change to determine outliers; 0: uses absolute global signal values
    ART.use_norms=1;                  % 1: uses composite motion measure (largest voxel movement) to determine outliers; 0: uses raw motion measures (translation/rotation parameters) 
    ART.mask_file=[];                 % set to user-defined mask file(s) for global signal estimation (if ART.global_mean is set to 2) 

    %%================== Create a config file =============================
    % Get the number of sessions
    nSessions = numel(normEPI);
    
    % Define the config file
    cfgfile = fullfile(outputDir, [subName '_art_config.cfg']);
        
	% Open it and write ART comments and parameters 
    fid=fopen(cfgfile,'wt');
     
    % Comments
    fprintf(fid,'# Automatic script generated by %s\n',mfilename);
    fprintf(fid,'# Users can edit this file and use\n');
    fprintf(fid,'#   art(''sess_file'',''%s'');\n',cfgfile);
    fprintf(fid,'# to launch art using this configuration\n');
        
    % Parameters 
    fprintf(fid,'sessions: %d\n', nSessions);
    fprintf(fid,'global_mean: %d\n', ART.global_mean);
    fprintf(fid,'global_threshold: %f\n', ART.global_threshold);
    fprintf(fid,'motion_threshold: %f\n', ART.motion_threshold);
    fprintf(fid,'motion_file_type: %d\n', ART.motion_file_type);
    fprintf(fid,'motion_fname_from_image_fname: 1\n');
    fprintf(fid,'use_diff_motion: %d\n', ART.use_diff_motion);
    fprintf(fid,'use_diff_global: %d\n', ART.use_diff_global);
    fprintf(fid,'use_norms: %d\n', ART.use_norms);
    fprintf(fid,'output_dir: %s\n', outputDir);        
    if ~isempty(ART.mask_file),fprintf(fid,'mask_file: %s\n',deblank(ART.mask_file(1,:)));end
    fprintf(fid,'end\n');
        
    for iSess=1:nSessions,
        fprintf(fid,'session %d image %s\n',iSess, normEPI{iSess});
    end
    fprintf(fid,'end\n');
    
    % Close config file
    fclose(fid);

    %%================== Use ART function  ================================
    % Use ART function to get 'regression' outliers   
    disp(['running subject using config file ',cfgfile]);
    art('sess_file',cfgfile);
    
    % Define a name for the figure
    set(gcf,'name',['subject #',subName]);
    
    %% Save the figure in 2 formats
    saveas(gcf, fullfile(outputDir, [subName '_art_config']), 'fig');
    saveas(gcf, fullfile(outputDir, [subName '_art_config']), 'png');
    %%
end
