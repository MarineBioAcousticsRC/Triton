function models = train_AMLM_AW(experiment, foldinfo, corpus, components, tonallist, modality)
% train(experiment, foldinfo, corpus, components)
% Train acoustic and language models for each of the folds
%
% Components for each species are clustered using a K-means algorithm
%
% Acoustic models for each cluster are represented by HMMs trained
% using HTK
%
% Language models are trained with SRI's language modeling tool

% tonallist was added for ART_warp; this is a time/frequency matrix of the
% smoothed whistles from dtRootFit_frame

import java.util.LinkedList

foldsN = size(foldinfo.fold, 1);
models = struct('htk', cell(foldsN, 1), 'N', cell(foldsN, 1));

config = experiment.config;

for f = 1:min(experiment.testonly, foldsN)
    if modality == 2 % if only training data, no folds
        foldinfo.labels{f} = 'TRAIN_DATA';
        folddir = fullfile(experiment.outdir, foldinfo.labels{f}); 
    else
        folddir = fullfile(experiment.outdir, foldinfo.labels{f});
    end
   
    if ~ exist(folddir, 'dir')
        mkdir(folddir);
    end

    handles = struct('htk', [], 'julius', [], 'species', []);
    
    % Files that will be opened and the field name used to reference them
    openlist = {
        'files', 'train_files.scp'  % List of training files
        'components', 'train_components.mlf'  % Component level ground truth 
        'species', 'train_species.mlf' % Species level ground truth
        'dictionary', 'Dict-HTK.txt' % Mapping of components to models (1-1)
        'decoderdict', 'Dict-Julius.txt'  % As above + sil
        'modellist', 'modellist-HTK.txt'  % Complete list of models for this fold
        'decodermodellist', 'modelllist-Julius.txt'  % As above + sil 
        };
    for idx=1:size(openlist, 1)
        [models(f).htk, handles.htk] = ...
            open_AMLM(models(f).htk, handles.htk, ...
            openlist{idx,1}, fullfile(folddir, openlist{idx,2}));
    end
    
    
    speciesN = length(corpus);
    
    for s = 1:length(corpus)
        % Species specific files that will be opened and the 
        % field name used to reference them
        handles.species = struct();
        handles.species.htk = struct();
        species = struct('name', corpus(s).species, 'htk', []);
        % Species specific language model training text
        [species, handles.species] = ...
            open_AMLM(species, handles.species, 'lmtrain', ...
                fullfile(folddir, ...
                    sprintf('lm-train-%s.txt', species.name)));
        % Files containing dictionary and models for species specific
        % decodes
        s_openlist = {
            'decoderdict', 'Dict-Julius-%s.txt'  % species specific dict &
            'decodermodellist', 'modelllist-Julius-%s.txt' % model list
            };
        for idx=1:size(s_openlist, 1)
            [species.htk, handles.species.htk] = ...
                open_AMLM(species.htk, handles.species.htk, ...
                    s_openlist{idx,1}, ...
                    fullfile(folddir, ...
                        sprintf(s_openlist{idx,2}, species.name)));
        end
        
        % Establish training data
        % Use components associated with all sightings that 
        % are not in fold f.
        if modality == 2
            train_groups = foldinfo.permutations{s};
        else
            train_groups = setdiff(foldinfo.permutations{s}, ...
                foldinfo.fold{f,s});
        end
        
        train_groups = sort(train_groups);
        
        if size(train_groups, 1) ~= 1
            train_groups = train_groups';  % ensure row vector
        end
        
        [train.features, train.map] = ...
            concatFeats(corpus(s), components(s), train_groups); 
        ARTfiles = unique(train.map(:,5));
        
        % Call Artwarp, giving it a list of the species files to train on
        
        % hardcoded - this may vary, will need to be optimized at some point.
        vigilance = 85;
        ARTout = ARTwarp_liz(vigilance, tonallist(s).tonals(ARTfiles), ...
            components(s).component_map(ARTfiles), corpus(s).species, folddir);

        ARToutput_train(1,s) = ARTout;
        indices = ARToutput_train(s).category(:);
        models(f).N{s} = max(indices);
      
        % Cluster the components
        dur_idx = 3;  % used for duration dependent state numbering
        
        for p_idx=1:models(f).N{s}
            % Write model dictionaries
            component_name = sprintf('%s_c%02d', corpus(s).species, p_idx);
            fprintf(handles.htk.dictionary, '%s %s\n', component_name, component_name);
            fprintf(handles.htk.decoderdict, '%s %s\n',component_name, component_name);
            fprintf(handles.species.htk.decoderdict, '%s %s\n',component_name, component_name);
            % Write model lists
            if experiment.states == 0
                % Base number of states on a statistic of duration
                states_per_s = experiment.states_per_s;
                this_model = indices == p_idx;
                duration = mean(train.features(this_model, dur_idx));
                % Add two non emitting states for HTK entry/exit + duration
                % minimum of 3 emitting states
                states = 2+max(3, ceil(duration * states_per_s));
                % Make sure that the number of states never exceeds the 
                % number of observations as HTK will fail.
                obsN = train.map(this_model, 4) - train.map(this_model, 3)+1;
                count = sum(obsN < states-2);
                if count > 0
                    mincount = min(obsN);
                    fprintf('%s: %d instances with length < %d: states=%d\n', ...
                        component_name, count, states-2, mincount+2);
                    states = mincount + 2;
                end
                fprintf(handles.htk.modellist, '%s  states %d\n', component_name, states);
            else
                fprintf(handles.htk.modellist, '%s\n', component_name);
            end
            fprintf(handles.htk.decodermodellist, '%s\n', component_name);
            fprintf(handles.species.htk.decodermodellist, '%s\n', component_name);            
        end

