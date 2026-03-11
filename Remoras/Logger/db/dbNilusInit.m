%Script to initialize Nilus

dbJavaPaths() %set up java dependencies
disp('Welcome to nilus')
%userpath prompt
if isempty(userpath())
    ask = true;
    while ask
        resp = input(['It looks like you''re missing a userpath.\n'...
            'Would you like to reset it?[Y/N]'],'s');
        if ~isempty(resp)
            ask=false;
            switch lower(resp)
                case 'y'
                    userpath('reset');
                    %set to new path,remove semicolon
                    newpath = userpath;
                    newpath = newpath(1:end-1);
                    cd(newpath);
                case 'n'
                    disp('OK, staying in current directory')
                otherwise
                    ask= true;
            end
        end
    end
end

%check for nilus on static path
static_path = javaclasspath('-static');
idx = strfind(static_path,'nilus.jar');
idx = idx(~cellfun('isempty',idx));

if isempty(idx)
    disp('Nilus not found on static path')
    %check for matlab version
    v = version('-release');
    disp(['MATLAB Release: ',v])
    minor = double(v(isstrprop(v,'alpha')));
    major = str2double(v(isstrprop(v,'digit')));
    b2012 = double('b')+2012;
    if major+minor >= b2012
        %check for javaclasspath.txt
        jvc_path = which('javaclasspath.txt');
        if isempty(jvc_path)
            disp(fprintf(['Cannot find javaclasspath.txt\n',...
                'Creating in directory:\n%s\n'],...
                fullfile(pwd)))
        end
        %open, create or append to javaclasspath.txt
        disp('Appending nilus.jar path to javaclasspath.txt')
        fid = fopen('javaclasspath.txt','a+');
        %create link to nilus.jar, should be on javapath
        nilus_path = which('nilus.jar');
        if isempty(nilus_path)
            disp('Error: Cannot find nilus.jar. Please add it manually to the Path and restart this script');
            return;
        end
        fprintf(fid,'\n%s\n',nilus_path);
        fclose(fid);
        %matlab sohuld now be restarted
        disp('Please restart MATLAB for the settings to take effect.')
        return;
    else
        %check for classpath.txt
        usrans = input(['Pre 2012b matlab Detected. ',...
            'Please confirm [Y/N]'],'s');
        if lower(usrans)=='y'
            cls_path = which('classpath.txt');
            fid = fopen(cls_path,'a+');
            nilus_path = which('nilus.jar');
			disp('Appending nilus.jar to classpath.txt');
            if isempty(nilus_path)
                disp('ERROR: Cannot find nilus.jar. Please add it manually to the Path and restart this script');
                return;
            end
            fprintf(fid,'\n######Tethys######\n');
            fprintf(fid,'%s\n',nilus_path);
            fprintf(fid,'######Tethys######\n');
            fclose(fid);
            %matlab sohuld now be restarted
            disp('Please restart MATLAB for the settings to take effect.')
            return;
        else
            disp('Error.')
            return;
        end
        
    end
else
    import tethys.nilus.*;
    detections=Detections();
    detections.marshal();
    clear idx;
    clear static_path;
    return;
end
