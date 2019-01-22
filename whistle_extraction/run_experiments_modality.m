function experiment = run_experiments_modality(indir,featdir,outdir,varargin)
tic
%function experiment = run_experiments(experimentsN, foldsN, states, 
%       mixtures, corpus, components, tonallist, method, indir, featdir, outdir)
% [models, results] = run_experiments(experimentsN, foldsN, ...
%     states, mixtures, corpus, components, method, featdir, outdir)
% Conduct N experiments where each experiment is conducted
% as an N-fold test.  corpus is a structure array that
% describes each species, and components is a corresponding
% structure array that shows how calls are broken down into components
% for training purposes.
% 
% Inputs:
% experimentsN - Number of trials
% foldsN - Number of folds used for N-fold testing
% states - Number of states per HMM
% mixtures - Number of mixtures per HMM state
% corpus - Information about the files in the corpus
% components - Information about components and feature files
% method - Extension used when searching for tonal annotations.
% featdir - feature parameter directory
% outdir - Base output directory for results

if nargin < 3
    outdir = [];
    if nargin < 2
        featdir = [];
        if nargin < 1
            indir = [];
        end
    end
elseif nargin == 3
    gui = true;
elseif nargin > 3 
    %if the user doesn't want to open a gui but wants to input values
    %directly
    gui = false;
    k = 1;
    while k <= length(varargin)
        switch varargin{k}
            case 'corpus'
                corpus = varargin{k+1};
                k = k+2;
            case 'min_length'
                min_s = varargin{k+1};
                k = k+2;
            case 'experimentsN'
                experimentsN = varargin{k+1};
                k = k+2;
            case 'foldsN'
                foldsN = varargin{k+1};
                k = k+2;
            case 'states'
                states = varargin{k+1};
                k = k+2;
            case 'mixtures'
                mixtures = varargin{k+1};
                k = k+2;
        end
    end  
end

if isempty(indir)
    indir = uigetdir(pwd, 'Whistle data directory');
    if isnumeric(indir)
        error('Must specify whistle data directory');
    end
end
if isempty(featdir)
    featdir = uigetdir(pwd, 'Feature directory');
    if isnumeric(featdir)
        error('Must specify feature directory');
    end
end
if isempty(outdir)
    outdir = uigetdir(pwd, 'Output directory');
    if isnumeric(outdir)
        error('Must specify output directory');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get user input of file type, species, and detection method
if gui
    
    % First determine the training and evaluation scheme the user wants to implement 
    %create GUI figure window to select scheme
    [modality,ok] = listdlg('ListString',...
        {'Experiment/Fold method',...
        'Training data only','Evaluation only'},...
        'SelectionMode','single',...
        'PromptString','Please select a method: ',...
        'Name','Whistle Evaluation Method');

    % set initial default values 
    corpus = fullfile(featdir,'corpus.mat');
    method = 'det';
    min_s = '0.1';
    experimentsN = '1';
    foldsN = '2';
    states = '0';
    mixtures = '4';
    evaldir = indir;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%a second dialogue box depending on which modality was chosen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if the multiple experiment/fold method is chosen:
if modality == 1;
    % user input dialog box
    prompt={'Enter corpus.mat file to use  : ',...
            'Enter detection method : ',...
            'Enter minimum whistle length : ',...
            'Enter number of experiments to run : ',...
            'Enter number of folds per experiment : ',...
            'Enter number of states per HMM (if 0 state number varies by species) : ',...
            'Enter number of mixtures per HMM : '};
    def={char(corpus),char(method),char(min_s),char(experimentsN),...
        char(foldsN),char(states),char(mixtures)};

    dlgTitle=['Enter input values for run_experiments'];
    lineNo=1;
    AddOpts.Resize='on';
    AddOpts.WindowStyle='normal';
    AddOpts.Interpreter='tex';
    in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    if length(in) == 0	% if cancel button pushed
        return
    end


    % corpus matrix
    corpus = char(deal(in{1}));

    % Method of detection
    method = char(deal(in{2}));

    %Minimum whistle length
    min_s = deal(str2num(in{3}));

    % Number of experiments and folds
    experimentsN = deal(str2num(in{4}));
    foldsN = deal(str2num(in{5}));

    %Number of states and mixtures
    states = deal(str2num(in{6}));
    mixtures = deal(str2num(in{7}));

    load(corpus);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %if the user only wants to evaluate a single dataset as a whole and
    %then save the results
elseif modality == 2;
    
