function pwr = fn_readPwrSnippet(start,stop)

global REMORA

fid = fopen(fullfile(REMORA.ship_dt.ltsa.inpath, REMORA.ship_dt.ltsa.infile));
fseek(fid, REMORA.ship_dt.ltsa.byteloc(start), -1);    % position for read
pwr = fread(fid, [REMORA.ship_dt.ltsa.nf, ...
    sum(REMORA.ship_dt.ltsa.nave(start:stop))], 'int8');
fclose(fid);