import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";

<Abbreviations>
{
for $doc in collection("SpeciesAbbreviations")/ty:Abbreviations
    where $doc/Name = %s
    return 
      for $map in $doc/Map
	return $map
}
</Abbreviations>
    
