function sm_calc_HMD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% calculate spectral averages and save to ltsa file
%
% called by sm_mk_ltsa
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global PARAMS
tic


%% Spectra Computation Parameters
fStart = PARAMS.ltsa.startF;
fStop = PARAMS.ltsa.endF;


window = hanning(PARAMS.ltsa.nfft);
overlap = 50;
noverlap = round((overlap/100)*PARAMS.ltsa.nfft);
sampPerAve = PARAMS.ltsa.tave * PARAMS.ltsa.fs;

%% Transfer Function
fid = fopen(PARAMS.tfFilePath,'r');
[A,~] = fscanf(fid,'%f %f',[2,inf]);
TFf = A(1,:);
TFdb = A(2,:);
fclose(fid);
TFflag = 1;
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

%% HMD Inputs



%%



% Convert char array to string array (each row becomes a string)
fnames = string(PARAMS.ltsa.fname);

disp('Compiling xwav file times')

fileStartTimes = datetime(PARAMS.ltsahd.dnumStart, 'ConvertFrom', 'datenum')+ years(2000);
durFile = (PARAMS.ltsahd.byte_length/(PARAMS.ltsa.nBits/8))/PARAMS.ltsa.fs;
fileEndTimes = fileStartTimes + seconds(durFile - .0005);


startDay = dateshift(min(fileStartTimes), 'start', 'day');
endDay = dateshift(max(fileEndTimes), 'start', 'day');
allDays = (startDay:days(1):endDay)';

%initiate loadbar showing progress
disp(['Creating HMD Products for ', PARAMS.ltsa.project, ' ', PARAMS.ltsa.site, ' ', datestr(startDay, 'dd-mmm-yyyy'), ' to ', datestr(endDay, 'dd-mmm-yyyy')]);
%
% % Create waitbar
% hWait = waitbar(0, sprintf('Processing HMD for %s - %s', startDay, endDay), ...
%     'Name', 'HMD Progress', ...
%     'CreateCancelBtn', 'setappdata(gcbf,''canceling'',1)', ...
%     'WindowStyle', 'normal');
%
% % Customize background color (light blue)
% set(hWait, 'Color', [0.94, 0.97, 1]);  % Match your GUI background
%
% % Optional: Set canceling flag
% setappdata(hWait, 'canceling', 0);

