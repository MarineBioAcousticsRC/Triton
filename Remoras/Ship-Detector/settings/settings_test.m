% settings_ship_detector

% Settings script for ship_detector

settings.outDir = '';

settings.tfFullFile = '';

% DETECTOR PARAMETERS 

settings.lowBand = [1000,5000];
settings.lowBand = [5000,10000];
settings.lowBand = [10000,50000];

settings.thrClose = 150;
settings.thrDistant = 250;
settings.thrRL = 0.1;
settings.minPassage = 0.5;
settings.buffer = 5;

settings.durWind = 2;
settings.slide = 0.5;
settings.errorRange = 0.1;

settings.diskWrite = true;
settings.dutyCycle = false;
settings.saveLabels = true;

