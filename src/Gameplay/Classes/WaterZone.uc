//=============================================================================
// Legacy UE1-era zone that marks an area as a water volume.  Superseded by WaterVolume in UE2.
// Retained for map backwards-compatibility; bObsolete flags it as deprecated in the editor.
//=============================================================================

class WaterZone extends ZoneInfo;

defaultproperties
{
     bObsolete=True
}