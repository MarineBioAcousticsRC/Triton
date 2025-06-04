function mypsd_run(option)
    switch option
        case 'gui'
            mypsd_gui;
        otherwise
            error('Unknown option in mypsd_run: %s', option);
    end
end