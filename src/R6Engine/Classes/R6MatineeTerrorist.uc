//=============================================================================
// R6MatineeTerrorist - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MatineeTerrorist.uc : A placeable Terrorist Class for Matinee. 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeTerrorist extends R6Terrorist
    native;

var(R6Equipment) bool m_bUseTerroristTemplate;
var R6MatineeAttach m_MatineeAttach;
var(R6Equipment) Class<R6AbstractWeapon> m_PrimaryWeapon;
// NEW IN 1.60
var(R6Equipment) Class<R6Terrorist> m_TerroristTemplate;

//--------------------------------------
//PostBeginPlay
//Desc: Initialize the Terrorist, taken from 
//		R6Terrorist.PostInitialize() The function is not directly
//		called because it may change. We only want to have a 
//		pawn that works, no other initializations. 
//--------------------------------------
event PostBeginPlay()
{
	m_MatineeAttach = new (none) Class'R6Engine.R6MatineeAttach';
	// End:0x4D
	if(__NFUN_130__(__NFUN_119__(m_TerroristTemplate, none), m_bUseTerroristTemplate))
	{
		Skins = m_TerroristTemplate.default.Skins;
		LinkMesh(m_TerroristTemplate.default.Mesh);
	}
	m_szPrimaryWeapon = string(m_PrimaryWeapon);
	CommonInit();
	__NFUN_3970__(Physics);
	return;
}

function SetAttachVar(Actor AttachActor, string StaticMeshTag, name PawnTag)
{
	m_MatineeAttach.m_AttachActor = AttachActor;
	m_MatineeAttach.m_StaticMeshTag = StaticMeshTag;
	m_MatineeAttach.m_PawnTag = PawnTag;
	m_MatineeAttach.m_AttachPawn = self;
	m_MatineeAttach.InitAttach();
	return;
}

function MatineeAttach()
{
	m_MatineeAttach.MatineeAttach();
	return;
}

function MatineeDetach()
{
	m_MatineeAttach.MatineeDetach();
	return;
}

defaultproperties
{
	m_szPrimaryWeapon="R63rdWeapons.NormalSubMP5A4"
	Mesh=SkeletalMesh'R6Terrorist_UKX.Militant01Mesh'
	KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel23'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var classR6Terroristm_TerroristTemplate
