function mypsd_run(option)
    switch option
        case 'compute'
            mypsd_gui;
        otherwise
            error('Unknown option in mypsd_run: %s', option);
    end
end