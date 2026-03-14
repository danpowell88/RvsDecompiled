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
	reliable if(__NFUN_154__(int(Role), int(ROLE_Authority)))
		CurrentTexture;
}

simulated event PostBeginPlay()
{
	super(Actor).PostBeginPlay();
	CurrentTexture = 0;
	// End:0x32
	if(__NFUN_119__(ScriptedTexture(DestinationTexture), none))
	{
		ScriptedTexture(DestinationTexture).NotifyActor = self;
	}
	return;
}

simulated event Destroyed()
{
	// End:0x40
	if(__NFUN_130__(__NFUN_119__(ScriptedTexture(DestinationTexture), none), __NFUN_114__(ScriptedTexture(DestinationTexture).NotifyActor, self)))
	{
		ScriptedTexture(DestinationTexture).NotifyActor = none;
	}
	super(Actor).Destroyed();
	return;
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	// End:0x2F
	if(__NFUN_130__(bTriggerOnceOnly, __NFUN_132__(__NFUN_114__(Textures[__NFUN_146__(CurrentTexture, 1)], none), __NFUN_154__(CurrentTexture, 9))))
	{
		return;
	}
	__NFUN_165__(CurrentTexture);
	// End:0x5C
	if(__NFUN_132__(__NFUN_114__(Textures[CurrentTexture], none), __NFUN_154__(CurrentTexture, 10)))
	{
		CurrentTexture = 0;
	}
	return;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	Tex.__NFUN_473__(0.0000000, 0.0000000, float(Tex.USize), float(Tex.VSize), 0.0000000, 0.0000000, float(Textures[CurrentTexture].USize), float(Textures[CurrentTexture].VSize), Textures[CurrentTexture], false);
	return;
}

defaultproperties
{
	RemoteRole=2
	bNoDelete=true
	bAlwaysRelevant=true
}
