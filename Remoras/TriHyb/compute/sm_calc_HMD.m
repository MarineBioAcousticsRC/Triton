function sm_calc_HMD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VMZ 6/25/2025 (copied parts from SoundScape Remora)
%
% calculate minutely spectral averages for daily files (called by mypst_compute)
%
%


global PARAMS

%% Spectra Computation Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fStart = PARAMS.metadata.startF;
fStop = PARAMS.metadata.endF;
PARAMS.ltsa.dfreq = 1;
PARAMS.ltsa.fs = double(PARAMS.ltsahd.sample_rate(1));
rmFifo = PARAMS.metadata.rmvFifo;


if ~all(PARAMS.ltsahd.sample_rate == PARAMS.ltsa.fs)
    error('Inconsistent sample rates detected in this folder.');
end

PARAMS.ltsa.nfft = double(floor(PARAMS.ltsa.fs / PARAMS.ltsa.dfreq));

window = hanning(PARAMS.ltsa.nfft);
overlap = 50;
noverlap = round((overlap/100)*PARAMS.ltsa.nfft);

% HMD
[ freqTable ] = getBandTable_erat(PARAMS.ltsa.fs/PARAMS.ltsa.nfft, 0, PARAMS.ltsa.fs, 10, ...
    1000, str2double(fStart), 1);
[~, firstBand]  = min(abs(str2double(fStart) - freqTable(:, 2)));
[~, lastBand] = min(abs(str2double(fStop) - freqTable(:, 2)));
freqTable = freqTable(firstBand:lastBand, :);

%% Transfer Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open transfer function and interpolate calibration curve

fid = fopen(PARAMS.metadata.tfFilePath,'r');
[A,~] = fscanf(fid,'%f %f',[2,inf]);
TFf = A(1,:);
TFdb = A(2,:);
fclose(fid);
cm1 = 60;
cm2 = 110;

% interpolating transfer function curve
[~,ia,ic] = unique(TFf);
if length(ia) == length(ic)
    freq = TFf;
    uppc = TFdb;
else
    freq = TFf(ia);
    uppc = TFdb(ia);
end


%% Compiling xwav times from ltsahd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Compiling xwav file times')

% file start and end times
fileStartTimes = datetime(PARAMS.ltsahd.dnumStart, 'ConvertFrom', 'datenum')+ years(2000);
durFile = (PARAMS.ltsahd.byte_length/(PARAMS.ltsa.nBits/8))/PARAMS.ltsa.fs;
fileEndTimes = fileStartTimes + seconds(durFile - .0005);

% days to process for HMD products
startDay = dateshift(min(fileStartTimes), 'start', 'day');
endDay = dateshift(max(fileEndTimes), 'start', 'day');
allDays = (startDay:days(1):endDay)';

%initiate loadbar showing progress
disp(['Creating HMD Products for ', PARAMS.metadata.project, ' ', PARAMS.metadata.site, ' ', datestr(startDay, 'dd-mmm-yyyy'), ' to ', datestr(endDay, 'dd-mmm-yyyy')]);


%% Processing minutely average SPL for each day
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
PARAMS_local = PARAMS; % copy global to local before parallel loop

