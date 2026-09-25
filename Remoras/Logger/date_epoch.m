function epoch = date_epoch(name)
% Return the epoch date associated with an application
% Can be used for date conversion

switch name
    case 'excel'
        % Excel for Mac 2011 and later default to the same 1900 date
        % system as Windows; the 1904 system was the old Mac default.
        epoch = datenum('30-Dec-1899');
        
    case 'triton'
        epoch = datenum([2000 0 0 0 0 0]);
        
    otherwise
        error('Unknown epoch name');
end