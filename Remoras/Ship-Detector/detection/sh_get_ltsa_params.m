function sh_get_ltsa_params

global REMORA PARAMS

REMORA.sh.ltsa.durWind = PARAMS.ltsa.tseg.sec;
REMORA.sh.ltsa.tave = PARAMS.ltsa.tave;
REMORA.sh.ltsa.nave = PARAMS.ltsa.nave;
REMORA.sh.ltsa.fimin = PARAMS.ltsa.fimin;
REMORA.sh.ltsa.fmax = PARAMS.ltsa.fmax;
REMORA.sh.ltsa.dfreq = PARAMS.ltsa.dfreq;
REMORA.sh.ltsa.freq = PARAMS.ltsa.freq;
REMORA.sh.ltsa.dnumSnippet = PARAMS.ltsa.plot.dnum;