parfor i = 1:length(allDays)
    % Only first worker uses GPU (safer for parfor)
    %useGPU = (labindex == 1);

    localParams = PARAMS_local;

    % start and end time for day being processed
    dayStart = allDays(i);
    dayEnd = dayStart + days(1) - seconds(60);

    % vector of all the minutes in this day
    thisDayMins = dayStart:1/(24*60):dayEnd;

    % initialize empty matrix to hold PSD columns
    nFreq = floor(localParams.ltsa.nfft/2) + 1;
    psd_matrix = nan(nFreq, length(thisDayMins), 'single');

    time_matrix = NaT(length(thisDayMins), 1);
    minPrct_vec = nan(length(thisDayMins), 1, 'single');
    xwav_file = cell(length(thisDayMins), 1);

    for m = 1:length(thisDayMins)
        startMin = thisDayMins(m);                % start of first minute to process
        endMin = startMin + seconds(60);          % end time is 60 seconds later


        % xwav(s) associated with this day
        [~, idxRw] = find(fileStartTimes < endMin & fileEndTimes > startMin);

        uxwav = unique(localParams.ltsahd.fname(idxRw, :), 'rows');

        if isempty(idxRw)
            disp(['No data for: ' char(startMin)])
            continue
        end


        % ------------------------------------------
        if size(uxwav, 1) == 1

            overlapFileName =  uxwav(1, :);
            overlapFiles = dir(fullfile(localParams.metadata.inputDir, '**', overlapFileName));

            thisxwavIdx = all(localParams.ltsahd.fname == overlapFileName, 2);


            % compiling start and end times of this xwav
            localParams.raw.dnumStart = localParams.ltsahd.dnumStart(thisxwavIdx);
            localParams.raw.dvecStart = [localParams.ltsahd.year(thisxwavIdx); ...
                localParams.ltsahd.month(thisxwavIdx); ...
                localParams.ltsahd.day(thisxwavIdx); ...
                localParams.ltsahd.hour(thisxwavIdx); ...
                localParams.ltsahd.minute(thisxwavIdx); ...
                localParams.ltsahd.secs(thisxwavIdx)]';

            localParams.raw.dvecEnd = datevec( ...
                datetime( ...
                localParams.ltsahd.year(thisxwavIdx), ...
                localParams.ltsahd.month(thisxwavIdx), ...
                localParams.ltsahd.day(thisxwavIdx), ...
                localParams.ltsahd.hour(thisxwavIdx), ...
                localParams.ltsahd.minute(thisxwavIdx), ...
                localParams.ltsahd.secs(thisxwavIdx) ...
                ) + seconds(localParams.ltsahd.byte_length(thisxwavIdx) / ((localParams.ltsa.nBits/8) * localParams.ltsahd.sample_rate(thisxwavIdx))) ...
                );



            localParams.raw.dnumEnd = datenum(localParams.raw.dvecEnd)';
            localParams.xhd.byte_loc = localParams.ltsahd.byte_loc(thisxwavIdx);
            localParams.xhd.byte_length = localParams.ltsahd.byte_length(thisxwavIdx);
            localParams.start.dnum = localParams.raw.dnumStart(1);
            localParams.end.dnum = localParams.raw.dnumEnd(end);



            % Read 1-minute chunk of data from file
            DATA = get_xwav_data_1ch_fromLTSAhd(fullfile(overlapFiles.folder, overlapFiles.name), datestr(startMin), datestr(endMin), localParams);


            if length(DATA)/ localParams.ltsa.fs < 60*(str2double(localParams.metadata.minPrct)/100)
                disp(['Less than ' localParams.metadata.minPrct '% of data in this minute, skipping!'])
                continue
            end

            xwav_file(m) = cellstr(uxwav(1, :));
            % Calculating percent effort in this minute
            minPrct_vec(m) = 100 * (length(DATA) / (60*localParams.ltsa.fs));

        elseif size(uxwav, 1) > 1
            DATA = [];

            for ix = 1:size(uxwav, 1)
                overlapFileName =  uxwav(ix, :);
                overlapFiles = dir(fullfile(localParams.metadata.inputDir, '**', overlapFileName));

                thisxwavIdx = all(localParams.ltsahd.fname == overlapFileName, 2);


                % compiling start and end times of this xwav
                localParams.raw.dnumStart = localParams.ltsahd.dnumStart(thisxwavIdx);
                localParams.raw.dvecStart = [localParams.ltsahd.year(thisxwavIdx); ...
                    localParams.ltsahd.month(thisxwavIdx); ...
                    localParams.ltsahd.day(thisxwavIdx); ...
                    localParams.ltsahd.hour(thisxwavIdx); ...
                    localParams.ltsahd.minute(thisxwavIdx); ...
                    localParams.ltsahd.secs(thisxwavIdx)]';

                localParams.raw.dvecEnd = datevec( ...
                    datetime( ...
                    localParams.ltsahd.year(thisxwavIdx), ...
                    localParams.ltsahd.month(thisxwavIdx), ...
                    localParams.ltsahd.day(thisxwavIdx), ...
                    localParams.ltsahd.hour(thisxwavIdx), ...
                    localParams.ltsahd.minute(thisxwavIdx), ...
                    localParams.ltsahd.secs(thisxwavIdx) ...
                    ) + seconds(localParams.ltsahd.byte_length(thisxwavIdx) / ((localParams.ltsa.nBits/8) * localParams.ltsahd.sample_rate(thisxwavIdx))) ...
                    );



                localParams.raw.dnumEnd = datenum(localParams.raw.dvecEnd)';
                localParams.xhd.byte_loc = localParams.ltsahd.byte_loc(thisxwavIdx);
                localParams.xhd.byte_length = localParams.ltsahd.byte_length(thisxwavIdx);
                localParams.start.dnum = localParams.raw.dnumStart(1);
                localParams.end.dnum = localParams.raw.dnumEnd(end);



                % Read 1-minute chunk of data from file
                DATA = [DATA; get_xwav_data_1ch_fromLTSAhd(fullfile(overlapFiles.folder, overlapFiles.name), datestr(startMin), datestr(endMin), localParams)];
                1;
                if length(DATA)/ localParams.ltsa.fs < 60*(str2double(localParams.metadata.minPrct)/100)
                    disp(['Less than ' localParams.metadata.minPrct '% of data in this minute, skipping!'])
                    continue
                end



            end
            xwav_file(m) = {strjoin(cellstr(uxwav), '; ')};
            % Calculating percent effort in this minute
            minPrct_vec(m) = 100 * (length(DATA) / (60*localParams.ltsa.fs));


        end
        %-----------------------------


        if isempty(DATA)
            continue
        end

        DATA = single(DATA);

        % if gpuDeviceCount > 0 && useGPU
        %     DATAg = gpuArray(DATA);
        %     % Compute Total Power (two-sided PSD)
        %     [S,F] = spectrogram(DATAg, window, noverlap, localParams.ltsa.nfft, localParams.ltsa.fs);
        %     % Mean two-sided PSD over the minute bin (119 samples) in linear
        %     % space
        %     P2 = gather(single(mean(abs(S).^2, 2))) / (localParams.ltsa.fs * sum(window.^2));
        % else
        % Compute Total Power (two-sided PSD)
        [S,F] = spectrogram(DATA, window, noverlap, localParams.ltsa.nfft, localParams.ltsa.fs);
        % Mean two-sided PSD over the minute bin (119 samples) in linear
        % space
        P2 = mean(abs(S).^2, 2) / (localParams.ltsa.fs * sum(window.^2));
        % end

        % Convert to one-sided
        P1 = P2;
        if rem(localParams.ltsa.nfft,2) % odd NFFT
            P1(2:end) = 2*P1(2:end);
        else % even NFFT
            P1(2:end-1) = 2*P1(2:end-1);
        end

        % lienar to dB
        P1dB = 10*log10(P1);

        % if rmFIFO
        if rmFifo
            [P1dB, ~] = fun_removeFIFO(P1dB, F, localParams.ltsa.fs);
        end

        % store in matrix
        psd_matrix(:, m) = P1dB;
        time_matrix(m) = startMin;

        disp(['PSD for ', char(string(startMin, 'yyyy-MM-dd HH:mm:ss')), ' computed'])

    end


    % transfer function in dB re 1uPa
    Ptf = interp1(freq,uppc,F,'linear','extrap');

    psd_tf = psd_matrix + Ptf;

    linLevel = 10.^(psd_tf/10)';


    % If you want sound pressure level
    % bandsOut = 10*log10(getBandSquaredSoundPressure(linLevel, localParams.ltsa.fs/localParams.ltsa.nfft, F(1), ...
    %     1, length(freqTable), freqTable));

    % if you want band width adjusted power spectral density
    bandsOut = 10*log10(getBandMeanPowerSpectralDensity(linLevel, localParams.ltsa.fs/localParams.ltsa.nfft, F(1), ...
        1, length(freqTable), freqTable));


    idxAllNaN = all(isnan(bandsOut), 2);
    bandsOut(idxAllNaN, :) = [];
    time_matrix(idxAllNaN) = [];
    minPrct_vec(idxAllNaN) = [];
    xwav_file(idxAllNaN) = [];


    if isempty(time_matrix)
        continue
    end


    outName = [
        localParams.metadata.organization, '_', ...
        localParams.metadata.project, '_', ...
        localParams.metadata.site, '_', ...
        localParams.metadata.deployment, '_', ...
        num2str(localParams.ltsa.fs/1000), 'kHz_',...
        localParams.metadata.startDep, '-', localParams.metadata.endDep, ...
        '_HMD_', ...
        datestr(dayStart + years(2000), 'yymmdd'), '.nc'];


    if ~exist(localParams.metadata.outputDir, 'dir')
        mkdir(localParams.metadata.outputDir);
    end
    outFile = fullfile(localParams.metadata.outputDir, outName);
    outFilePng = strrep(outFile, '.nc', '.png');


    % Create invisible figure for parfor
    fig = figure('Visible','off');
    clf(fig);
    set(fig, 'Position', [100, 100, 1200, 600]);  % [left, bottom, width, height]

    % First subplot (wider)
    ax1 = axes('Parent', fig, 'Position', [0.08, 0.1, 0.6, 0.8]);
    surf(ax1, time_matrix, freqTable(:, 2), bandsOut', 'Linestyle', 'none');
    ylim(ax1, [str2double(fStart) str2double(fStop)]);
    xlim(ax1, [dayStart, dayEnd]);
    view(ax1, [0 90]);
    set(ax1, 'yscale', 'log');
    colormap(ax1, cmocean('thermal'));
    caxis(ax1, [cm1 cm2]);
    ylabel(ax1, 'Frequency (Hz)');
    xlabel(ax1, 'UTC Time (HH:MM)');
    title(ax1, [localParams.metadata.organization ' ' localParams.metadata.project ' ' ...
        localParams.metadata.site ' ' localParams.metadata.deployment ...
        ' Hybrid Millidecade ' datestr(dayStart)]);
    c = colorbar(ax1,'eastoutside');
    c.Label.String = 'Spectrum Level (dB re 1\muPa^2/Hz)';
    datetick(ax1, 'x', 'keeplimits');

    % Compute percentiles
    percentiles = [1 10 25 50 75 90 99];
    pctVals = prctile(bandsOut', percentiles, 2);

    % Second subplot (narrower)
    ax2 = axes('Parent', fig, 'Position', [0.72, 0.1, 0.22, 0.8]);
    hold(ax2, 'on');
    for n = 1:length(percentiles)
        semilogy(ax2, pctVals(:, n), freqTable(:, 2), 'LineWidth', 1.2);
    end
    set(ax2, 'YScale', 'log', 'YDir', 'normal', 'YAxisLocation', 'right');
    xlabel(ax2, 'Spectrum Level (dB re 1\muPa^2/Hz)');
    ylabel(ax2, 'Frequency (Hz)');
    grid(ax2,'on');
    xlim(ax2, [50 120]);
    ylim(ax2, [str2double(fStart) str2double(fStop)]);
    title(ax2, 'Percentiles');
    legend(ax2, strcat(string(percentiles'), 'th'), 'Location', 'northeast');
    hold(ax2, 'off');


    % Save figure to file
    saveas(fig, outFilePng);

    % Close figure to free memory
    close(fig);

    ncid = netcdf.create(fullfile(localParams.metadata.outputDir, outName), 'NETCDF4');


    % Add global attributes
    globalID = netcdf.getConstant('NC_GLOBAL');
    netcdf.putAtt(ncid, globalID, 'title', char(localParams.metadata.title));
    netcdf.putAtt(ncid, globalID, 'summary', char(localParams.metadata.summary));
    netcdf.putAtt(ncid, globalID, 'history', char(localParams.metadata.history));
    netcdf.putAtt(ncid, globalID, 'source', char(localParams.metadata.source));
    netcdf.putAtt(ncid, globalID, 'acknowledgements', char(localParams.metadata.acknowledgements));
    netcdf.putAtt(ncid, globalID, 'citation', char(localParams.metadata.citation));
    netcdf.putAtt(ncid, globalID, 'comment', char(localParams.metadata.comment));
    netcdf.putAtt(ncid, globalID, 'conventions', char(localParams.metadata.conventions));
    netcdf.putAtt(ncid, globalID, 'creator_name', char(localParams.metadata.creator_name));
    netcdf.putAtt(ncid, globalID, 'creator_role', char(localParams.metadata.creator_role));
    netcdf.putAtt(ncid, globalID, 'creator_url', char(localParams.metadata.creator_url));
    netcdf.putAtt(ncid, globalID, 'publisher_url', char(localParams.metadata.publisher_url));
    netcdf.putAtt(ncid, globalID, 'institution', char(localParams.metadata.institution));
    netcdf.putAtt(ncid, globalID, 'instrument', char(localParams.metadata.instrument));
    netcdf.putAtt(ncid, globalID, 'keywords', char(localParams.metadata.keywords));
    netcdf.putAtt(ncid, globalID, 'keywords_vocabulary', char(localParams.metadata.keywords_vocabulary));
    netcdf.putAtt(ncid, globalID, 'license',char( localParams.metadata.license));
    netcdf.putAtt(ncid, globalID, 'naming_authority', char(localParams.metadata.naming_authority));
    netcdf.putAtt(ncid, globalID, 'product_version', char(localParams.metadata.product_version));
    netcdf.putAtt(ncid, globalID, 'publisher_name', char(localParams.metadata.publisher_name));
    netcdf.putAtt(ncid, globalID, 'reference', char(localParams.metadata.reference));

    netcdf.putAtt(ncid, globalID, 'organization', char(localParams.metadata.organization));
    netcdf.putAtt(ncid, globalID, 'project', char(localParams.metadata.project));
    netcdf.putAtt(ncid, globalID, 'site', char(localParams.metadata.site));
    netcdf.putAtt(ncid, globalID, 'deployment', localParams.metadata.deployment);
    pointStr = sprintf('POINT(%0.6f %0.6f)', localParams.metadata.longitude, localParams.metadata.latitude);
    netcdf.putAtt(ncid, globalID, 'geospatial_bounds', pointStr);    netcdf.putAtt(ncid, globalID, 'id', char(localParams.metadata.id));
    netcdf.putAtt(ncid, globalID, 'sample_rate', localParams.ltsa.fs);
    netcdf.putAtt(ncid, globalID, 'nfft', localParams.ltsa.nfft);
    idxTF = find(localParams.metadata.tfFilePath == '\', 1, 'last');
    netcdf.putAtt(ncid, globalID, 'transferFunction_file', localParams.metadata.tfFilePath(idxTF+1:end));
    netcdf.putAtt(ncid, globalID, 'freq_bin_size', localParams.ltsa.dfreq);
    netcdf.putAtt(ncid, globalID, 'cmd_data_type', 'TimeSeries');
    netcdf.putAtt(ncid, globalID, 'time_coverage_duration', 'P1D');
    netcdf.putAtt(ncid, globalID, 'time_coverage_resolution', 'P60S');
    netcdf.putAtt(ncid, globalID, 'date_created', char(datetime('today', 'Format', 'yyyy-MM-dd')));


    xwav_file = string(xwav_file);
    numFiles = size(xwav_file, 1);


    % Define dimensions
    timeDimID = netcdf.defDim(ncid, 'time', length(time_matrix));
    freqDimID = netcdf.defDim(ncid, 'frequency', length(freqTable(:, 2)));
    dimNumFilesID = netcdf.defDim(ncid, 'numFiles', numFiles);
    % Define variables

    % time
    timeVarID = netcdf.defVar(ncid, 'time', 'double', timeDimID);
    netcdf.putAtt(ncid, timeVarID, 'units', 'seconds since 1970-01-01T00:00:00Z');
    netcdf.putAtt(ncid, timeVarID, 'time_zone', 'UTC');

    % frequency
    freqVarID = netcdf.defVar(ncid, 'frequency', 'double', freqDimID);
    netcdf.putAtt(ncid, freqVarID, 'units', 'Hz');

    % psd
    psdVarID = netcdf.defVar(ncid, 'psd', 'double', [freqDimID, timeDimID]);
    netcdf.putAtt(ncid, psdVarID, 'units', 'dB re 1uPa^2/Hz');

    %effort
    effortVarID = netcdf.defVar(ncid, 'effort', 'double', timeDimID);
    netcdf.putAtt(ncid, effortVarID, 'units', 'percent');

    % xwav file associated with measurement
    % xwavFileVarID = netcdf.defVar(ncid, 'xwavFile', 'NC_CHAR', xwavFileDimID);
    xwavFileVarID = netcdf.defVar(ncid, 'xwavFile', 'NC_STRING', dimNumFilesID);

    % End Define Mode
    netcdf.endDef(ncid);

    % Put Variables

    % converting to seconds since 1970
    epoch = datetime(1970,1,1,0,0,0);
    secondsSinceEpoch = seconds(time_matrix - epoch);

    netcdf.putVar(ncid, timeVarID, double(secondsSinceEpoch));
    netcdf.putVar(ncid, freqVarID, double(freqTable(:, 2)));
    netcdf.putVar(ncid, psdVarID, double(bandsOut'));
    netcdf.putVar(ncid, effortVarID, double(minPrct_vec(:)));
    netcdf.putVar(ncid, xwavFileVarID, xwav_file);
    netcdf.close(ncid);
    disp(['Saved NetCDF: ', fullfile(localParams.metadata.outputDir, outName)]);


end

end
