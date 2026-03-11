function value = dbDomGetValue(domItem, idx)
if domItem.hasChildNodes()
    value = domItem.getFirstChild().getNodeValue();
else
    value = [];
end