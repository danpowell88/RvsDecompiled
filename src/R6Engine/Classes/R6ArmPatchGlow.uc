//=============================================================================
// R6ArmPatchGlow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6ArmPatchGlow.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/12 * Created by Jean-Francois Dube
//=============================================================================
class R6ArmPatchGlow extends R6GlowLight;

var float m_fMatrixMul;
var name m_AttachedBoneName;

function Tick(float fDeltaTime)
{
	local Pawn OwnerPawn, ViewPawn;
	local PlayerController ViewActor;
	local Coords TempCoord;
	local Vector temp;
	local Rotator TempRot;

	bCorona = false;
	bHidden = true;
	// End:0x27
	if((Level.m_bNightVisionActive == false))
	{
		return;
	}
	ViewActor = GetCanvas().Viewport.Actor;
	// End:0x4F
	if((ViewActor == none))
	{
		return;
	}
	OwnerPawn = Pawn(m_pOwnerNightVision);
	ViewPawn = ViewActor.Pawn;
	// End:0x17A
	if(((ViewPawn != none) && (OwnerPawn.m_iTeam == ViewPawn.m_iTeam)))
	{
		TempCoord = OwnerPawn.GetBoneCoords(m_AttachedBoneName, true);
		temp = TempCoord.Origin;
		(temp += (TempCoord.XAxis * 14.0000000));
		(temp -= (TempCoord.YAxis * 2.0000000));
		(temp += ((TempCoord.ZAxis * 8.0000000) * m_fMatrixMul));
		SetLocation(temp);
		TempRot = OrthoRotation((TempCoord.ZAxis * m_fMatrixMul), (TempCoord.YAxis * m_fMatrixMul), (TempCoord.XAxis * m_fMatrixMul));
		SetRotation(TempRot);
		bCorona = true;
		bHidden = false;
	}
	return;
}

defaultproperties
{
	m_fMatrixMul=1.0000000
	m_AttachedBoneName="'"
	m_bInverseScale=true
	RemoteRole=0
	LightHue=255
	bNoDelete=false
	bCanTeleport=true
	bMovable=true
	DrawScale=0.6000000
	LightBrightness=255.0000000
	LightRadius=96.0000000
	Texture=none
	Skins=/* Array type was not detected. */
}
