function sh_init_ltsa_params
% sh_init_ltsa_params()
% Initialize LTSA parameters.

global PARAMS REMORA

% If we have an open LTSA, use the input directory to initialize the path
% to the metadata directory, save other directory in case user switches

if isempty(PARAMS.ltsa.inpath) || isempty(PARAMS.ltsa.infile)
    error('Load first an LTSA file');  % No LTSA, use current directory
end

REMORA.sh.ltsa.inpath = PARAMS.ltsa.inpath;
REMORA.sh.ltsa.infile = PARAMS.ltsa.infile;

sh_read_ltsa_header;
