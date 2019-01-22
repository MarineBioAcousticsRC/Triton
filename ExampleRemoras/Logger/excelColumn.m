function val = excelColumn(n)
% Convert from number to base 26 (Alphabetic)
% Columns are indiced from 0:  excelColumn(0) = 'A'

val = [];

base = 26;
% Build up an array in val of the specified base
% At the end, val(i) represents the base^(i-1) value
done = false;
while ~ done
    leftover = rem(n, base);
    n = floor(n / base);
    done = n <= 0;
    val(end+1) = leftover;
end
% Convert to a string and flip so that the
% base^{highest power comes first}
if length(val) > 1
    % After Z, Excel numbers AA AB etc.  Since B=1 we need to decrement
    val(2:end) = val(2:end) - 1;
end
val = char('A' + val);
val = fliplr(val);