% user input dialog box
    prompt={'Enter corpus.mat file to use  : ',...
            'Enter detection method : ',...
            'Enter minimum whistle length : ',...
            'Enter number of states per HMM (if 0 state number varies by species) : ',...
            'Enter number of mixtures per HMM : '};
    def={char(corpus),char(method),char(min_s),...
        char(states),char(mixtures)};

    dlgTitle=['Enter input values for run_experiments_train'];
    lineNo=1;
    AddOpts.Resize='on';
    AddOpts.WindowStyle='normal';
    AddOpts.Interpreter='tex';
    in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
    if length(in) == 0	% if cancel button pushed
        return
    end

    % corpus matrix
    corpus = char(deal(in{1}));

    % Method of detection
    method = char(deal(in{2}));

    %Minimum whistle length
    min_s = deal(str2num(in{3}));

    % Number of experiments and folds
%         experimentsN = deal(str2num(in{4}));
%         foldsN = deal(str2num(in{5}));

    %Number of states and mixtures
    states = deal(str2num(in{4}));
    mixtures = deal(str2num(in{5}));

    load(corpus);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % if the user wants to evaluate a new dataset using a preexisting trained
    % dataset
elseif modality == 3;
        
        %default trained data location
        experiment = fullfile(outdir,'experiment.mat');
        % user input dialog box
        prompt={'Enter method to use  : ',...
                'Enter minimum whistle length : ',... 
                'Enter experiment.mat file to use : ',...
                'Enter evaluation file directory : '};
        def={char(method),char(min_s),char(experiment),char(evaldir)};

        dlgTitle=['Enter input values for evaluate_whistles'];
        lineNo=1;
        AddOpts.Resize='on';
        AddOpts.WindowStyle='normal';
        AddOpts.Interpreter='tex';
        in=inputdlg(prompt,dlgTitle,lineNo,def,AddOpts);
        if length(in) == 0	% if cancel button pushed
            return
        end
        
        if isempty(evaldir)
            evaldir = uigetdir(pwd, 'Evaluation data directory');
            if isnumeric(evaldir)
                error('Must specify evaluation data directory');
            end
        end

        % Method of detection
        method = char(deal(in{1}));

        %Minimum whistle length
        min_s = deal(str2num(in{2}));
        % experiment matrix
        experiment = char(deal(in{3}));
        load(experiment);
        
        % Evaluation directory (if different than indir)
        evaldir = char(deal(in{4}));
        
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if modality == 1 || modality == 2
    
    experiment.method = method;
    experiment.featuresdir = featdir;
    experiment.outdir = outdir;
    experiment.states = states;
    experiment.mixtures = mixtures;
    experiment.ngram = 2;  % language model order
    experiment.states_per_s = 10;
    experiment.verbose = false;
    experiment.multipass_decode = true;
    experiment.testonly = inf;  % Test 1st m of N folds only (use Inf for all)

    if ~ exist(experiment.outdir, 'dir')
        mkdir(experiment.outdir);
    end

    % Write the configuration file (more efficient to do outside of experiment
    % loop)
    experiment.delta = 1;  % delta features  0=none 1=velocity 2=velocity/accel
    switch(experiment.delta)
        case 0
            deltastr = '';
        case 1  
            deltastr = '_D';
        case 2  
            deltastr = '_D_A';
        otherwise
            error('Bad delta feature value')
    end

    experiment.config = fullfile(experiment.outdir, 'config.txt');
    configH = fopen(experiment.config, 'w');
    if configH == -1
        error('Unable to write %s', config);
    end
    fwrite(configH, sprintf(['# Feature paramters\n', ...
        'SOURCEKIND = USER_D_A\n', ...
        'TARGETKIND = USER%s\n', ...
        'WINDOWSIZE = 80000.0\n', ...
        'NUMCEPS = 1\n', ...
        'ENORMALISE = F\n'], deltastr));
    fclose(configH);
end

if modality == 1 % Running multiple experiments/folds

    for e_idx = 1:experimentsN
        % Assign folds for this experiment
        foldinfo = constructFolds(foldsN, corpus);
        for f=1:foldsN
            % experiment/fold
            foldinfo.labels{f} = ...
                sprintf('E%02dF%d', e_idx, f);
        end

        % Secify the features that will be used to cluster components
        % 1:uslope, 2:bandwidth, 3:duration 4:5 start/end freq 6 slope
        % 7:10 Legendre polynomial coefficients
        foldinfo.cfeatures = [8:10];  % clustering features

        experiment.foldinfo(e_idx) = foldinfo;
    
        % train_AMLM_AW and test_AMLM_AW utilize ART_warp to create the
        % whistle categories, whereas train_AMLM and test_AMLM utilize
        % vqDistortion. Once the "best" method is chosen thse can be
        % consolidated to reduce code redundancy
        models = train_AMLM_AW(experiment, ...
            experiment.foldinfo(e_idx), corpus, components, tonallist, modality);
    %     models = train_AMLM(experiment, ...
    %         experiment.foldinfo(e_idx), corpus, components);
        results = test_AMLM_AW(experiment, ...
            experiment.foldinfo(e_idx), corpus, components, tonallist, models, modality);
