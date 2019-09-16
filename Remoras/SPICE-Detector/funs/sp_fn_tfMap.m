function [f, uppc] = sp_fn_tfMap(tf_fname,f_desired)
% [f, uppc] = dtf_map(tf_fname, f_desired)
% transfer function map

% Given a path to a transfer function file open it and 
% interpollate to curve to match desired frequency vector.

% Based tfmap.m in Triton, Version 1.64.20070709 

fid = fopen(tf_fname,'r');
if fid ~=-1
    % read in transfer function file
    [A,count] = fscanf(fid,'%f %f',[2,inf]);
    f = A(1,:);
    uppc = A(2,:);    % [dB re uPa(rms)^2/counts^2]
    fclose(fid);
    
    % If user wants response for different frequencies than those
    % in the transfer function, use linear interpolation.
    if nargin > 1 && ...
            (length(f_desired) ~= length(f) || sum(f_desired ~= f))
        [~,uniqueIndex] = unique(f);
        if length(uniqueIndex)<length(f) % check for duplicate frequencies
            % remove if there are duplicates, otherwise interpolation will
            % fail
            warning('Duplicate frequencies detected in transfer function.')
            f = f(uniqueIndex);
            uppc = uppc(uniqueIndex);
        end 
        % interpolate for frequencies user wants

        uppc = interp1(f, uppc, f_desired, 'linear', 'extrap');
        f = f_desired;
    end
else
    msg = sprintf('Unable to open transfer function %s',tf_fname);
    error(msg);
end

