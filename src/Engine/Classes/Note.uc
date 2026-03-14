//=============================================================================
// Note - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// A sticky note.  Level designers can place these in the level and then
// view them as a batch in the error/warnings window.
//=============================================================================
class Note extends Actor
    native
    placeable;

var() string Text;

defaultproperties
{
	bStatic=true
	bHidden=true
	bNoDelete=true
	bMovable=false
	Texture=Texture'Engine.S_Note'
}
