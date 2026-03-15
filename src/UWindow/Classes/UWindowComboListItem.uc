//=============================================================================
// UWindowComboListItem - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class UWindowComboListItem extends UWindowList;

var int SortWeight;
var bool bDisabled;
var float ItemTop;
var string Value;
var string Value2;  // A second, non-displayed value

function int Compare(UWindowList t, UWindowList B)
{
	local UWindowComboListItem TI, BI;
	local string TS, BS;

	TI = UWindowComboListItem(t);
	BI = UWindowComboListItem(B);
	// End:0x98
	if((TI.SortWeight == BI.SortWeight))
	{
		TS = Caps(TI.Value);
		BS = Caps(BI.Value);
		// End:0x7E
		if((TS == BS))
		{
			return 0;
		}
		// End:0x93
		if((TS < BS))
		{
			return -1;
		}
		return 1;		
	}
	else
	{
		return (TI.SortWeight - BI.SortWeight);
	}
	return;
}