%         if experiment.verbose
            plot_groups_AW(sprintf('train %s', foldinfo.labels{f}), ...
                models(f).N{s}, indices, foldinfo.cfeatures, ...
                corpus(s), components(s), train, ARToutput_train(s).freq, train_groups);
            
%         end
        
        fprintf('Generating class specific labels and language models\n')
        % We now have the information needed to write 
        % training labels, scripts, and component sequences
        WriteLabels(corpus(s), components(s), train.map, indices, handles);
        
        % Add silence model required by decoder
        fprintf(handles.species.htk.decodermodellist, 'sil\n');
        % Map start and end of sentence to silence in dictionary
        fprintf(handles.species.htk.decoderdict, '<s> sil\n</s> sil\n');
        
        fclose(handles.species.lmtrain);
        fclose(handles.species.htk.decoderdict);
        fclose(handles.species.htk.decodermodellist);
        
        Ngram = experiment.ngram;   % Ngram order
        % Train forward language model
        species.ngram = fullfile(folddir, ...
            sprintf('lm-ngram-%s.txt', corpus(s).species));
        species.counts = fullfile(folddir, ...
            sprintf('lm-counts-%s.txt', corpus(s).species));
   
        result = system(...
            sprintf('ngram-count -order %d -text %s -write %s -unk -lm %s -wbdiscount2 -wbdiscount3', ...
            Ngram, species.lmtrain, species.counts, species.ngram));
        if result
            error('Unable to train %s', species.lmtrain);
        end

        % Reverse the text for a backward language model
        result = system(sprintf('reverse.py %s', species.lmtrain));
        if result
            error('Unable to reverse %s', species.train);
        end
        % reverse.py will have produced the following file:
        species.lmtrainRev = fullfile(folddir, ....
            sprintf('lm-train-%s.txt_rev', corpus(s).species));

        species.ngramRev = fullfile(folddir, ...
            sprintf('lm-ngram_rev-%s.txt', corpus(s).species));
            
        species.countsRev = fullfile(folddir, ...
            sprintf('lm-counts_rev-%s.txt', corpus(s).species));
        
        % Train the backward language model
        result = system(...
            sprintf('ngram-count -order %d -text %s -write %s -unk -lm %s -wbdiscount2 -wbdiscount3', ...
            Ngram, species.lmtrainRev, species.countsRev, species.ngramRev));
        if result
            error('Unable to train %s', species.lmtrainRev);
        end
        
        models(f).species(s) = species;

    end  % end for species
    
    fclose(handles.htk.files);   % list of training files
    fclose(handles.htk.components);  % component master label file
    fclose(handles.htk.species); % species master label file
    fclose(handles.htk.dictionary);    % dictionary 
    
    % Map start and end of sentence to silence in dictionary
    fprintf(handles.htk.decoderdict, '<s> sil\n</s> sil\n');
    fclose(handles.htk.decoderdict);
    
    % Add silence model required by decoder
    fclose(handles.htk.modellist);
    fprintf(handles.htk.decodermodellist, 'sil\n');
    fclose(handles.htk.decodermodellist);
    
    
    %create equally balanced language model for all species
    models(f).ngram= fullfile(folddir,sprintf('lm-ngram.txt'));
    models(f).ngramRev = fullfile(folddir,sprintf('lm-ngram-rev.txt'));
    
    weights = ones(1, speciesN) / speciesN;
    language_models = {'ngram', 'ngramRev'};
    lmcmd = cell(2,1);  % language model merge commands
    for lm_idx = 1:2  % forwards & backwards models
        lm = language_models{lm_idx};
        lmcmd{lm_idx} = sprintf('-lm %s -lambda %f ', ...
            models(f).species(s).(lm), weights(1));
        if speciesN > 1
            % weight of second model is derived from 1 - all other
            % weights and is not specified explicitly.
            lmcmd{lm_idx} = sprintf('%s -mix-lm %s ', ...
                lmcmd{lm_idx}, models(f).species(2).(lm));
            for m=3:speciesN
                lmcmd{lm_idx} = sprintf(...
                    '%s -mix-lm%d %s -mix-lambda%d %f ', ...
                    lmcmd{lm_idx}, m, models(f).species(m).(lm), m, weights(m));
            end
        end
        lmcmd{lm_idx} = sprintf('ngram %s -unk -write-lm %s', ...
            lmcmd{lm_idx}, models(f).(language_models{lm_idx}));
        
        fprintf('Merging species specific %s...\n', language_models{lm_idx});
        [result, output] = system(lmcmd{lm_idx});
        if result
            error('Unable to merge %s:\n%s\n', ...
                language_models{lm_idx}, output);
        end
    end
    
    % Train acoustic models for all species
    % TODO?  Make the number of states depend upon average duration
    % per component?  If so, store the average duration inside the
    % for species loop
    
    models(f).htk.hmmdir = fullfile(folddir, 'hmm');
    if ~ exist(models(f).htk.hmmdir, 'dir')
        mkdir(models(f).htk.hmmdir);
    end
   
    fprintf('Training acoustic models with HTK\n');
    htkcmd = sprintf(['train_hmm.py dictionary=%s config=%s isolated=0 ', ...
        'classes=%s states=%d mixtures=%d mlf=%s train=%s outdir=%s ' ...
        'segmented=True'], ...
        models(f).htk.dictionary, config, models(f).htk.modellist, ...
        experiment.states, experiment.mixtures, ...
        models(f).htk.components, models(f).htk.files, ...
        models(f).htk.hmmdir);
        %models(f).htk.compfiles, models(f).htk.compmlf);
    [result, errtxt] = system(htkcmd);
    if result
        sprintf('%s\n', errtxt);
        error('Problem training HMM models');
    end
    
    % Append silence model to HTK models
    models(f).htk.hmm = fullfile(...
        sprintf('%s/model_defs.mmf',models(f).htk.hmmdir));
    
    if false
        hmmH = fopen(fullfile(models(f).htk.hmmdir, 'model_defs.mmf'), 'a');
        if hmmH == -1
            error('HMM master macro file (models_def) cannot be opened for appending');
        end
        % The Julius decoder requires a silence model to be present even
        % if we do not need one.  Copy in a dummy silence model
        % that we assume is in the same directory as this function
        dir = fileparts(mfilename);  % location of this file
        silH = fopen(fullfile(dir,'dummy_sil.mmf'), 'r');
        if silH == -1
            error('Unable to open silence model for copying')
        end
        temp = fread(silH);  % read and append
        fwrite(hmmH, temp);
        
        fclose(hmmH);
        fclose(silH);
    end
    
end  % end for fold

  
1;