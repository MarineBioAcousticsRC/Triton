function dbTethysDumpXML(q, dir)
% dbTethysDumpXML(queryHandler, OutputDir)
% Given a handle to a Tethys server, write out all XML documents
% contained in the database.  Each collection is processed and the
% documents are placed in a subdirectory associated with the collection.

% Currently wont' process the following Detection documents:
% Problem with " in string, may be a problem with the document
% as not a valid file name, added to issue tracker.
% "SOCAL49M_d05-08 
% Problem with not escaping &
% SOCAL49M_MF_MFA&Communications_aa SOCAL49N_MF_MFA&Communications_aa SOCAL50M_MF_MFA&Communications_ajd OCNMS06QC_MF_HumpbackDetector_ajd&emo OCNMS04QC_MF_HumpbackDetector_ajd&emo OCNMS02QC_MF_HumpbackDetector_ajd&emo OCNMS05QC_MF_HumpbackDetector_ajd&emo OCNMS06QC_HF_SpermWhale_ajd&emo OCNMS05QC_HF_SpermWhale_ajd&emo OCNMS04QC_HF_SpermWhale_ajd&emo OCNMS02QC_MF_SpermWhale_ajd&emo HAT04A_HF_Sonar&Echo_JJ_ajd_edited NFC01A_HF_Sonar&Echo_JJ_ajd HAT03A_HF_Sonar&Echo_JJ_ajd


collections = {
    'Calibrations'
    'Deployments'
    'Detections'
    'Ensembles'
    'Events'
    'ITIS'
    'Localizations'
    'SourceMaps'
    'SpeciesAbbreviations'
    'TransferFunctions'
    };

for cidx = 1:length(collections)
    errors = {};
    collection = collections{cidx};
    target = fullfile(dir, collection);    
    
    fordocin = sprintf('for $doc in collection("%s") ', collection);
    % Find documents in collection
    docstr = q.QueryTethys(...
        [fordocin, 'return dbxml:metadata("dbxml:name",$doc)']);
    docch = char(docstr);  % Java -> Matlab string
    if isempty(docch)
        fprintf('Collection %s empty, skipping\n', collection);
        continue
    end
    docs = strsplit(docch);
    
    if ~ isdir(target)
        mkdir(target);
    end

    % Process documents
    fprintf('Collection %s, %d documents\n', collection, length(docs));
    for didx = 1:length(docs)
        if rem(didx, 100) == 0
            fprintf('%d ', didx);
        end
        try
            xmlstr = q.getDocument(collection, docs{didx});
        catch e
            errors{end+1} = docs{didx};
            fprintf('\ncaught error doc %s :\n', docs{didx})
            e.message
            continue
        end
        h = fopen(fullfile(target, [docs{didx}, '.xml']), 'wb');
        fwrite(h, char(q.xmlpp(xmlstr)));
        fclose(h);
        1;
    end
    fprintf('\n\n');
    if length(errors) > 0
        fprintf('Errors:  %s\n', strjoin(errors, ' '));
    end
end
