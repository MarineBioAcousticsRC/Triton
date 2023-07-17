function epoch = date_epoch(name)
% Return the epoch date associated with an application
% Can be used for date conversion

switch name
    case 'excel'
        if ismac
            % Mac Excel uses different date (not tested)
            epoch = datenum('01-Jan-1904');
        else
            epoch = datenum('30-Dec-1899');
        end
        
    case 'triton'
        epoch = datenum([2000 0 0 0 0 0]);
        
    otherwise
        error('Unknown epoch name');
end