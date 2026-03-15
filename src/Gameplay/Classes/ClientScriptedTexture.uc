//=============================================================================
// ClientScriptedTexture - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class ClientScriptedTexture extends Info
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var() Texture ScriptedTexture;

simulated function BeginPlay()
{
	// End:0x20
	if((ScriptedTexture != none))
	{
		ScriptedTexture(ScriptedTexture).NotifyActor = self;
	}
	return;
}

simulated function Destroyed()
{
	// End:0x20
	if((ScriptedTexture != none))
	{
		ScriptedTexture(ScriptedTexture).NotifyActor = none;
	}
	return;
}

simulated event RenderTexture(ScriptedTexture Tex)
{
	return;
}

defaultproperties
{
	RemoteRole=2
	bNoDelete=true
	bAlwaysRelevant=true
}
