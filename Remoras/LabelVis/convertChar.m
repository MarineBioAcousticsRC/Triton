%created by MAZ on 1/18/2021 to convert names that have slashes, spaces,
%etc into acceptable names for file naming/saving purposes. Used in
%lv_getIDfiles_fromExcelSheet

function outName = convertChar(inName)

tempName = inName;
%look for slashes
if contains(tempName,'\')
    pref = extractBefore(tempName,'\');
    suff = extractAfter(tempName,'\');
    tempName = [char(pref),'_',char(suff)];
end

if contains(tempName,'/')
    pref = extractBefore(tempName,'/');
    suff = extractAfter(tempName,'/');
    tempName = [char(pref),'_',char(suff)];
end

%look for spaces
if contains(tempName,' ')
    pref = extractBefore(tempName,' ');
    suff = extractAfter(tempName,' ');
    tempName = [char(pref),char(suff)];
end

%look for <, >
if contains(tempName,'<')
    pref = extractBefore(tempName,'<');
    suff = extractAfter(tempName,'<');
    tempName = [char(pref),'lessThan',char(suff)];
end

if contains(tempName,'>')
    pref = extractBefore(tempName,'>');
    suff = extractAfter(tempName,'>');
    tempName = [char(pref),'moreThan',char(suff)];
end

outName = tempName;

