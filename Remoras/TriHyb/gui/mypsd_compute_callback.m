function mypsd_compute_callback(~, ~)

1; 
clear global PARAMS
global REMORA PARAMS

PARAMS.metadata.inputDir = get(REMORA.mypsd.gui.InputDirectory_, 'String');
PARAMS.metadata.recursiveSearch = REMORA.mypsd.gui.recursiveSearchValue;
PARAMS.metadata.FilenamePattern_ = get(REMORA.mypsd.gui.FilenamePattern_, 'String');
PARAMS.metadata.outputDir = get(REMORA.mypsd.gui.OutputDirectory_, 'String');


% HARP INFO
PARAMS.metadata.organization = get(REMORA.mypsd.gui.Organization_, 'String');
PARAMS.metadata.site = get(REMORA.mypsd.gui.SiteName_, 'String');
PARAMS.metadata.project = get(REMORA.mypsd.gui.Project_, 'String');
PARAMS.metadata.deployment = get(REMORA.mypsd.gui.Deployment__, 'String');
PARAMS.metadata.startDep = get(REMORA.mypsd.gui.startDep, 'String');
PARAMS.metadata.endDep = get(REMORA.mypsd.gui.endDep, 'String');

PARAMS.metadata.tfFilePath = get(REMORA.mypsd.gui.TransferFunctionFile_, 'String');
PARAMS.metadata.startF = get(REMORA.mypsd.gui.startFreq, 'String');
PARAMS.metadata.endF = get(REMORA.mypsd.gui.endFreq, 'String');
PARAMS.metadata.minPrct = get(REMORA.mypsd.gui.MinimumEffortForMinuteBin____, 'String');
latlon = str2double(strsplit(erase(erase(get(REMORA.mypsd.gui.SiteLocation_, 'String'), '['), ']'), ','));
[PARAMS.metadata.latitude, PARAMS.metadata.longitude] = deal(latlon(1), latlon(2));

% Plot the location on a geographic map
figure(500)
geoplot(PARAMS.metadata.latitude, PARAMS.metadata.longitude, 'p', 'MarkerSize', 30, ...
    'MarkerFaceColor', [1.0, 0.6, 0.8] , ...
    'MarkerEdgeColor', 'k', ...
    'LineWidth', 1.5);
geobasemap satellite

% Set map limits around the point
latBuffer = 5;
lonBuffer = 5;
geolimits([PARAMS.metadata.latitude - latBuffer, PARAMS.metadata.latitude + latBuffer], [PARAMS.metadata.longitude - lonBuffer, PARAMS.metadata.longitude + lonBuffer]);
title([PARAMS.metadata.organization ' ' PARAMS.metadata.project ' ' PARAMS.metadata.site ' ' PARAMS.metadata.deployment])
outNameMap = [
    PARAMS.metadata.organization, '_', ...
    PARAMS.metadata.project, '_', ...
    PARAMS.metadata.site, '_', ...
    PARAMS.metadata.deployment, '_', 'siteMap.png'];
outFileMap = fullfile(PARAMS.metadata.outputDir, outNameMap);

saveas(gcf, outFileMap);


% META DATA
PARAMS.metadata.title = get(REMORA.mypsd.gui.Title, 'String');
PARAMS.metadata.summary = get(REMORA.mypsd.gui.Summary, 'String');
PARAMS.metadata.history = get(REMORA.mypsd.gui.History, 'String');
PARAMS.metadata.source = get(REMORA.mypsd.gui.Source, 'String');
PARAMS.metadata.acknowledgements = get(REMORA.mypsd.gui.Acknowledgements, 'String');
PARAMS.metadata.citation = get(REMORA.mypsd.gui.Citation, 'String');
PARAMS.metadata.comment = get(REMORA.mypsd.gui.Comment, 'String');
PARAMS.metadata.conventions = get(REMORA.mypsd.gui.Conventions, 'String');
PARAMS.metadata.creator_name = get(REMORA.mypsd.gui.Creator_Name, 'String');
PARAMS.metadata.creator_role = get(REMORA.mypsd.gui.Creator_Role, 'String');
PARAMS.metadata.creator_url = get(REMORA.mypsd.gui.Creator_URL, 'String');

PARAMS.metadata.id = get(REMORA.mypsd.gui.ID, 'String');
PARAMS.metadata.institution = get(REMORA.mypsd.gui.Institution, 'String');
PARAMS.metadata.instrument = get(REMORA.mypsd.gui.Instrument, 'String');
PARAMS.metadata.keywords = get(REMORA.mypsd.gui.Keywords, 'String');
PARAMS.metadata.keywords_vocabulary = get(REMORA.mypsd.gui.Keywords_Vocabulary, 'String');
PARAMS.metadata.license = get(REMORA.mypsd.gui.License, 'String');
PARAMS.metadata.naming_authority = get(REMORA.mypsd.gui.Naming_Authority, 'String');
PARAMS.metadata.product_version = get(REMORA.mypsd.gui.Product_Version, 'String');
PARAMS.metadata.publisher_name = get(REMORA.mypsd.gui.Publisher_Name, 'String');
PARAMS.metadata.publisher_url = get(REMORA.mypsd.gui.Publisher_URL, 'String');
PARAMS.metadata.reference = get(REMORA.mypsd.gui.References, 'String');

% Confirm input
disp('-------------------- HARP HMD Input Parameters --------------------')
disp(['Input Dir: ', PARAMS.metadata.inputDir])
disp(['Output Dir: ', PARAMS.metadata.outputDir])
disp(['Organization: ', PARAMS.metadata.organization])
disp(['Project: ', PARAMS.metadata.project])
disp(['Site: ', PARAMS.metadata.site])
disp(['Deployment #: ', PARAMS.metadata.deployment])
disp(['Start Frequency (Hz): ', PARAMS.metadata.startF])
disp(['End Frequency (Hz): ', PARAMS.metadata.endF])

%disp(['File: ',  PARAMS.ltsa.outfname])


% Run actual HMD computation
mypsd_compute
end