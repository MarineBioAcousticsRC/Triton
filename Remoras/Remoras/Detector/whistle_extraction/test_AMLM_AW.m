function results = test_AMLM_AW(experiment, foldinfo, corpus, components, tonallist, models, modality)
% test_AMLM(experiment, foldinfo, corpus, components, models)

% tonallist was added for ART_warp; this is a time/frequency matrix of the
% smoothed whistles from dtRootFit_frame
 
foldsN = size(foldinfo.fold, 1);

% preallocate results structure array
results = struct('htk', cell(foldsN, 1), 'julius', cell(foldsN, 1));

speciesN = length(corpus);
% ARToutput = struct('species',{corpus.species});

for f = 1:min(experiment.testonly, foldsN)
    if modality == 3 %if only evaluating data using pre-existing models
        foldinfo.labels{f} = 'TEST_DATA';
        folddir = fullfile(experiment.outdir, foldinfo.labels{f}); 
    else
        folddir = fullfile(experiment.outdir, foldinfo.labels{f});
    end
    
    if ~ exist(folddir, 'dir')
        mkdir(folddir);
    end
    
    handles = struct('htk', [], 'julius', []);
    
    % Files that will be opened and the field name used to reference them
    openlist = {
        'files', 'test_files.scp'  % List of test files
        'components', 'test_components.mlf'  % Component level ground truth 
        'species', 'test_species.mlf' % Species level ground truth
        };
    for idx=1:size(openlist, 1)
        [results(f).htk, handles.htk] = ...
            open_AMLM(results(f).htk, handles.htk, ...
            openlist{idx,1}, fullfile(folddir, openlist{idx,2}));
    end
     
    if experiment.multipass_decode
        % Set up to run species specific decoders
        results(f).species = struct('htk', cell(speciesN, 1), ...
            'julius', cell(speciesN, 1));
    end
    
    for s = 1:speciesN
        
        % Establish testing data
        % Use components associated with all sightings that 
        % are not in fold f.
        if modality == 3 %if only evaluating data
            test_groups = unique(corpus(1,s).subgroup);
        else
            test_groups = sort(foldinfo.fold{f,s});
        end
        
        if size(test_groups, 1) ~= 1
            test_groups = test_groups';  % ensure row vector
        end
        
        % Build component feature matrices for clustering
        % and a map from each component to the whistle to which
        % it belongs.
        [test.features, test.map] = ...
            concatFeats(corpus(s), components(s), test_groups);
        ARTfiles = unique(test.map(:,5));
        
        % Use pre-defined categories in ART_warp to cluster the whistles
        ARTout = ARTwarp_Test_Net(folddir,...
                        tonallist(s).tonals(ARTfiles),...
                        components(s).component_map(ARTfiles),...
                        corpus(s).species, modality);
                    
        ARToutput_test(s) = ARTout;
        indices = ARToutput_test(s).category(:);
        
%         if experiment.verbose
            plot_groups_AW(sprintf('test %s ', foldinfo.labels{f}), ...
                models(f).N{s}, indices, foldinfo.cfeatures, ...
                corpus(s), components(s), test, ARToutput_test(s).freq, test_groups);
%         end
        
        % We now have the information needed to write 
        % training labels, scripts, and component sequences
        WriteTestLabels(corpus(s), components(s), test.map, indices, ...
            handles);
    end % end for species
    
    fclose(handles.htk.files);  % close test script file
    % close master label files
    fclose(handles.htk.components);  % component labels MLF
    fclose(handles.htk.species);    % species labels MLF

    % Location where Julius transcript files will be produced
    results(f).julius.transcript_component = fullfile(folddir, ...
        'julius-component_trn.txt');  % components
    results(f).julius.transcript_species =fullfile(folddir, ...
            'julius-species_trn.txt');  % species level classification
    
    if experiment.multipass_decode
        decodes = cell(1, speciesN);
        for s = 1:speciesN
            % decode with single species models
            results(f) = decoder_AMLM(s, folddir, models(f), results(f));
            decodes{s} = results(f).species(s).julius.output;
        end
        
        % Merge results into a single transcription file
        mergefiles = sprintf('%s ', decodes{:});
        mergecmd = sprintf('julius2trn.py %s >%s', mergefiles, ...
                results(f).julius.transcript_component);
        result = system(mergecmd);
        if result
            error('Unable to merge component transcripts')
        end
        
        mergecmd = sprintf('julius2trn.py --metaclass %s >%s', mergefiles, ...
                results(f).julius.transcript_species);
        result = system(mergecmd);
        if result
            error('Unable to merge species transcripts')
        end
        
    else
        results(f) = decoder_AMLM(-1, folddir, models(f), results(f));
        
        % We score using score lite (sclite).
        % Both the test master label file and results must be transformed
        % to the trn "transcript" format.
        result = system(sprintf('julius2trn.py %s >%s', ...
            results(f).julius.output, results(f).julius.transcript));
        if result
            error('Unable to convert compnents to transcript format');
        end
        result = system(sprintf('julius2trn.py --metaclass %s >%s', ...
            results(f).julius.output, results(f).julius.transcript));
        if result
            error('Unable to convert species to transcript format');
        end

    end
    
    % Score on a component by component basis -------------------------
    results(f).htk.gttranscript_component = ...
        fullfile(folddir, 'test-groundtruth-components.trn');
    result = system(sprintf('mlf2trn.py %s >%s', ...
        results(f).htk.components, results(f).htk.gttranscript_component));
    if result
        error('Unable to convert component test master label files to transcript format');
    end
    
    % Score with scorelite
    results(f).scores_component = fullfile(folddir, 'results-component.txt');
    sclite = sprintf('sclite -f 0 -r %s -h %s -i rm -n %s -o spk', ...
        results(f).htk.gttranscript_component, ...
        results(f).julius.transcript_component, ...
        results(f).scores_component);
    result = system(sclite);
    if result
        error('Problem scoring test set');
    end
    
    
    % Score on a species basis -------------------------
    
    results(f).htk.gttranscript_species = ...
        fullfile(folddir, 'test-groundtruth-species.trn');
    result = system(sprintf('mlf2trn.py %s >%s', ...
        results(f).htk.species, results(f).htk.gttranscript_species));
    if result
        error('Unable to convert species test master label files to transcript format');
    end
    
    results(f).scores_species = fullfile(folddir, 'results-species.txt');
    sclite = sprintf('sclite -f 0 -r %s -h %s -i rm -n %s -o spk', ...
        results(f).htk.gttranscript_species, ...
        results(f).julius.transcript_species, ...
        results(f).scores_species);
    result = system(sclite);
    if result
        error('Problem scoring test set');
    end


end % for fold
1;

