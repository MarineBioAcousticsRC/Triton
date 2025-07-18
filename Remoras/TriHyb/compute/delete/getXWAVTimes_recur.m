function getXWAVTimes_recur

global PARAMS



if PARAMS.metadata.recursiveSearch == 1
    lffn = dir(fullfile(PARAMS.metadata.inputDir, '**', [PARAMS.metadata.FilenamePattern_ '.ltsa']));
elseif PARAMS.metadata.recursiveSearch == 0
    lffn = dir(fullfile(PARAMS.metadata.inputDir, '*.ltsa'));    % xwav files
end


%lffn = dir(fullfile(inDir, flag));


PARAMS.fname = '';
PARAMS.ltsa.xtimes = [];
Y2K = datenum([2000 0 0 0 0 0 ]);
xfn_len = 80; % LTSA ver < 4 will have 40 char long filenames that will need to be padded
xffn_len = 200; % want to save full path name
for l=1:length(lffn)
        
        fprintf('\n\t%s\n', [lffn(l).folder, '\', lffn(l).name]);
        linfo = dir([lffn(l).folder, '\', lffn(l).name]);
        [ p, f, e ] = fileparts([lffn(l).folder, '\', lffn(l).name]);
        clear PARAMS;
        global PARAMS;
        PARAMS.ltsa.inpath = p;
        PARAMS.ltsa.infile = sprintf('%s%s',f,e); 
        read_ltsahead;
        
        % found LTSA with zeros in filenames?! CINMS_B_30_00_disk04_5s_10Hz_df20.ltsa
        zi = find(sum(PARAMS.ltsahd.fname,2)==0);
        if ~isempty(zi)
            fprintf('\tLTSA has empty %d filenames in header\n',length(zi));
            PARAMS.ltsa.dnumStart(zi) = [];
            PARAMS.ltsa.dnumEnd(zi) = [];
            PARAMS.ltsahd.fname(zi,:) = [];
            PARAMS.ltsa.nrftot = length(PARAMS.ltsa.dnumStart);
        end

        % need to deal with varying lengths in filename fields
        [uxwav,If,Iu] = unique(PARAMS.ltsahd.fname,'rows');
        uxwav = char(uxwav);
        [ p1,f1,e1 ] = fileparts(uxwav(1,:));
        if strcmp(e1,'.w') && size(uxwav,2)==40
            padStr = char(repmat([ double('av') zeros(1,38) ],size(uxwav,1),1));
            uxwav = [ uxwav, padStr ];
        elseif size(uxwav,2)<80
            nPad = xfn_len - size(uxwav,2);
            padStr = char(zeros(size(uxwav,1),nPad));
            uxwav = [ uxwav, padStr ];
        end
        
        % include pathname and pad to get equal sizes
        uxwav = arrayfun(@(x) fullfile(p,uxwav(x,:)),1:size(uxwav,1),'UniformOutput',0);
        uxwav = vertcat(uxwav{:});
        nPad = xffn_len - size(uxwav,2);
        padStr = char(zeros(size(uxwav,1),nPad));
        uxwav = [ uxwav, padStr ];
        
        si = If; 
        ei = [ If(2:end)-1; PARAMS.ltsa.nrftot ];
        PARAMS.fname = vertcat( PARAMS.fname, uxwav);
        PARAMS.ltsa.xtimes = vertcat( PARAMS.ltsa.xtimes,...
            [ PARAMS.ltsa.dnumStart(si)'+Y2K, PARAMS.ltsa.dnumEnd(ei)'+Y2K ] );
        
end
% 
% % odir = 'G:\ShippingCINMS\wavInfo';
% % odir = 'P:\ShippingCINMS\wavInfo_COPsmw';
% t0 = min(xtimes(:,1));
% tn = max(xtimes(:,2));
% ofn = sprintf('CINMS_B_xwavInfo_%s_to_%s.mat', datestr(t0,'yymmdd'),datestr(tn,'yymmdd'));
% save(fullfile(odir,ofn),'xwavs','xtimes');
% 1;