import schema namespace ty="http://tethys.sdsu.edu/schema/1.0" at "tethys.xsd";

<AbbreviationNames>
{
for $name in collection("SpeciesAbbreviations")/ty:Abbreviations/Name
    return $name
}
</AbbreviationNames>
    
