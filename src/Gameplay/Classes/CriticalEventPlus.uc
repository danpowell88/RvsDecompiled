//=============================================================================
// CriticalEventPlus - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class CriticalEventPlus extends LocalMessagePlus
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

static function float GetOffset(int Switch, float YL, float ClipY)
{
	return __NFUN_171__(__NFUN_172__(default.YPos, 768.0000000), ClipY);
	return;
}

defaultproperties
{
	FontSize=1
	Lifetime=3
	bIsSpecial=true
	bIsUnique=true
	bFadeMessage=true
	bBeep=true
	bCenter=true
	YPos=196.0000000
	DrawColor=(R=0,G=128,B=255,A=255)
}
