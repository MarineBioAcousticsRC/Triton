<Detections xmlns:xsi="http://cetus.ucsd.edu/Deployment">
{for $item in (
for $det in collection("Detections")/Detections
where base-uri($det) = "dbxml:///Detections/SCMMW_SMK_groundtruth"
return

for $detection in $det/OnEffort/Detection
where $detection/SpeciesCode = "Bm" and $detection/Call = "A"
return
<Detection>
{$detection/Species}
{$detection/Call}
{$detection/Start}
{$detection/End}
</Detection>
)
order by $item/Detection/Start
return $item
}
</Detections>
