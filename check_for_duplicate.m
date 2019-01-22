 function newfilename = check_for_duplicate(outfile, outpath)
% Check if the output file name matches any of the current file names in
% the directory and then prompt for a rename, overwrite, or automatic
% rename

y=0;
thedir = dir(outpath);

newfilename = outfile;
%get the length of the directory to figure out how far to count in
for y = 1:length(dir)
    if ( (strcmp(outfile, thedir(y).name)) == 1)
        newname = questdlg('Name of File?', 'Name of File', ...
            'Rename', 'Overwrite', 'Automatically Name', 'Automatically Name');
        switch newname
            case 'Rename'
                newfilename = char(inputdlg ('Rename the file'));
                %for files that are the same name, Autoname just adds a (A)
                %before the .x.wav part, and if there already is an (A),
                %then another 'A' is added in between the parenthesis
            case 'Automatically Name'
                for a = 1:length(thedir(y).name)
                    if thedir(y).name(a) == '('
                        thedir(y).name = strrep(thedir(y).name, ').x.wav', 'A).x.wav');
                        newfilename = thedir(y).name;
                        break;
                    else if thedir(y).name(a) == '.'
                            thedir(y).name = strrep(thedir(y).name,'.x.wav', '(A).x.wav');
                            newfilename = thedir(y).name;
                            break;
                        end
                    end
                end
        end
    end
end
