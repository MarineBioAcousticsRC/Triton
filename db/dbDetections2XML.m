function xml = dbDetections2XML(EffStart, EffEnd, Kinds, DetectionTimes)
% xml = dbDetections2XML(EffStart, EffEnd, Kinds)
% Generate XML from a set of detections
%
% Kinds should be a structure array where each element has:
%  .SpeciesID (a taxonomic serial number from the ITIS collection)
%  .Call (a call type)
%  .Granularity - granularity type
%  .BinSize_m - bin size in minutes
% Note that every element of the structure must have the same fields.
% If some things are not needed set them to [] (e.g. BinSize_m for
% effort of granularity "encounter".
%              
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Calendar;
import java.util.List;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Marshaller;

% Used for generating instances of XML types
import javax.xml.datatype.DatatypeFactory;

import edu.sdsu.tethys.schema._1.*;


% Any types defined in the schema can be simply constructed.  XML 
% native types use JAXB's DataTypeFactory.

% We create the detections object and subtypes that are part of it
det = Detections();  % Create instance of Detections schema

% Build up the effort
effort = DetectionEffort();  % Description of effort

% Dates must be converted to XMLGregorianCalendar which is the 
% way Java represents XML date time units.  
EffStartISO8601 = dbSerialDateToISO8601(EffStart);
effort.setStart(DatatypeFactory.newInstance.newXMLGregorianCalendar(EffStartISO8601));
EffEndISO8601 = dbSerialDateToISO8601(EffEnd);
effort.setEnd(DatatypeFactory.newInstance.newXMLGregorianCalendar(EffEndISO8601));

% Populate start of effort
xstart = DatatypeFactory.newInstance.newXMLGregorianCalendar();
effort.setStart(xstart);
xend = DatatypeFactory.newInstance.newXMLGregorianCalendar(dbSerialDateToISO8601(EffEnd));
effort.setEnd(xend);

% kinds is a linked list.  We add each kind to the list
KindsList = effort.getKind();
for kidx = 1:length(Kinds)
    kind = DetectionEffortKind();
    species = SpeciesIDType();
    species.setValue(java.math.BigInteger(Kinds(kidx).SpeciesID));
    kind.setSpeciesID(species);
    if isfield(Kinds(kidx), 'Call')
        acall = CallType()
        acall.setValue(Kinds(kidx).Call);
        kind.setCall(acall);
    end
    granularity = GranularityType();
    granularity.setValue(GranularityEnumType.fromValue(Kinds(kidx).Granularity));
    if strcmp(Kinds(kidx).Granularity, 'binned')
        granularity.setBinSizeM(Kinds(kidx).BinSize_m);
    end
    kind.setGranularity(granularity);
    
    KindsList.add(kind)
end

1;



