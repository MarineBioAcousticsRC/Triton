function msgs = disp_headSummary(nfiles)
%
%
% display PARAMS.headall structure in useful format...
%
% 061031 smw
%
global PARAMS

disp_msg(' ');
disp_msg('HARP *head.hrp disk header values');
disp_msg(' ');
disp_msg(sprintf('Directory : %s',PARAMS.inpath));
disp_msg(sprintf('Number of *head.hrp files : %d',nfiles));
disp_msg(sprintf('Evaluation Date : %s',datestr(date,29)));


% disp_msg(['Disk Number            ',sprintf('%8d',PARAMS.headall.disknumberSector0)])
% disp_msg(['1st Dir Loc   [sect] : ',sprintf('%8d',PARAMS.headall.firstDirSector)])
% disp_msg(['Curr Dir Loc  [sect] : ',sprintf('%8d',PARAMS.headall.currDirSector)])
% disp_msg(['1st File Loc  [sect] : ',sprintf('%8d',PARAMS.headall.firstFileSector)])
% disp_msg(['Curr File Loc [sect] : ',sprintf('%8d',PARAMS.headall.nextFileSector)])

sectors = [PARAMS.headall.disknumberSector0; ...
    PARAMS.headall.firstDirSector ; PARAMS.headall.currDirSector; ...
    PARAMS.headall.firstFileSector; PARAMS.headall.nextFileSector; ...
    PARAMS.headall.unusedSector; PARAMS.headall.disksizeSector];

disp_msg(' ');
disp_msg('Sectors : ');
disp_msg(' ');
disp_msg('Disk        1st      Curr      1st       Next      Disk      Disk');
disp_msg(' #          Dir      Dir       File      File      Unused    Size');
disp_msg((num2str(sectors')));


disp_msg(' ');
disp_msg('Timing Evaluation : ');
disp_msg(' ');

disp_msg(sprintf('Eval Sample Rate : %d kHz',PARAMS.rec.sr));
disp_msg(sprintf('Eval Interval    : %0.2f min',PARAMS.rec.int));
disp_msg(sprintf('Eval Duration    : %0.2f min',PARAMS.rec.dur));
disp_msg(sprintf('RF Duration    : %0.2f sec',PARAMS.rec.dtime1));
disp_msg(sprintf('Duty-cycle Gap Duration    : %0.2f sec',PARAMS.rec.dtime2));
disp_msg(' ');

timeEval = [PARAMS.headall.disknumberSector2; ...
    PARAMS.headall.nextFile; PARAMS.headall.maxFile; ...
    PARAMS.headall.numTimingErrors];

disp_msg('Disk Next Max   Num');
disp_msg(' #   File File  TE');
disp_msg(num2str(timeEval'));
disp_msg(' ');

% disp_msg(' ')
% disp_msg('Misc : ')
% disp_msg(' ')
% 
% misc1 = [ PARAMS.headall.disknumberSector2; PARAMS.headall.samplerate];
% 
% disp_msg('Disk            Sample        Firmware     Disk')
% disp_msg(' #              Rate          Version      Type')
% disp_msg([num2str(misc1)', PARAMS.headall.firmwareVersion , PARAMS.headall.disktype])
% disp_msg(' ')


    

