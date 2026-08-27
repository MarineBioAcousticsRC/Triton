    function hrp2xwav_paramC(input, k)
        %% hrp2xwav_paramC
        %
        % called by figure_stuffC and proc_guiC in procFunB in HRP Remora in Triton
        %
        % function to get user input and process HRP files into
        % XWAV (including decimation) files.
        %
        % LTSA stuff does not work, so it was taken out.
        % LTSAs are made with mk_ltsa_multidir
        %
        % get info and set up xwav destination folder
        % get info on which rawfiles to process
        % save processing file for another run
        %
        % The GLOBAL or PERSISTENT declaration of "REMORA" appears in a nested function,
        % but should be in the outermost function where it is used
        % So, that is why global is commented out below
        % but now the function is standalone and not inside h2xm_getparamB,
        % so uncomment now...
        %
        global REMORA PARAMS gui_cancel
        
        switch input
            
            case 'get'
                set(REMORA.hrpfig.disk_handles{k}, 'String', uigetdir('\..','Choose XWAV Destination Folder'));
                
            case 'ctn_disk'
                % get string from each of the disk fields
                blanks = false;
                for k = 1:length(REMORA.hrp.dfs)
                    str = get(REMORA.hrpfig.disk_handles{k}, 'String');
                    if isempty(str)
                        set(REMORA.hrpfig.disk_handles{k}, 'BackgroundColor', 'red');
                        blanks = true;
                    else
                        set(REMORA.hrpfig.disk_handles{k}, 'BackgroundColor', 'white');
                    end
                    REMORA.hrp.saveloc{k} = str;
                end
                
                % if missing fields
                if blanks
                    return
                end
                
                % close and resume
                uiresume(REMORA.hrpfig.main);
                delete(REMORA.hrpfig.main);
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'browsebois');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'disk_handles');
                               
            case 'rad_rf'
                state = get(REMORA.hrpfig.wholeradio, 'Value');
                
                % if whole disk selected disable edit boxes
                if state
                    set(REMORA.hrpfig.start,'Enable','off');
                    set(REMORA.hrpfig.end,'Enable','off');
                else
                    set(REMORA.hrpfig.start,'Enable','on');
                    set(REMORA.hrpfig.end,'Enable','on');
                end
                
            case 'ctn_rf'
                blanks = false;
                
                % check for blanks
                for k = 1:size(REMORA.hrp.disks, 1)
                    
                    if isempty(get(REMORA.hrpfig.rf_start{k}, 'String'))
                        set(REMORA.hrpfig.rf_start{k}, 'BackgroundColor', 'r');
                        blanks = true;
                    else
                        try
                            REMORA.hrp.rf_start(k) = str2double(...
                                get(REMORA.hrpfig.rf_start{k}, 'String'));
                            set(REMORA.hrpfig.rf_start{k}, 'BackgroundColor', 'w');
                        catch
                            set(REMORA.hrpfig.rf_start{k}, 'BackgroundColor', 'r');
                            blanks = true;
                        end
                    end
                    if isempty(get(REMORA.hrpfig.rf_end{k}, 'String'))
                        set(REMORA.hrpfig.rf_end{k}, 'BackgroundColor', 'r');
                        blanks = true;
                    else
                        try
                            REMORA.hrp.rf_end(k) = str2double(...
                                get(REMORA.hrpfig.rf_end{k}, 'String'));
                            set(REMORA.hrpfig.rf_end{k}, 'BackgroundColor', 'w');
                        catch
                            set(REMORA.hrpfig.rf_end{k}, 'BackgroundColor', 'r');
                            blanks = true;
                        end
                    end
                    str = get(REMORA.hrpfig.rf_skip{k}, 'String');
                    str = strsplit(str, {',',', '});
                    for v = 1:length(str)
                        rf = str2num(str{v});
                        REMORA.hrp.rf_skip{k} = [REMORA.hrp.rf_skip{k}, rf];
                    end
                end
                
                % return for rest of numbers or continue; clear REMORA fields
                if blanks
                    return;
                end
                
                uiresume(REMORA.hrpfig.main);
                delete(REMORA.hrpfig.main);
                
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'rf_start');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'rf_end');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'rf_skip');
                
            case 'enb'
                state = get(REMORA.hrpfig.fix_rad, 'Value');
                if state
                    set(REMORA.hrpfig.fix_files_rad, 'Enable', 'on');
                else
                    set(REMORA.hrpfig.fix_files_rad, 'Enable', 'off');
                    set(REMORA.hrpfig.fix_files_rad, 'Value', 0);
                end
                
            case 'save'
                % don't want to save figure handles so temporarily remove
                temp = REMORA.hrpfig;
                REMORA = rmfield(REMORA,'hrpfig');
                
                try
                    name = 'my_procparams';
                    [savefile, savepath] = uiputfile('*.mat', 'Save processing parameter file',name);
                    save(fullfile(savepath, savefile), 'REMORA', 'PARAMS');
                catch
                    disp('Invalid file selected or cancel button pushed.')
                end
                % fix REMORA field
                REMORA.hrpfig = temp;
                
            case 'go'
                REMORA.hrp.fixTimes = get(REMORA.hrpfig.fix_rad, 'Value');
                REMORA.hrp.rmfifo = get(REMORA.hrpfig.rmfifo_rad, 'Value');
                REMORA.hrp.resumeDisk = get(REMORA.hrpfig.resume_rad, 'Value');
                PARAMS.dflag = get(REMORA.hrpfig.disp_rad, 'Value');
                REMORA.hrp.diary_bool = get(REMORA.hrpfig.diary_rad, 'Value');
                REMORA.hrp.use_mod = get(REMORA.hrpfig.fix_files_rad, 'Value');
                
                uiresume(REMORA.hrpfig.main);
                delete(REMORA.hrpfig.main);
                
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'fix_rad');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'rmfifo_rad');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'resume_rad');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'disp_rad');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'diary_rad');
                REMORA.hrpfig = rmfield(REMORA.hrpfig, 'fix_files_rad');
            case 'close_cancel'
                uiresume(gcf);
                delete(gcf);
                gui_cancel = 1;
                
        end  % end switch
        
    end  % end function h2xm_getparamC