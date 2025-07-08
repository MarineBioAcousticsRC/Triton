function mypsd_compute_callback(~, ~)
global REMORA PARAMS

PARAMS.ltsa.inputDir = get(REMORA.mypsd.gui.InputDirectory_, 'String');
PARAMS.ltsa.outputDir = get(REMORA.mypsd.gui.OutputDirectory_, 'String');

% HARP INFO
PARAMS.ltsa.organization = get(REMORA.mypsd.gui.Organization_, 'String');
PARAMS.ltsa.site = get(REMORA.mypsd.gui.SiteName_, 'String');
PARAMS.ltsa.project = get(REMORA.mypsd.gui.Project_, 'String');
PARAMS.ltsa.deployment = get(REMORA.mypsd.gui.Deployment__, 'String');
PARAMS.ltsa.startDep = get(REMORA.mypsd.gui.startDep, 'String');
PARAMS.ltsa.endDep = get(REMORA.mypsd.gui.endDep, 'String');

PARAMS.tfFilePath = get(REMORA.mypsd.gui.TransferFunctionFile_, 'String');
PARAMS.ltsa.startF = get(REMORA.mypsd.gui.startFreq, 'String');
PARAMS.ltsa.endF = get(REMORA.mypsd.gui.endFreq, 'String');
PARAMS.ltsa.minPrct = get(REMORA.mypsd.gui.MinimumEffortForMinuteBin____, 'String');
latlon = str2double(strsplit(erase(erase(get(REMORA.mypsd.gui.SiteLocation_, 'String'), '['), ']'), ','));
[PARAMS.ltsa.latitude, PARAMS.ltsa.longitude] = deal(latlon(1), latlon(2));

% Plot the location on a geographic map
figure(500)
geoplot(PARAMS.ltsa.latitude, PARAMS.ltsa.longitude, 'p', 'MarkerSize', 30, ...
    'MarkerFaceColor', [1.0, 0.6, 0.8] , ...
    'MarkerEdgeColor', 'k', ...
    'LineWidth', 1.5);
geobasemap satellite

% Set map limits around the point
latBuffer = 5;
lonBuffer = 5;
geolimits([PARAMS.ltsa.latitude - latBuffer, PARAMS.ltsa.latitude + latBuffer], [PARAMS.ltsa.longitude - lonBuffer, PARAMS.ltsa.longitude + lonBuffer]);
title([PARAMS.ltsa.organization ' ' PARAMS.ltsa.project ' ' PARAMS.ltsa.site ' ' PARAMS.ltsa.deployment])
outNameMap = [
    PARAMS.ltsa.organization, '_', ...
    PARAMS.ltsa.project, '_', ...
    PARAMS.ltsa.site, '_', ...
    PARAMS.ltsa.deployment, '_', 'siteMap.png'];
outFileMap = fullfile(PARAMS.ltsa.outputDir, outNameMap);

saveas(gcf, outFileMap);


% META DATA
PARAMS.ltsa.title = get(REMORA.mypsd.gui.Title, 'String');
PARAMS.ltsa.summary = get(REMORA.mypsd.gui.Summary, 'String');
PARAMS.ltsa.history = get(REMORA.mypsd.gui.History, 'String');
PARAMS.ltsa.source = get(REMORA.mypsd.gui.Source, 'String');
PARAMS.ltsa.acknowledgements = get(REMORA.mypsd.gui.Acknowledgements, 'String');
PARAMS.ltsa.citation = get(REMORA.mypsd.gui.Citation, 'String');
PARAMS.ltsa.comment = get(REMORA.mypsd.gui.Comment, 'String');
PARAMS.ltsa.conventions = get(REMORA.mypsd.gui.Conventions, 'String');
PARAMS.ltsa.creator_name = get(REMORA.mypsd.gui.Creator_Name, 'String');
PARAMS.ltsa.creator_role = get(REMORA.mypsd.gui.Creator_Role, 'String');
PARAMS.ltsa.creator_url = get(REMORA.mypsd.gui.Creator_URL, 'String');

PARAMS.ltsa.id = get(REMORA.mypsd.gui.ID, 'String');
PARAMS.ltsa.institution = get(REMORA.mypsd.gui.Institution, 'String');
PARAMS.ltsa.instrument = get(REMORA.mypsd.gui.Instrument, 'String');
PARAMS.ltsa.keywords = get(REMORA.mypsd.gui.Keywords, 'String');
PARAMS.ltsa.keywords_vocabulary = get(REMORA.mypsd.gui.Keywords_Vocabulary, 'String');
PARAMS.ltsa.license = get(REMORA.mypsd.gui.License, 'String');
PARAMS.ltsa.naming_authority = get(REMORA.mypsd.gui.Naming_Authority, 'String');
PARAMS.ltsa.product_version = get(REMORA.mypsd.gui.Product_Version, 'String');
PARAMS.ltsa.publisher_name = get(REMORA.mypsd.gui.Publisher_Name, 'String');
PARAMS.ltsa.publisher_url = get(REMORA.mypsd.gui.Publisher_URL, 'String');
PARAMS.ltsa.reference = get(REMORA.mypsd.gui.Reference, 'String');







% set for HARP hybrid millidecade soundscape metrics
PARAMS.ltsa.ftype = 2;      % 1= WAVE, 2=XWAV
PARAMS.ltsa.dtype = 1;      % 1 = HARP, 2 = ARP, 3 = OBS, 4 = towed array or sonobuoy, 5 = SoundTrap
PARAMS.ltsa.dfreq = 1;      % frequency bin size [Hz]
PARAMS.ltsa.nstart = 1;     % start number of LTSA file (e.g. want to start at week 2)

PARAMS.ltsa.tave = 1;       % averaging time [seconds]
% Confirm input
disp('-------------------- HARP HMD Input Parameters --------------------')
disp(['Input Dir: ', PARAMS.ltsa.inputDir])
disp(['Output Dir: ', PARAMS.ltsa.outputDir])
disp(['Organization: ', PARAMS.ltsa.organization])
disp(['Project: ', PARAMS.ltsa.project])
disp(['Site: ', PARAMS.ltsa.site])
disp(['Deployment #: ', PARAMS.ltsa.deployment])
disp(['Start Frequency (Hz): ', PARAMS.ltsa.startF])
disp(['End Frequency (Hz): ', PARAMS.ltsa.endF])

%disp(['File: ',  PARAMS.ltsa.outfname])


% Run actual HMD computation
mypsd_compute
end