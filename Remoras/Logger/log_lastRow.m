function last = log_lastRow(sheetH)
% last = log_lastRow(sheetH)
% Given a handle to an excel worksheet, return the last used row.
if ismac
    [last,~] = size(sheetH);
    
else
   last = sheetH.UsedRange.Rows.Count;
end