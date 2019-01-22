function styles = datepatterns()
% This function returns a Nx2 cell array where the first column
% is the name of a particular style of timestamp.
% The second column is the regular expression that can be used
% to extract time information from a string containing a timestamp
% in the corresponding style.

styles = {
    'DCMMLPA 2009', '(?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._- ](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)_[^c]|(?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._- ](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)_cut_(?<dmin>\d\d)(?<ds>\d\d)'
    'DCMMLPA 2007', '(?<mon>\d\d)(?<day>\d\d)(?<yr>\d\d)-(H\d+-)?.*-(?<hr>\d\d)(?<min>\d\d)-\d\d\d\dloc.*_(?<dmin>\d\d)(?<ds>\d\d)'
    'Fostek', '.*B(?<hr>\d+)h(?<min>\d+)m(?<s>\d+)s(?<day>\d+)(?<mon>[a-zA-Z]+)(?<yr>\d+)y.*'
    '(YY)YYMMDD[-. ]HHMMSS', ...
    '(?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._- ](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)'
    'Palmyra', '(\d\d)((\d\d)?\d\d)[^-]*-(?<yr>\d\d)(?<mon>\d\d)(?<day>\d\d)-(?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)'
    'Raven', 'raven[\._](?<yr>(\d\d)?\d\d)(?<mon>\d\d)(?<day>\d\d)[\._- ](?<hr>\d\d)(?<min>\d\d)(?<s>\d\d)'
    'Common Formats', ''
    };

for k=[3 4 6]
    styles{end, 2} = [styles{end,2}, styles{k,2}, '|'];
end
styles{end,2} = [styles{end, 2}, styles{end-1,2}];
    
