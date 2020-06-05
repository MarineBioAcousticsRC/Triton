function searchIcon = nn_ui_search_icon

[myPath,~] = fileparts(mfilename('fullpath'));
iconFile = strrep(myPath,'Remoras\NNet\ui','Extras\icons\mag_glass.png');
[X,aMap] = imread(iconFile,'BackgroundColor' ,[1,1,1]);
searchIcon = imresize(ind2rgb(X,aMap),0.02, 'nearest');