%         results = test_AMLM_AW(experiment, ...
%             experiment.foldinfo(e_idx), corpus, components, models, modality);

        if e_idx == 1
            % first experiment establishes structure
            experiment.models = models;
            experiment.results = results;
            experiment.verbose = false;  % don't overload user w/plots
        else
            % extend structure arrays
            experiment.models(:,end+1) = models;
            experiment.results(:,end+1) = results;
        end
        save(fullfile(experiment.outdir, 'experiment.mat'), 'experiment');
    end

elseif modality == 2 % just training data, no testing
    
    for s_idx = 1:length(corpus)
        foldinfo.fold{s_idx} = 1;
        foldinfo.permutations{s_idx} = unique(corpus(1,s_idx).subgroup);
    end   
    
    foldinfo.cfeatures = [8:10];  % clustering features - same options as above
    
    experiment.foldinfo = foldinfo;
    
    models = train_AMLM_AW(experiment, ...
            experiment.foldinfo, corpus, components, tonallist, modality);

    experiment.models = models;
%     experiment.results = results;
    experiment.verbose = false;  % don't overload user w/plots

    save(fullfile(experiment.outdir, 'experiment.mat'), 'experiment');
    
elseif modality == 3 %just evaluating data, using pre-trained models
    
    % Run prepare_corpus for the evaluation dataset
    [corpus, components, tonallist] = prepare_corpus(method, evaldir, featdir, min_s);

    % preallocate results structure array
    results = struct('htk', cell(1, 1), 'julius', cell(1, 1));
    
    for s_idx = 1:length(corpus)
        foldinfo.fold{s_idx} = 1;
        foldinfo.permutations{s_idx} = unique(corpus(1,s_idx).subgroup);
    end   
    foldinfo.cfeatures = [8:10];  % clustering features - same options as above
    experiment.foldinfo = foldinfo;
    
    results = test_AMLM_AW(experiment, ...
        experiment.foldinfo, corpus, components, tonallist, experiment.models, modality);
        
    experiment.results = results;
    experiment.verbose = false;

    save(fullfile(experiment.outdir, 'experiment.mat'), 'experiment');
end


% -------------------------------------------------------------------
function foldinfo = constructFolds(foldsN, corpus)
% foldinfo = constructFold(foldsN, corpus)
% Randomly assign subgroups to each fold on a per class basis
fold_size = zeros(length(corpus), 1);
% foldinfo.permutations{1} = unique(corpus(1).subgroup);
% foldinfo.permutations{2} = unique(corpus(2).subgroup);
% foldinfo.permutations{3} = unique(corpus(3).subgroup);
% foldinfo.permutations{4} = unique(corpus(4).subgroup);
% foldinfo.fold{1,1} = 1;
% foldinfo.fold{1,2} = 1;
% foldinfo.fold{1,3} = 1;
% foldinfo.fold{1,4} = 1;
% foldinfo.fold{2,1} = 1;
% foldinfo.fold{2,2} = 1;
% foldinfo.fold{2,3} = 1;
% foldinfo.fold{2,4} = 1;

for s_idx = 1:length(corpus)
    % Randomly order the subgroups associated with this species.
    % Then use a deterministic algorithm to assign the permuted
    % set to folds.
    subgroups = unique(corpus(s_idx).subgroup);
    foldinfo.permutations{s_idx} = subgroups(randperm(length(subgroups)));
    
    fold_size(s_idx) = floor(length(subgroups) / foldsN);
    % How many folds will get one extra group?
    leftover = mod(length(subgroups), foldsN);
    
    for f = 1:foldsN
        % Assign f'th set of subgroups to this fold
        first = (f-1)*fold_size(s_idx)+1;
        last = min(f*fold_size(s_idx), length(subgroups));
        foldinfo.fold{f,s_idx} = ...
            foldinfo.permutations{s_idx}(first:last);
        if leftover
            % Add one of the reamaining groups to each fold
            % until there are not any left.
            foldinfo.fold{f,s_idx}(end+1) = ...
                foldinfo.permutations{s_idx}(end-leftover+1);
            leftover = leftover - 1;
        end
    end
end

toc