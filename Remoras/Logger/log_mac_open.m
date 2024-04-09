function log_mac_open(MetadataNames,MetadataValues)

%function for opening logger spreadsheet in mac
% Annebelle Kok, 8 April 2024

% MetadataNames and MetadataValues contain an optional pair of cell arrays
% with a set of field names and their corresponding values for the Metadata
% shee in the active log file
% Valid names and values depend upon the spreadsheet template that is used
% for the logger, but the following example indicates things some of the
% fields for which this was developed:
%
% log_start({'User ID', 'Project', 'Site'}, {'ritter', 'SOCAL', 'A'});
% If this is a continued log sheeet, use
% log_start(); 


global handles HANDLES

%[num,txt] = xlsread(handles.logfile);
Detections = readtable(handles.logfile,'Sheet','Detections',"VariableUnitsRange" , 1);
AdhocDetections = readtable(handles.logfile,'Sheet','AdhocDetections',"VariableUnitsRange" , 1);
Metadata = readtable(handles.logfile,'Sheet','MetaData',"VariableUnitsRange" , 1);

% Fill out Metadata
Metadata.UserID = MetadataValues{2};
Metadata.DeploymentId = MetadataValues{1};
Metadata.EffortStart = MetadataValues{3};


set(handles.logcallgui, 'CloseRequestFcn', @log_closewindow)

for f = {'main', 'ctrl', 'msg'}
    field = f{1};
    handles.log.oldclosefn.(field) = get(HANDLES.fig.(field), 'CloseRequestFcn');
    set(HANDLES.fig.(field), 'CloseRequestFcn', @log_closewindow);
end

handles.Meta.Sheet = Metadata;
%colsN = length(Metadata.Properties.VariableNames);
%lastCol = excelColumn(colsN);
handles.Meta.Headers = Metadata.Properties.VariableNames;

handles.OnEffort.Sheet = Detections;
handles.OnEffort.Sheet.InputFile = categorical(handles.OnEffort.Sheet.InputFile);
handles.OnEffort.Sheet.EventNumber = categorical(handles.OnEffort.Sheet.EventNumber);
handles.OnEffort.Sheet.SpeciesCode = categorical(handles.OnEffort.Sheet.SpeciesCode);
handles.OnEffort.Sheet.Call = categorical(handles.OnEffort.Sheet.Call);
handles.OnEffort.Sheet.Comments = categorical(handles.OnEffort.Sheet.Comments);
handles.OnEffort.Sheet.Image = categorical(handles.OnEffort.Sheet.Image);
handles.OnEffort.Sheet.Audio = categorical(handles.OnEffort.Sheet.Audio);
%colsN = length(Detections.Properties.VariableNames);
%headerCols = handles.OnEffort.Sheet.Range(sprintf('A1:%s1', ...
 %   excelColumn(colsN-1)));
handles.OnEffort.Headers = Detections.Properties.VariableNames;
handles.OnEffort.ParamCols = {'G1','H1','I1','J1','K1','L1'};

handles.OffEffort.Sheet = AdhocDetections;
handles.OffEffort.Sheet.InputFile = categorical(handles.OffEffort.Sheet.InputFile);
handles.OffEffort.Sheet.EventNumber = categorical(handles.OffEffort.Sheet.EventNumber);
handles.OffEffort.Sheet.SpeciesCode = categorical(handles.OffEffort.Sheet.SpeciesCode);
handles.OffEffort.Sheet.Call = categorical(handles.OffEffort.Sheet.Call);
handles.OffEffort.Sheet.Comments = categorical(handles.OffEffort.Sheet.Comments);
handles.OffEffort.Sheet.Image = categorical(handles.OffEffort.Sheet.Image);
handles.OffEffort.Sheet.Audio = categorical(handles.OffEffort.Sheet.Audio);
%colsN = length(AdhocDetections.Properties.VariableNames);
%headerCols = handles.OffEffort.Sheet.Range(sprintf('A1:%s1', ...
%    excelColumn(colsN-1)));
handles.OffEffort.Headers = AdhocDetections.Properties.VariableNames;
handles.OffEffort.ParamCols = {'G1','H1','I1','J1','K1','L1'};

for fname = {'imagedir', 'audiodir'}
    field = fname{1};
    if ~exist(handles.log.(field), 'dir')
        [retval, msg] = mkdir(handles.log.(field));
        if ~ retval
            errordlg('Unable to create %s\n%s', handles.log.(field), msg);
        end
    end
end

handles.Meta.file_tag = handles.Meta.Sheet.DeploymentId;
