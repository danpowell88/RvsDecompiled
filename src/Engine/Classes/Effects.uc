//=============================================================================
// Effects - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Effects, the base class of all gratuitous special effects.
// 
//=============================================================================
class Effects extends Actor
 notplaceable;

var() Sound EffectSound1;

defaultproperties
{
	RemoteRole=0
	bNetTemporary=true
	bUnlit=true
	bGameRelevant=true
}
