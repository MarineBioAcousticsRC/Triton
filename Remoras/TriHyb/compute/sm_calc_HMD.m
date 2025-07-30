function sm_calc_HMD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VMZ 6/25/2025 (copied parts from SoundScape Remora)
%
% calculate minutely spectral averages for daily files (called by mypst_compute)
%
%
% TO DO:
% - Stitch minutes with 2 xwavs together, for now, it just uses
% beginning xwav and keeps if it has 50% of data in minute


global PARAMS

%% Spectra Computation Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fStart = PARAMS.metadata.startF;
fStop = PARAMS.metadata.endF;
PARAMS.ltsa.dfreq = 1;
PARAMS.ltsa.fs = double(PARAMS.ltsahd.sample_rate(1));

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

for i = 1:length(allDays)

    % start and end time for day being processed
    dayStart = allDays(i);
    dayEnd = dayStart + days(1) - seconds(60);

    % vector of all the minutes in this day
    thisDayMins = dayStart:1/(24*60):dayEnd;

    % initialize empty matrix to hold PSD columns
    psd_matrix = nan(length(0:PARAMS.ltsa.fs/2), length(thisDayMins));
    time_matrix = NaT(length(thisDayMins), 1);
    minPrct_vec = nan(length(thisDayMins), 1);
    xwav_file = cell(length(thisDayMins), 1);
    tic
    for m = 1:length(thisDayMins)
        startMin = thisDayMins(m);                % start of first minute to process
        endMin = startMin + seconds(60);          % end time is 60 seconds later


        % xwav(s) associated with this day
        [~, idxRw] = find(fileStartTimes < endMin & fileEndTimes > startMin);

        uxwav = unique(PARAMS.ltsahd.fname(idxRw, :), 'rows');

        if isempty(idxRw)
            disp(['No data for: ' char(startMin)])
            continue
        end


        % ------------------------------------------
        if size(uxwav, 1) == 1

            overlapFileName =  uxwav(1, :);
            overlapFiles = dir(fullfile(PARAMS.metadata.inputDir, '**', overlapFileName));

            thisxwavIdx = all(PARAMS.ltsahd.fname == overlapFileName, 2);


            % compiling start and end times of this xwav
            PARAMS.raw.dnumStart = PARAMS.ltsahd.dnumStart(thisxwavIdx);
            PARAMS.raw.dvecStart = [PARAMS.ltsahd.year(thisxwavIdx); ...
                PARAMS.ltsahd.month(thisxwavIdx); ...
                PARAMS.ltsahd.day(thisxwavIdx); ...
                PARAMS.ltsahd.hour(thisxwavIdx); ...
                PARAMS.ltsahd.minute(thisxwavIdx); ...
                PARAMS.ltsahd.secs(thisxwavIdx)]';

            PARAMS.raw.dvecEnd = datevec( ...
                datetime( ...
                PARAMS.ltsahd.year(thisxwavIdx), ...
                PARAMS.ltsahd.month(thisxwavIdx), ...
                PARAMS.ltsahd.day(thisxwavIdx), ...
                PARAMS.ltsahd.hour(thisxwavIdx), ...
                PARAMS.ltsahd.minute(thisxwavIdx), ...
                PARAMS.ltsahd.secs(thisxwavIdx) ...
                ) + seconds(PARAMS.ltsahd.byte_length(thisxwavIdx) / ((PARAMS.ltsa.nBits/8) * PARAMS.ltsahd.sample_rate(thisxwavIdx))) ...
                );



            PARAMS.raw.dnumEnd = datenum(PARAMS.raw.dvecEnd)';
            PARAMS.xhd.byte_loc = PARAMS.ltsahd.byte_loc(thisxwavIdx);
            PARAMS.xhd.byte_length = PARAMS.ltsahd.byte_length(thisxwavIdx);
            PARAMS.start.dnum = PARAMS.raw.dnumStart(1);
            PARAMS.end.dnum = PARAMS.raw.dnumEnd(end);



            % Read 1-minute chunk of data from file
            DATA = get_xwav_data_1ch_fromLTSAhd(fullfile(overlapFiles.folder, overlapFiles.name), datestr(startMin), datestr(endMin));


            if length(DATA)/ PARAMS.ltsa.fs < 60*(str2double(PARAMS.metadata.minPrct)/100)
                disp(['Less than ' PARAMS.metadata.minPrct '% of data in this minute, skipping!'])
                continue
            end

            xwav_file(m) = cellstr(uxwav(1, :));
            % Calculating percent effort in this minute
            minPrct_vec(m) = round((length(DATA)/PARAMS.ltsa.fs / 60));

        elseif size(uxwav, 1) > 1
            DATA = [];

            for ix = 1:size(uxwav, 1)
                overlapFileName =  uxwav(ix, :);
                overlapFiles = dir(fullfile(PARAMS.metadata.inputDir, '**', overlapFileName));

                thisxwavIdx = all(PARAMS.ltsahd.fname == overlapFileName, 2);


                % compiling start and end times of this xwav
                PARAMS.raw.dnumStart = PARAMS.ltsahd.dnumStart(thisxwavIdx);
                PARAMS.raw.dvecStart = [PARAMS.ltsahd.year(thisxwavIdx); ...
                    PARAMS.ltsahd.month(thisxwavIdx); ...
                    PARAMS.ltsahd.day(thisxwavIdx); ...
                    PARAMS.ltsahd.hour(thisxwavIdx); ...
                    PARAMS.ltsahd.minute(thisxwavIdx); ...
                    PARAMS.ltsahd.secs(thisxwavIdx)]';

                PARAMS.raw.dvecEnd = datevec( ...
                    datetime( ...
                    PARAMS.ltsahd.year(thisxwavIdx), ...
                    PARAMS.ltsahd.month(thisxwavIdx), ...
                    PARAMS.ltsahd.day(thisxwavIdx), ...
                    PARAMS.ltsahd.hour(thisxwavIdx), ...
                    PARAMS.ltsahd.minute(thisxwavIdx), ...
                    PARAMS.ltsahd.secs(thisxwavIdx) ...
                    ) + seconds(PARAMS.ltsahd.byte_length(thisxwavIdx) / ((PARAMS.ltsa.nBits/8) * PARAMS.ltsahd.sample_rate(thisxwavIdx))) ...
                    );



                PARAMS.raw.dnumEnd = datenum(PARAMS.raw.dvecEnd)';
                PARAMS.xhd.byte_loc = PARAMS.ltsahd.byte_loc(thisxwavIdx);
                PARAMS.xhd.byte_length = PARAMS.ltsahd.byte_length(thisxwavIdx);
                PARAMS.start.dnum = PARAMS.raw.dnumStart(1);
                PARAMS.end.dnum = PARAMS.raw.dnumEnd(end);



                % Read 1-minute chunk of data from file
                DATA = [DATA; get_xwav_data_1ch_fromLTSAhd(fullfile(overlapFiles.folder, overlapFiles.name), datestr(startMin), datestr(endMin))];
                1;
                if length(DATA)/ PARAMS.ltsa.fs < 60*(str2double(PARAMS.metadata.minPrct)/100)
                    disp(['Less than ' PARAMS.metadata.minPrct '% of data in this minute, skipping!'])
                    continue
                end



            end
            xwav_file(m) = {strjoin(cellstr(uxwav), '; ')};
            % Calculating percent effort in this minute
            minPrct_vec(m) = round((length(DATA)/PARAMS.ltsa.fs / 60));


        end
        %-----------------------------


        if isempty(DATA)
            continue
        end

        [pxx,F] = pwelch(DATA,window,noverlap,PARAMS.ltsa.nfft,PARAMS.ltsa.fs);   % pwelch is supported psd'er
        psd = 10*log10(pxx); % counts^2/Hz
        psd_matrix(:, m) = psd;
        time_matrix(m) = startMin;

        disp(['PSD for ', char(string(startMin, 'yyyy-MM-dd HH:mm:ss')), ' computed'])

    end


    % transfer function in dB re 1uPa
    Ptf = interp1(freq,uppc,F,'linear','extrap');

    psd_tf = psd_matrix + Ptf;

    linLevel = 10.^(psd_tf/10)';


    % If you want sound pressure level
    % bandsOut = 10*log10(getBandSquaredSoundPressure(linLevel, PARAMS.ltsa.fs/PARAMS.ltsa.nfft, F(1), ...
    %     1, length(freqTable), freqTable));

    % if you want band width adjusted power spectral density
    bandsOut = 10*log10(getBandMeanPowerSpectralDensity(linLevel, PARAMS.ltsa.fs/PARAMS.ltsa.nfft, F(1), ...
        1, length(freqTable), freqTable));


    figure(601)
    clf
    % Make figure wider
    set(gcf, 'Position', [100, 100, 1200, 600])  % [left, bottom, width, height]
    % First subplot (wider)
    ax1 = axes('Position', [0.08, 0.1, 0.6, 0.8]);  % [left, bottom, width, height]
    surf(ax1, time_matrix, freqTable(:, 2), bandsOut', 'Linestyle', 'none');
    ylim([str2double(fStart) str2double(fStop)])
    xlim([dayStart, dayEnd])
    view(ax1, [0 90])
    set(ax1, 'yscale', 'log')
    colormap(ax1, cmocean('thermal'));
    caxis(ax1, [cm1 cm2])  % clim is caxis in axes
    ylabel(ax1, 'Frequency (Hz)')
    xlabel(ax1, 'UTC Time (HH:MM)')
    title(ax1, [PARAMS.metadata.organization ' ' PARAMS.metadata.project ' ' PARAMS.metadata.site ' ' PARAMS.metadata.deployment ' Hybrid Millidecade ' datestr(dayStart)])
    c = colorbar('eastoutside');
    c.Label.String = 'Spectrum Level (dB re 1\muPa^2/Hz)';
    datetick(ax1, 'x', 'keeplimits')
    % Compute percentiles across time (columns of bandsOut')
    percentiles = [1 10 25 50 75 90 99];
    pctVals = prctile(bandsOut', percentiles, 2);  % size: [nFreqBands x nPercentiles]
    % Second subplot (narrower, with y-ticks on right)
    ax2 = axes('Position', [0.72, 0.1, 0.22, 0.8]);  % moved slightly right and narrow
    hold(ax2, 'on')

    % Plot amplitude percentiles vs frequency with semilog y
    for n = 1:length(percentiles)
        semilogy(ax2, pctVals(:, n), freqTable(:, 2), 'LineWidth', 1.2);
    end
    set(ax2, 'YScale', 'log', 'YDir', 'normal', 'YAxisLocation', 'right')
    xlabel(ax2, 'Spectrum Level (dB re 1\muPa^2/Hz)')
    ylabel(ax2, 'Frequency (Hz)')  % optional, since it's on right side
    grid(ax2, 'on')
    xlim([50 120])
    ylim([str2double(fStart) str2double(fStop)])
    title(ax2, 'Percentiles')
    legend(ax2, strcat(string(percentiles'), 'th'), 'Location', 'northeast')
    hold(ax2, 'off')
    toc


    idxNaN = any(isnan(bandsOut), 2);
    bandsOut(idxNaN, :) = [];
    time_matrix(idxNaN) = [];
    minPrct_vec(idxNaN) = [];
    xwav_file(idxNaN) = [];


    if isempty(time_matrix)
        continue
    end


    outName = [
        PARAMS.metadata.organization, '_', ...
        PARAMS.metadata.project, '_', ...
        PARAMS.metadata.site, '_', ...
        PARAMS.metadata.deployment, '_', ...
        num2str(PARAMS.ltsa.fs/1000), 'kHz_',...
        PARAMS.metadata.startDep, '-', PARAMS.metadata.endDep, ...
        '_HMD_', ...
        datestr(dayStart + years(2000), 'yymmdd'), '.nc'];

    outFile = fullfile(PARAMS.metadata.outputDir, outName);
    outFilePng = strrep(outFile, '.nc', '.png');
    saveas(gcf, outFilePng);


    fclose('all');


    ncid = netcdf.create(fullfile(PARAMS.metadata.outputDir, outName), 'NETCDF4');


    % Add global attributes
    globalID = netcdf.getConstant('NC_GLOBAL');
    netcdf.putAtt(ncid, globalID, 'title', char(PARAMS.metadata.title));
    netcdf.putAtt(ncid, globalID, 'summary', char(PARAMS.metadata.summary));
    netcdf.putAtt(ncid, globalID, 'history', char(PARAMS.metadata.history));
    netcdf.putAtt(ncid, globalID, 'source', char(PARAMS.metadata.source));
    netcdf.putAtt(ncid, globalID, 'acknowledgements', char(PARAMS.metadata.acknowledgements));
    netcdf.putAtt(ncid, globalID, 'citation', char(PARAMS.metadata.citation));
    netcdf.putAtt(ncid, globalID, 'comment', char(PARAMS.metadata.comment));
    netcdf.putAtt(ncid, globalID, 'conventions', char(PARAMS.metadata.conventions));
    netcdf.putAtt(ncid, globalID, 'creator_name', char(PARAMS.metadata.creator_name));
    netcdf.putAtt(ncid, globalID, 'creator_role', char(PARAMS.metadata.creator_role));
    netcdf.putAtt(ncid, globalID, 'creator_url', char(PARAMS.metadata.creator_url));
    netcdf.putAtt(ncid, globalID, 'publisher_url', char(PARAMS.metadata.publisher_url));
    netcdf.putAtt(ncid, globalID, 'institution', char(PARAMS.metadata.institution));
    netcdf.putAtt(ncid, globalID, 'instrument', char(PARAMS.metadata.instrument));
    netcdf.putAtt(ncid, globalID, 'keywords', char(PARAMS.metadata.keywords));
    netcdf.putAtt(ncid, globalID, 'keywords_vocabulary', char(PARAMS.metadata.keywords_vocabulary));
    netcdf.putAtt(ncid, globalID, 'license',char( PARAMS.metadata.license));
    netcdf.putAtt(ncid, globalID, 'naming_authority', char(PARAMS.metadata.naming_authority));
    netcdf.putAtt(ncid, globalID, 'product_version', char(PARAMS.metadata.product_version));
    netcdf.putAtt(ncid, globalID, 'publisher_name', char(PARAMS.metadata.publisher_name));
    netcdf.putAtt(ncid, globalID, 'reference', char(PARAMS.metadata.reference));

    netcdf.putAtt(ncid, globalID, 'organization', char(PARAMS.metadata.organization));
    netcdf.putAtt(ncid, globalID, 'project', char(PARAMS.metadata.project));
    netcdf.putAtt(ncid, globalID, 'site', char(PARAMS.metadata.site));
    netcdf.putAtt(ncid, globalID, 'deployment', PARAMS.metadata.deployment);
    pointStr = sprintf('POINT(%0.6f %0.6f)', PARAMS.metadata.longitude, PARAMS.metadata.latitude);
    netcdf.putAtt(ncid, globalID, 'geospatial_bounds', pointStr);    netcdf.putAtt(ncid, globalID, 'id', char(PARAMS.metadata.id));
    netcdf.putAtt(ncid, globalID, 'sample_rate', PARAMS.ltsa.fs);
    netcdf.putAtt(ncid, globalID, 'nfft', PARAMS.ltsa.nfft);
    idxTF = find(PARAMS.metadata.tfFilePath == '\', 1, 'last');
    netcdf.putAtt(ncid, globalID, 'transferFunction_file', PARAMS.metadata.tfFilePath(idxTF+1:end));
    netcdf.putAtt(ncid, globalID, 'freq_bin_size', PARAMS.ltsa.dfreq);
    netcdf.putAtt(ncid, globalID, 'cmd_data_type', 'TimeSeries');
    netcdf.putAtt(ncid, globalID, 'time_coverage_duration', 'P1D');
    netcdf.putAtt(ncid, globalID, 'time_coverage_resolution', 'P60S');
    netcdf.putAtt(ncid, globalID, 'date_created', char(datetime("today", 'Format', 'yyyy-MM-dd')));


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
    netcdf.putVar(ncid, effortVarID, double(minPrct_vec(:)*100));
    netcdf.putVar(ncid, xwavFileVarID, xwav_file);

end



end
