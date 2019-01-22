function new_name = xwav_name_check(name, prefix, date_name, time_name)

if size(name,2) > 40 % Warn user if filename will be > 40 chars and truncates (prevents bad ltsas)
        disp_msg('Filename too long: Using truncated name');
        disp('Filename too long: Using truncated name');
        main_chars = [ '*_', date_name ,'_',time_name,'.x.wav']; %following block truncates prefix
        extra_chars = 40 - size(main_chars,2);
        new_prefix = prefix(1:extra_chars);
        new_name =[ new_prefix, main_chars ];
else
        new_name = name;
end