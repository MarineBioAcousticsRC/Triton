function sm_write_netcdf_init(lIdx)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% sm_write_netcdfHead.m
%
% setup values for ltsa file and write header + directories for netcdf ltsa
% file
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CMS NOTES: INSERT BREAKPOINT HERE TO STOP CODE AFTER FINISHING A SINGLE
% LTSA!!
global PARAMS

fname = [PARAMS.ltsa.organization, '_', ...
    PARAMS.ltsa.project, '_', ...
    PARAMS.ltsa.site, '_', ...
    PARAMS.ltsa.deployment, '_', ...
    fnum,'.nc'];

PARAMS.ltsa.outfile = fname;

    ncid = netcdf.create(PARAMS.ltsa.outfile, 'NETCDF4');

    % Define dimensions
    numFreqs = PARAMS.ltsa.nfreq;
    maxTimes = 100000; % can be unlimited if needed
    timeDimID = netcdf.defDim(ncid, 'time', netcdf.getConstant('NC_UNLIMITED'));
    freqDimID = netcdf.defDim(ncid, 'frequency', numFreqs);

    % Define variables
    timeVarID = netcdf.defVar(ncid, 'time', 'double', timeDimID);
    freqVarID = netcdf.defVar(ncid, 'frequency', 'double', freqDimID);
    splVarID = netcdf.defVar(ncid, 'SPL', 'float', [freqDimID, timeDimID]);

    % Define metadata attributes
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'organization', PARAMS.ltsa.organization);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'project', PARAMS.ltsa.project);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'site', PARAMS.ltsa.site);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'deployment', PARAMS.ltsa.deployment);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'sample_rate', PARAMS.ltsa.fs);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'nfft', PARAMS.ltsa.nfft);
    netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'freq_bin_size', PARAMS.ltsa.dfreq);

    % End definitions
    netcdf.endDef(ncid);

    % Save NetCDF ID for later write
    PARAMS.ltsa.ncid = ncid;
    PARAMS.ltsa.splVarID = splVarID;
    PARAMS.ltsa.timeVarID = timeVarID;
end