function p = dt_interp_tf(p)

% If a transfer function is provided, interpolate to desired frequency bins

% Determine the frequencies for which we need the transfer function
p.xfr_f = (p.specRange(1)-1)*p.binWidth_Hz:p.binWidth_Hz:...
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
        if nargin > 1 && (length(f_desired) ~= length(f) || sum(f_desired ~= f))
            [~,uniqueIndex] = unique(f);
            if length(uniqueIndex)<length(f) 
                % check for duplicate frequencies remove if there are
                % duplicates, otherwise interpolation will fail
                warning('Duplicate frequencies detected in transfer function.')
                f = f(uniqueIndex);
                uppc = uppc(uniqueIndex);
            end
            % interpolate for frequencies user wants
            p.xfrOffset = interp1(f, uppc, f_desired, 'linear', 'extrap');
            p.xfr_f = f_desired;
        end
    else
        error('Unable to open transfer function %s',tf_fname);
    end
    
else
    % if you didn't provide a tf function, then just create a
    % vector of zeros of the right size.
    p.xfrOffset = zeros(size(p.xfr_f));
end