for i = 1:length(allDays)
    % if getappdata(hWait, 'canceling')
    %     break;
    % end

    dayStart = allDays(i);
    dayEnd = dayStart + days(1);



    [~, idxRw] = find(fileStartTimes < dayEnd & fileEndTimes > dayStart);
    overlapFilesAll = unique(PARAMS.ltsahd.fname(idxRw, :), 'rows');

    for j = 1:size(overlapFilesAll, 1)  % assuming overlapFiles is a vector of file indices
        overlapFiles = overlapFilesAll(j, :);

        thisxwavIdx = ismember(cellstr(PARAMS.ltsahd.fname), cellstr(overlapFiles));

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


        % Initialize start and end times for this file (datetime or datenum)
        minTime = dayStart;                % start of first minute to process
        endt = minTime + seconds(60);     % end time is 60 seconds later


        psd_matrix = [];  % initialize empty matrix to hold PSD columns
        time_matrix = [];
        % Loop over minutes within this file time range
        while minTime < dayEnd  % assuming dayEnd is the end of the day's range

            % Read 1-minute chunk of data from file
            DATA = get_xwav_data_1ch_fromLTSAhd(fullfile(PARAMS.ltsa.inputDir, fnames{j}), datestr(minTime), datestr(endt));
            [pxx,F] = pwelch(DATA,window,noverlap,PARAMS.ltsa.nfft,PARAMS.ltsa.fs);   % pwelch is supported psd'er
            psd = 10*log10(pxx); % counts^2/Hz
            psd_matrix = [psd_matrix, psd];
            time_matrix = [time_matrix, minTime];


            % Process DATA here (e.g., compute spectra, averages...)


            % Increment times by 1 minute (60 seconds)
            minTime = minTime + seconds(60);
            endt = endt + seconds(60);
            disp(['PSD for ', datestr(minTime), ' computed'])
        end



    end


    % transfer function in dB re 1uPa
    Ptf = interp1(freq,uppc,F,'linear','extrap');

    psd_tf = psd_matrix + Ptf;

    [ freqTable ] = getBandTable_erat(PARAMS.ltsa.fs/PARAMS.ltsa.nfft, F(1), PARAMS.ltsa.fs, 10, ...
        1000, 10, 1);

    linLevel = 10.^(psd_tf/10)';

    [~, firstBand]  = min(abs(str2num(fStart) - freqTable(:, 2)));
    [~, lastBand] = min(abs(str2num(fStop) - freqTable(:, 2)));


    bandsOut = 10*log10(getBandSquaredSoundPressure(linLevel, PARAMS.ltsa.fs/PARAMS.ltsa.nfft, F(1), ...
        firstBand, lastBand, freqTable));
    %
    % bandsOut = 10*log10(getBandMeanPowerSpectralDensity(linLevel, PARAMS.ltsa.fs/PARAMS.ltsa.nfft, F(1), ...
    %     firstBand, lastBand, freqTable));

    bandsOut(isinf(bandsOut)) = NaN;
    neonCoolToHot = [
        0.00, 0.80, 1.00;  % neon cyan
        0.00, 1.00, 0.50;  % bright green-cyan
        0.20, 1.00, 0.00;  % bright green
        1.00, 1.00, 0.00;  % neon yellow
        1.00, 0.65, 0.00;  % neon orange
        1.00, 0.30, 0.00;  % bright orange-red
        1.00, 0.00, 0.00;  % neon red
        1.00, 0.20, 0.50;  % pinkish neon red
        1.00, 0.40, 0.70;  % pink-magenta
        ];




    figure(600)
    clf
    % Make figure wider
    set(gcf, 'Position', [100, 100, 1200, 600])  % [left, bottom, width, height]
    % First subplot (wider)
    ax1 = axes('Position', [0.08, 0.1, 0.6, 0.8]);  % [left, bottom, width, height]
    surf(ax1, time_matrix, freqTable(:, 2), bandsOut', 'Linestyle', 'none');
    view(ax1, [0 90])
    set(ax1, 'yscale', 'log')
    colormap(ax1, 'jet')
    caxis(ax1, [60 100])  % clim is caxis in axes
    ylabel(ax1, 'Frequency (Hz)')
    xlabel(ax1, 'UTC Time (HH:MM)')
    title(ax1, [PARAMS.ltsa.project ' ' PARAMS.ltsa.site ' Hybrid Millidecade ' datestr(dayStart)])
    datetick(ax1, 'x', 'keeplimits')
    % Compute percentiles across time (columns of bandsOut')
    percentiles = [1 5 10 25 50 75 90 95 99];
    pctVals = prctile(bandsOut', percentiles, 2);  % size: [nFreqBands x nPercentiles]
    % Second subplot (narrower, with y-ticks on right)
    ax2 = axes('Position', [0.72, 0.1, 0.22, 0.8]);  % moved slightly right and narrow
    hold(ax2, 'on')

    % Plot amplitude percentiles vs frequency with semilog y
    for i = 1:length(percentiles)
        semilogy(ax2, pctVals(:, i), freqTable(:, 2), 'LineWidth', 1.2, ...
            'Color', neonCoolToHot(i, :));
    end
    set(ax2, 'YScale', 'log', 'YDir', 'normal', 'YAxisLocation', 'right')
    xlabel(ax2, 'Amplitude (dB re 1\muPa^2/Hz)')
    ylabel(ax2, 'Frequency (Hz)')  % optional, since it's on right side
    grid(ax2, 'on')
    xlim([0 120])
    title(ax2, 'Percentiles')
    legend(ax2, strcat(string(percentiles'), 'th'), 'Location', 'southwest')
    hold(ax2, 'off')


    outName = [...
        PARAMS.ltsa.organization, ...
        '_products_sound_level_metrics_', ...
        PARAMS.ltsa.organization, '_', ...
        PARAMS.ltsa.project, '_', ...
        PARAMS.ltsa.site, '_', ...
        datestr(startDay + years(2000), 'yymmdd'), '-', datestr(endDay + years(2000), 'yymmdd'), ...
        '_hmd_data_', ...
        datestr(dayStart + years(2000), 'yymmdd'), '.nc'];

    outFile = fullfile(PARAMS.ltsa.outputDir, outName);
    fclose('all');


    % Delete file if it exists (and not already open)
    if isfile(outFile)
        try
            delete(outFile);
        catch ME
            warning('Could not delete existing file: %s\n%s', outFile, ME.message);
        end
    end


    ncid = netcdf.create(fullfile(PARAMS.ltsa.outputDir, outName), 'CLOBBER');


    % Define dimensions
    numFreqs = length(freqTable(:, 2));  % number of frequency bins
    timeDimID = netcdf.defDim(ncid, 'time', length(time_matrix));
    freqDimID = netcdf.defDim(ncid, 'frequency', length(freqTable(:, 2)));

    % Define variables
    timeVarID = netcdf.defVar(ncid, 'time', 'double', timeDimID);
    freqVarID = netcdf.defVar(ncid, 'frequency', 'double', freqDimID);
    splVarID = netcdf.defVar(ncid, 'SPL', 'float', [freqDimID, timeDimID]);

    % Put Variables
    netcdf.putVar(ncid, 'time', 'int64', double(time_matrix));
    netcdf.putVar(ncid, 'frequency', 'single', double(freqTable(:, 2));
    netcdf.putVar(ncid, 'SPL', 'float', [freqDimID, timeDimID]);

    % Define metadata attributes
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'title', PARAMS.ltsa.title);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'summary', PARAMS.ltsa.summary);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'history', PARAMS.ltsa.history);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'source', PARAMS.ltsa.source);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'acknowledgements', PARAMS.ltsa.acknowledgements);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'citation', PARAMS.ltsa.citation);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'comment', PARAMS.ltsa.comment);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'conventions', PARAMS.ltsa.conventions);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'creator_name', PARAMS.ltsa.creator_name);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'creator_role', PARAMS.ltsa.creator_role);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'geospatial_bounds', PARAMS.ltsa.geospatial_bounds);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'geospatial_bounds', PARAMS.ltsa.geospatial_bounds);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'id', PARAMS.ltsa.id);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'infoUrl', PARAMS.ltsa.infoUrl);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'institution', PARAMS.ltsa.institution);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'instrument', PARAMS.ltsa.instrument);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'keywords', PARAMS.ltsa.keywords);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'keywords_vocabulary', PARAMS.ltsa.keywords_vocabulary);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'license', PARAMS.ltsa.license);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'naming_authority', PARAMS.ltsa.naming_authority);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'product_version', PARAMS.ltsa.product_version);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'project', PARAMS.ltsa.project);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'publisher_name', PARAMS.ltsa.publisher_name);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'publisher_type', PARAMS.ltsa.publisher_type);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'reference', PARAMS.ltsa.reference);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'standard_name_vocabulary', PARAMS.ltsa.standard_name_vocabulary);

    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'organization', PARAMS.ltsa.organization);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'project', PARAMS.ltsa.project);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'site', PARAMS.ltsa.site);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'sample_rate', PARAMS.ltsa.fs);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'nfft', PARAMS.ltsa.nfft);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'freq_bin_size', PARAMS.ltsa.dfreq);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'timeVarID', PARAMS.ltsa.organization);
    netcdf.endDef(ncid);


    % End definitions
    netcdf.close(ncid);



    % Update progress
    %progress = i / length(allDays);
    %percentStr = sprintf('Processing HMD... %3.0f%% Complete', progress * 100);
    % waitbar(progress, hWait, percentStr);
    %drawnow;

end
% if ishandle(hWait)
%     delete(hWait);
% end

%% create daily netCDF file




% Now read data only between fileClipStart and fileClipEnd,
% then compute pwelch with 1-sec window and 1-Hz bins,
% average over minutes, and save to netcdf.
end


% test2 = ncinfo('D:\HMD\MBARC_products_sound_level_metrics_MBARC_CINMS_B_230919-231113_hmd_data_230919.nc')

test = ncinfo('D:\HMD\mbari_products_sound_level_metrics_mbari-mars_20210101-20211231_hmd_data_MARS_20210125.nc');
% test3 = ncinfo('D:\HMD\onms_products_sound_level_metrics_sb03_onms_sb03_20230731-20231208_hmd_data_ONMS_SB03_20230731_7852.1.48000_20230731_DAILY_MILLIDEC_MinRes.nc');
