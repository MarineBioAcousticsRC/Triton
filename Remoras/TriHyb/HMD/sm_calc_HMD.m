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

fStart = PARAMS.ltsa.startF;
fStop = PARAMS.ltsa.endF;
window = hanning(PARAMS.ltsa.nfft);
overlap = 50;
noverlap = round((overlap/100)*PARAMS.ltsa.nfft);

% HMD
[ freqTable ] = getBandTable_erat(PARAMS.ltsa.fs/PARAMS.ltsa.nfft, 0, PARAMS.ltsa.fs, 10, ...
    1000, fStart, 1);
[~, firstBand]  = min(abs(str2double(fStart) - freqTable(:, 2)));
[~, lastBand] = min(abs(str2double(fStop) - freqTable(:, 2)));
freqTable = freqTable(firstBand:lastBand, :);

%% Transfer Function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% open transfer function and interpolate calibration curve

fid = fopen(PARAMS.tfFilePath,'r');
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
disp(['Creating HMD Products for ', PARAMS.ltsa.project, ' ', PARAMS.ltsa.site, ' ', datestr(startDay, 'dd-mmm-yyyy'), ' to ', datestr(endDay, 'dd-mmm-yyyy')]);


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
    for m = 1:3%length(thisDayMins)
        PARAMS.minTime = thisDayMins(m);                % start of first minute to process
        PARAMS.endt = PARAMS.minTime + seconds(60);     % end time is 60 seconds later


        % xwav(s) associated with this day
        [~, idxRw] = find(fileStartTimes < PARAMS.endt & fileEndTimes > PARAMS.minTime);
        overlapFiles = unique(PARAMS.ltsahd.fname(idxRw, :), 'rows');

        % change to all overlapFiles when fixing xwav stitching
        overlapFiles = overlapFiles(1, :);
        thisxwavIdx = ismember(cellstr(PARAMS.ltsahd.fname), cellstr(overlapFiles));

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
            ) + seconds(75.9995) ...
            );

        PARAMS.raw.dnumEnd = datenum(PARAMS.raw.dvecEnd)';
        PARAMS.xhd.byte_loc = PARAMS.ltsahd.byte_loc(thisxwavIdx);
        PARAMS.xhd.byte_length = PARAMS.ltsahd.byte_length(thisxwavIdx);
        PARAMS.start.dnum = PARAMS.raw.dnumStart(1);
        PARAMS.end.dnum = PARAMS.raw.dnumEnd(end);



        % Read 1-minute chunk of data from file
        DATA = get_xwav_data_1ch_fromLTSAhd(fullfile(PARAMS.ltsa.inputDir, overlapFiles), datestr(PARAMS.minTime), datestr(PARAMS.endt));

        if isempty(DATA)
            continue
        end

        [pxx,F] = pwelch(DATA,window,noverlap,PARAMS.ltsa.nfft,PARAMS.ltsa.fs);   % pwelch is supported psd'er
        psd = 10*log10(pxx); % counts^2/Hz
        psd_matrix(:, m) = psd;
        time_matrix(m) = PARAMS.minTime;
        minPrct_vec(m) = PARAMS.minPrctVecTemp;
        xwav_file(m) = cellstr(overlapFiles);


        disp(['PSD for ', char(string(PARAMS.minTime, 'yyyy-MM-dd HH:mm:ss')), ' computed'])

    end

    % if there aren't the maximum amount of minutes in this day

    idxEnd = find(isnan(psd_matrix(1, :)));
    if ~isempty(idxEnd)
        psd_matrix = psd_matrix(:, 1:idxEnd(1) - 1);
        time_matrix = time_matrix(1:idxEnd(1) - 1);
        minPrct_vec = minPrct_vec(1:idxEnd(1) - 1);
        xwav_file = xwav_file(1:idxEnd(1) - 1);
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
    view(ax1, [0 90])
    set(ax1, 'yscale', 'log')
    colormap(ax1, cmocean('thermal'));
    clim(ax1, [cm1 cm2])  % clim is caxis in axes
    ylabel(ax1, 'Frequency (Hz)')
    xlabel(ax1, 'UTC Time (HH:MM)')
    title(ax1, [PARAMS.ltsa.organization ' ' PARAMS.ltsa.project ' ' PARAMS.ltsa.site ' ' PARAMS.ltsa.deployment ' Hybrid Millidecade ' datestr(dayStart)])
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

    outName = [
        PARAMS.ltsa.organization, '_', ...
        PARAMS.ltsa.project, '_', ...
        PARAMS.ltsa.site, '_', ...
        PARAMS.ltsa.deployment, '_', ...
        num2str(PARAMS.ltsa.fs/1000), 'kHz_',...
        PARAMS.ltsa.startDep, '-', PARAMS.ltsa.endDep, ...
        '_HMD_', ...
        datestr(dayStart + years(2000), 'yymmdd'), '.nc'];

    outFile = fullfile(PARAMS.ltsa.outputDir, outName);
    outFilePng = strrep(outFile, '.nc', '.png');
    saveas(gcf, outFilePng);


    fclose('all');


    % Delete file if it exists (and not already open)
    if isfile(outFile)
        try
            delete(outFile);
        catch ME
            warning('Could not delete existing file: %s\n%s', outFile, ME.message);
        end
    end


    ncid = netcdf.create(fullfile(PARAMS.ltsa.outputDir, outName), 'NETCDF4');


    % Add global attributes
    globalID = netcdf.getConstant('NC_GLOBAL');
    netcdf.putAtt(ncid, globalID, 'title', char(PARAMS.ltsa.title));
    netcdf.putAtt(ncid, globalID, 'summary', char(PARAMS.ltsa.summary));
    netcdf.putAtt(ncid, globalID, 'history', char(PARAMS.ltsa.history));
    netcdf.putAtt(ncid, globalID, 'source', char(PARAMS.ltsa.source));
    netcdf.putAtt(ncid, globalID, 'acknowledgements', char(PARAMS.ltsa.acknowledgements));
    netcdf.putAtt(ncid, globalID, 'citation', char(PARAMS.ltsa.citation));
    netcdf.putAtt(ncid, globalID, 'comment', char(PARAMS.ltsa.comment));
    netcdf.putAtt(ncid, globalID, 'conventions', char(PARAMS.ltsa.conventions));
    netcdf.putAtt(ncid, globalID, 'creator_name', char(PARAMS.ltsa.creator_name));
    netcdf.putAtt(ncid, globalID, 'creator_role', char(PARAMS.ltsa.creator_role));
    pointStr = sprintf('POINT(%0.6f %0.6f)', PARAMS.ltsa.longitude, PARAMS.ltsa.latitude);
    netcdf.putAtt(ncid, globalID, 'geospatial_bounds', pointStr);    netcdf.putAtt(ncid, globalID, 'id', char(PARAMS.ltsa.id));
    netcdf.putAtt(ncid, globalID, 'infoUrl', char(PARAMS.ltsa.infoUrl));
    netcdf.putAtt(ncid, globalID, 'institution', char(PARAMS.ltsa.institution));
    netcdf.putAtt(ncid, globalID, 'instrument', char(PARAMS.ltsa.instrument));
    netcdf.putAtt(ncid, globalID, 'keywords', char(PARAMS.ltsa.keywords));
    netcdf.putAtt(ncid, globalID, 'keywords_vocabulary', char(PARAMS.ltsa.keywords_vocabulary));
    netcdf.putAtt(ncid, globalID, 'license',char( PARAMS.ltsa.license));
    netcdf.putAtt(ncid, globalID, 'naming_authority', char(PARAMS.ltsa.naming_authority));
    netcdf.putAtt(ncid, globalID, 'product_version', char(PARAMS.ltsa.product_version));
    netcdf.putAtt(ncid, globalID, 'project', char(PARAMS.ltsa.project));
    netcdf.putAtt(ncid, globalID, 'publisher_name', char(PARAMS.ltsa.publisher_name));
    %    netcdf.putAtt(ncid, globalID, 'publisher_type', char(PARAMS.ltsa.publisher_type));
    netcdf.putAtt(ncid, globalID, 'reference', char(PARAMS.ltsa.reference));
    netcdf.putAtt(ncid, globalID, 'standard_name_vocabulary', char(PARAMS.ltsa.standard_name_vocabulary));
    netcdf.putAtt(ncid, globalID, 'organization', char(PARAMS.ltsa.organization));
    netcdf.putAtt(ncid, globalID, 'site', char(PARAMS.ltsa.site));
    netcdf.putAtt(ncid, globalID, 'sample_rate', PARAMS.ltsa.fs);
    netcdf.putAtt(ncid, globalID, 'nfft', PARAMS.ltsa.nfft);
    netcdf.putAtt(ncid, globalID, 'freq_bin_size', PARAMS.ltsa.dfreq);
    netcdf.putAtt(ncid, globalID, 'deployment', PARAMS.ltsa.deployment);



    xwav_file = string(xwav_file);

    % Define dimensions
    timeDimID = netcdf.defDim(ncid, 'time', length(time_matrix));
    freqDimID = netcdf.defDim(ncid, 'frequency', length(freqTable(:, 2)));
    xwavFileDimID = netcdf.defDim(ncid, 'xwavFile', length(xwav_file));

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
    xwavFileVarID = netcdf.defVar(ncid, 'xwavFile', 'string', xwavFileDimID);

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
    netcdf.putVar(ncid, xwavFileVarID, xwav_file');

end



end
% % 

test2 = ncinfo('D:\HMD\MBARC_CINMS_B_47_2kHz_YYMMDD-YYMMDD_HMD_230920.nc');
 PSTnc2 = ncread('D:\HMD\MBARC_CINMS_B_47_2kHz_YYMMDD-YYMMDD_HMD_230920.nc', 'effort');
  PSTnc2 = ncread('D:\HMD\MBARC_CINMS_B_47_2kHz_YYMMDD-YYMMDD_HMD_230920.nc', 'xwavFile');
  PSTnc2 = ncread('D:\HMD\MBARC_CINMS_B_47_2kHz_YYMMDD-YYMMDD_HMD_230920.nc', 'time');
%  t = datetime(PSTnc2, 'ConvertFrom', 'posixtime');
% % % 
% % % % % 
% % 
% test = ncinfo('D:\HMD\mbari_products_sound_level_metrics_mbari-mars_20210101-20211231_hmd_data_MARS_20210125.nc');
% PSTnc = ncread('D:\HMD\mbari_products_sound_level_metrics_mbari-mars_20210101-20211231_hmd_data_MARS_20210125.nc', 'psd');

% test3 = ncinfo('D:\HMD\onms_products_sound_level_metrics_sb03_onms_sb03_20230731-20231208_hmd_data_ONMS_SB03_20230731_7852.1.48000_20230731_DAILY_MILLIDEC_MinRes.nc');
