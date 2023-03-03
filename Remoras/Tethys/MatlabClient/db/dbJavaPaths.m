function dbJavaPaths
% Make sure Java classes on path

% We look for the Java classes in two possible directories:
% 1 - a 'JavaClient' sibling folder relative to the root of the 
%     Matlab client.
% 2 - a 'java' subdirectory of this file's parent directory (used in
%     Triton distribution)

basedir = fileparts(fileparts(which(mfilename)));

dirs  = struct('name', {'JavaClient', 'NilusXMLGenerator'}, ...
               'level', {-1, -1});  % depth relative to basedir

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
        % directory exists, see if it has classes/dependency subdirectories
        
        allinjars = true;
        if ~ allinjars
            classes = dbFindFiles('Path', jdir, 'Pattern', 'classes', ...
                'Type', 'dir', 'PathMode', 'file');
            if ~onpath(classes, existing)
                paths{end+1} = classes;
            end            
        end
        
        jars = dbFindFiles('Path', jdir, 'Pattern', '*.jar', ...
            'PathMode', 'file');
        % Some jars are should not be included on some systems
        jars = filterJars(jars);
        
        if ~ isempty(jars)
            paths = vertcat(paths{:}, jars);
        end       
    end
end


if ~ isempty(paths)
    
    % Filter out any of the paths that are already on the global class
    % path
    existing = javaclasspath('-all');
    for pidx=length(paths):-1:1
        % Check if paths{pidx} already on path
        if sum(~cellfun(@isempty, strfind(existing, paths{pidx}))) > 0
            paths(pidx) = [];  % no need to add
        end
    end
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
    
    % Handle TethysJavaClient first
    % It supports a class that lets us manipulate the static class path
    re_tjc = 'TethysJavaClient-\d+\.\d+\.jar';  % regexp to match
    % Already on path?
    need_tjc = find(~cellfun(@isempty, regexp(existing, re_tjc)));
    if isempty(need_tjc)
        % Not on path, see if it's in the list to add
        tjc_at_idx = find(~cellfun(@isempty, regexp(paths, re_tjc)));
        if isempty(tjc_at_idx)
            error('Unable to find TethysJavaClient jar file');
        elseif length(tjc_at_idx) ~= 1
            error('Multiple versions of TethysJavaClient jar, not sure which to load');        
        else
            % Found it, add it to the Java path
            javaaddpath(paths{tjc_at_idx});
            paths(tjc_at_idx) = [];
            % We now have the library and can hack the rest in.
            dbHackpath(paths);
        end
    end
    
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



function jars = filterJars(jars)

jre = version('-java');
if startsWith(jre, 'Java 1.7')
    % Java runtime 1.7 has several packages included that were removed
    % in Java 1.8.  The jars we include for these packages were compiled
    % with 1.8, so they are removed from the path.
    removals = [
        '(' 'javax\.ws\.rs-api', '|' 'jaxb-api', '|', ...
        'jaxb-core', 'jaxb-impl', '|', ...
        'activation', '|', 'jersey-common', ')'];
    for idx=length(jars):-1:1
        m = regexp(jars{idx}, removals);
        if ~ isempty(m)
            jars(idx) = [];
        end
    end
end

function boolean = onpath(name, path)
% boolean = onpath(name, path)
% Checks if name is a component of the path
% Looks for exact comparisons, will fail when mutliple path names
% resolve to the same file or directory.
boolean = sum(strcmp(name, path)) > 0;
 