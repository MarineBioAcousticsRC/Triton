function result = dbGetTableDap(dom)

domHdr = dbXPathDomQuery(dom, 'Table/header');
domHdrItems = domHdr.item(0);
hdrLen = domHdrItems.getLength();

%result.hdr = struct('name', cell(hdrLen,1), 'type', cell(hdrLen,1), 'units', cell(hdrLen, 1));
result.Columns.names = cell(hdrLen, 1);
result.Columns.types = cell(hdrLen, 1);
result.Columns.units = cell(hdrLen, 1);
for hidx = 1:hdrLen
    domHdrItem = domHdrItems.item(hidx-1);
    attributes = domHdrItem.getAttributes();
    for aidx = 1:attributes.getLength()
         attr = regexp(char(attributes.item(aidx-1)), '(?<name>.*)="(?<val>.*)"', 'names');
         switch attr.name
             case 'type'
                 result.Columns.types{hidx} = attr.val;
             case 'units'
                 result.Columns.units{hidx} = attr.val;
         end
    end
    result.Columns.names{hidx}= char(domHdrItem.getNodeName());
end

% Extract data
for hidx=1:hdrLen
    fname = result.Columns.names{hidx};
    domData = dbXPathDomQuery(dom, sprintf('Table/row/%s', fname));
    dataLen = domData.getLength();
    if strcmp(result.Columns.types{hidx}, 'String')
        result.Data.(fname) = cell(dataLen,1);
        for didx = 1:dataLen
            value = char(dbDomGetValue(domData.item(didx - 1)));
            result.Data.(fname){didx} = value;
        end
        if strcmp(result.Columns.units{hidx}, 'UTC')
            result.Columns.types{hidx} = 'datenum';
            result.Data.(fname) = ...
                dbISO8601toSerialDate(result.Data.(fname));
        end
    else
        result.Data.(fname) = zeros(dataLen,1);
        for didx = 1:dataLen
            value = dbDomGetValue(domData.item(didx - 1));
            if isempty(value)
                value = NaN;
            else
                value = str2double(value);
            end
            result.Data.(fname)(didx) = value;
        end
    end
end

result.rows = dataLen;

1;

