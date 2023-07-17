function guParseTimestamps(hObject, eventdata, handles)
% parse_timestamps(hObject, eventdata, handles)
% Format timestamp information from current guFileComponent files. 

fileinfo = get(handles.guFileComponent.filelist, 'UserData');
files = fileinfo.files;
nfiles = length(files);

if ~ isempty(files)
  % Extract dates and sort
  try
    dates = dateregexp(files, get(handles.guTimeEncoding.re, 'String'));
  catch
    err = lasterror;
    if strfind(err.Message, 'non-existent field')
      guErrorBacktrace(err, 'Unable to extract timestamps', ...
                       ['The regular expression does not contain a ' ...
                        'needed field such as yr, mon, day, hr, min, or ' ...
                        's.  See Triton documentation for specifying ' ...
                        'time stamps.']);
      % Create default dates.
      dates = datenum([0 1 1 0 0 0]);      % 1-Jan-0000 00:00:00
      dates = dates(ones(length(files), 1));
    else
      error(err)        % couldn't handle, raise to next level
    end
  end

  % Create list showing parsed files and update list
  parsed = cell(nfiles, 1);
  for idx=1:nfiles
    if dates(idx)
      parsed{idx} = sprintf('%s %s', datestr(dates(idx), 0, 'local'), ...
                            files{idx});
    else
      % Display question marks when serial date is at time 0.
      % Note that this code is currently dead.
      parsed{idx} = sprintf('??-???-???? ??:??:?? %s', files{idx});
    end
  end
  % Update filelist with files formatted to include date.
  set(handles.guFileComponent.filelist, 'String', parsed);  % List box files
  

  [dates sortidx] = sort(dates);  % Reorder files according to date
  guFileComponent('permutefiles', sortidx, handles);
  
  files = files(sortidx);
  nfiles = length(files);
  set(handles.guTimeEncoding.re, 'UserData', dates(sortidx));
else
  set(handles.guTimeEncoding.re, 'UserData', []);
end

