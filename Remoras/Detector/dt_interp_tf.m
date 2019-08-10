function p = dt_interp_tf(p)

% Given a path to a transfer function file open it and 
% interpollate to curve to match desired frequency vector.

% Determine the frequencies for which we need the transfer function
f_desired = (p.specRange(1)-1)*p.binWidth_Hz:p.binWidth_Hz:...
    (p.specRange(end)-1)*p.binWidth_Hz;
if ~isempty(p.tfFullFile)

    fid = fopen(p.tfFullFile,'r');
    if fid ~=-1
        % read in transfer function file
        [A,~] = fscanf(fid,'%f %f',[2,inf]);
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
            
            p.tf = interp1(f, uppc, f_desired, 'linear', 'extrap');
            p.tf_freq = f_desired;
            p.tf_uppc = uppc;
        end
    else
        msg = sprintf('Unable to open transfer function %s',tf_fname);
        error(msg);
    end
else
    % if you didn't provide a tf function, then just create a
    % vector of zeros of the right size.
    p.tf = zeros(size(p.xfr_f));
end