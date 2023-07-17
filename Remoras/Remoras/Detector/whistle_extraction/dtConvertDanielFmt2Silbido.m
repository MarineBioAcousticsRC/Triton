function dtConvertDanielFmt2Silbido(filenames)

newpath = fullfile(getenv('USERPROFILE'), 'matlab', 'triton', 'java');
olddir = fileparts(mfilename);

javarmpath(newpath);
for idx=1:length(filenames)
    clear java
    javarmpath(newpath);
    javaaddpath(oldpath);
    tonals = dtDanielTonalsLoad(filenames{idx});
    mtonals = struct('time', cell(tonals.size(),1))
    for tidx = 0:tonals.size()-1
        atonal = tonals.get(tidx);
        mtonals(tidx+1).time = atonal.get_time();
        mtonals(tidx+1).freq = atonal.get_freq();
        mtonals(tidx+1).snr = atonal.get_snr();
    end
    clear tonals
    clear java
    javarmpath(oldpath)
    javaaddpath(newpath);
    
end