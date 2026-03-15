//=============================================================================
// TriggeredTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class TriggeredTexture extends Triggers;

var int CurrentTexture;
var() bool bTriggerOnceOnly;
var() Texture DestinationTexture;
var() Texture Textures[10];

replication
{
	// Pos:0x000
	reliable if((int(Role) == int(ROLE_Authority)))
		CurrentTexture;
}

simulated event PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	CurrentTexture = 0;
	// End:0x32
	if((ScriptedTexture(DestinationTexture) != none))
	{
		ScriptedTexture(DestinationTexture).NotifyActor = self;
	}
	return;
}

simulated event Destroyed()
{
	// End:0x40
	if(((ScriptedTexture(DestinationTexture) != none) && (ScriptedTexture(DestinationTexture).NotifyActor == self)))
	{
		ScriptedTexture(DestinationTexture).NotifyActor = none;
	}
	super(Actor).Destroyed();
	return;
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	// End:0x2F
	if((bTriggerOnceOnly && ((Textures[(CurrentTexture + 1)] == none) || (CurrentTexture == 9))))
	{
		return;
	}
	(CurrentTexture++);
	// End:0x5C
	if(((Textures[CurrentTexture] == none) || (CurrentTexture == 10)))
	{
		CurrentTexture = 0;
	}
	return;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	Tex.DrawTile(0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize), 0.0000000, 0.0000000, float(Textures[CurrentTexture].USize), float(Textures[CurrentTexture].VSize), Textures[CurrentTexture], false);
	return;
}

defaultproperties
{
	RemoteRole=2
	bNoDelete=true
	bAlwaysRelevant=true
}
