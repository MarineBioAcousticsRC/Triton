function corpus = bhavesh_corpus()

corpus.rootdir = 'd:/home/bioacoustics/Paris-ASA/' ;
% Filenames relative to root and their associated species
corpus.gtfiles = {
    'bottlenose/palmyra092007FS192-070924-205305.wav', 'Tt'
    'bottlenose/palmyra092007FS192-070924-205730.wav', 'Tt'
    'bottlenose/Qx-Tt-SCI0608-N1-060814-121518.wav', 'Tt'
    'spinner/palmyra092007FS192-070927-224737.wav', 'Dl'
    'spinner/palmyra092007FS192-071011-232000.wav', 'Dl'
    'spinner/palmyra102006-061103-213127_4.wav', 'Dl'
    'melon-headed/palmyra092007FS192-070925-023000.wav', 'Pe'
    'melon-headed/palmyra092007FS192-071004-032342.wav', 'Pe'
    'melon-headed/palmyra102006-061020-204327_4.wav', 'Pe'
    'common/QX-Dc-FLIP0610-VLA-061015-165000.wav', 'Dc'
    'common/Qx-Dc-SC03-TAT09-060516-171606.wav', 'Dc'
    'common/Qx-Dc-CC0411-TAT11-CH2-041114-154040-s.wav', 'Dc'
    'common/Qx-Dd-SCI0608-N1-060815-100318.wav', 'Dd'
    'common/Qx-Dd-SCI0608-Ziph-060817-100219.wav', 'Dd'
    'common/Qx-Dd-SCI0608-Ziph-060817-125009.wav', 'Dd'
% $$$     'simone/092007/bottlenose_dolphins/palmyra092007FS192-070924-205305.wav', 'Tt'
% $$$     'simone/092007/bottlenose_dolphins/palmyra092007FS192-070924-205730.wav', 'Tt'
% $$$     'melissa/Qx-Tt-SCI0608-N1-060814-121518.wav', 'Tt'
% $$$     'simone/092007/spinner_dolphins/palmyra092007FS192-070927-224737.wav', 'Dl'
% $$$     'simone/092007/spinner_dolphins/palmyra092007FS192-071011-232000.wav', 'Dl'
% $$$     'simone/102006/spinner_dolphins/palmyra102006-061103-213127_4.wav', 'Dl'
% $$$     'simone/092007/melon-headed_whales/palmyra092007FS192-070925-023000.wav', 'Pe'
% $$$     'simone/092007/melon-headed_whales/palmyra092007FS192-071004-032342.wav', 'Pe'
% $$$     'simone/102006/melon-headed_whales/palmyra102006-061020-204327_4.wav', 'Pe'
% $$$     'melissa/QX-Dc-FLIP0610-VLA-061015-165000.wav', 'Dc'
% $$$     'melissa/Qx-Dc-SC03-TAT09-060516-171606.wav', 'Dc'
% $$$     'melissa/Qx-Dc-CC0411-TAT11-CH2-041114-154040-s.wav', 'Dc'
% $$$     'melissa/Qx-Dd-SCI0608-N1-060815-100318.wav', 'Dd'
% $$$     'melissa/Qx-Dd-SCI0608-Ziph-060817-100219.wav', 'Dd'
% $$$     'melissa/Qx-Dd-SCI0608-Ziph-060817-125009.wav', 'Dd'
    };

% Indicator functions for selecting files

% by region
corpus.geo.names = {'Palmyra', 'SoCal'};
corpus.geo.filenames{1} = ...
    ~ cellfun(@isempty, strfind(corpus.gtfiles(:,1), 'palmyra'));
corpus.geo.filenames{2} = ~ corpus.geo.filenames{1};

% by species
corpus.species.names = unique(corpus.gtfiles(:,2));
for k=1:length(corpus.species.names)
    corpus.species.filenames{k} = ...
        ~ cellfun(@isempty, strfind(corpus.gtfiles(:,2), ...
                            corpus.species.names{k}));
end



    
  

