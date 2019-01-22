function dbJavaPaths
% Make sure Java classes on path

% We look for the Java classes in two possible directories:
% 1 - a 'client-java' sibling folder to this file's parent directory;Tethys
% 2 - a 'java' subdirectory of this file's parent directory;Triton

basedir = fileparts(fileparts(which(mfilename)));

dirs  = struct('name', {'client-java', 'java'}, ...
               'level', {-1, 0});  % depth relative to basedir

existing = javaclasspath('-dynamic');  % what's already there...
paths = {};   
for didx = 1:length(dirs)
    % Find path to dirs(didx).name
    pathto = basedir;
    for pidx = dirs(didx).level:1:-1
        pathto = fileparts(pathto);  % parent directory
    end
    jdir = fullfile(pathto, dirs(didx).name);
    


    if exist(jdir, 'dir')
        % directory exists, add it to path
        if ~onpath(jdir, existing)
            paths{end+1} = jdir;
        end
        
        % Include any direct subdirectories
        listing = dir(jdir);
        for lidx=1:length(listing)
            if listing(lidx).isdir
                switch listing(lidx).name
                    case {'.', '..'}
                        % ignore current & parent directories
                    otherwise
                        newpath = fullfile(jdir, listing(lidx).name);
                        if ~onpath(newpath, existing)
                            paths{end+1} = newpath;
                        end
                end
            end
        end
        
        % Handle special cases
        switch dirs(didx).name
            case 'client-java'
                % There may be a bin subdirectory that needs to be
                % added to the path
                targets = fullfile(jdir, 'classes');
                if exist(targets) && ~onpath(targets, existing)
                    paths{end+1} = targets;
                end
            case 'java'
                % Matlab installation
                targets = fullfile(jdir, 'TethysJavaClient', 'classes');
                if exist(targets) && ~onpath(targets, existing)
                    paths{end+1} = targets;
                end                
        end
        
        % Add any java archive files in this direcory as they
        % must appear directly on the path
        javajars = dbFindFiles({'*.jar'}, {jdir}, true);
        if ~ isempty(javajars)
            remove = false(length(javajars), 1);
            for jidx=1:length(javajars)
                remove(jidx) = onpath(javajars{jidx}, existing);
            end
            javajars(remove) = [];
            %add dependency path to normal path
            nilus_idx = ~cellfun(@isempty, ...
                regexp(javajars, '.*nilus.jar'));
            if any(nilus_idx)
                nilus_path = javajars{nilus_idx};
                dependency_path=fileparts(nilus_path);
                addpath(dependency_path);
                %remove nilus.jar from paths to be added to dynamic
                javajars(~cellfun(@isempty, ...
                    regexp(javajars, '.*nilus.jar'))) = [];
            end
            paths(end+1:end+length(javajars)) = javajars;
        end
    end
end


if ~ isempty(paths)
    %global variables get cleared with javaaddpaths
    %need to first store them in temp variable,
    %and then reassign
    %get names
    globs = who('global')';
    if ~isempty(globs)
        glob_str = sprintf('global %s;',strjoin(globs));

        %pull them
        eval(glob_str)
        %put them into a struct
        for gidx = 1:numel(globs)
            g_name = globs{gidx};
            assign_str = sprintf('globals.%s = %s;',g_name,g_name);
            eval(assign_str)
        end
    end
    
    javaaddpath(paths);
    
    if ~isempty(globs)
        %they're cleared, recreate
        eval(glob_str)

        %reassign from the struct
        for gidx = 1:numel(globs)
            g_name = globs{gidx};
            reassign_str = sprintf('%s = globals.%s;',g_name,g_name);
            eval(reassign_str)
        end
    end
end

function boolean = onpath(name, path)
% Checks if name is a component of the path
% Looks for exact comparisons, will fail when mutliple path names
% resolve to the same file or directory.
boolean = sum(strcmp(name, path)) > 0;