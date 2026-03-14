//=============================================================================
// LocalMessagePlus - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//
// Designed for ChallengeHUD
//
class LocalMessagePlus extends LocalMessage
 hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var int FontSize;  // Relative font size.

static function int GetFontSize(int Switch)
{
	return default.FontSize;
	return;
}

static function Color GetColor(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	return default.DrawColor;
	return;
}

static function float GetOffset(int Switch, float YL, float ClipY)
{
	return __NFUN_171__(__NFUN_172__(default.YPos, float(768)), ClipY);
	return;
}

defaultproperties
{
	bIsConsoleMessage=true
}
