//=============================================================================
// R6MatineeHostage - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MatineeHostage.uc : A placeable Hostage Class for Matinee. 
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeHostage extends R6Hostage
    native;

var(R6Equipment) bool m_bUseHostageTemplate;
//Private Variables:
var R6MatineeAttach m_MatineeAttach;
// NEW IN 1.60
var(R6Equipment) Class<R6Hostage> m_HostageTemplate;

event PostBeginPlay()
{
	m_MatineeAttach = new (none) Class'R6Engine.R6MatineeAttach';
	// End:0x4D
	if(__NFUN_130__(__NFUN_119__(m_HostageTemplate, none), m_bUseHostageTemplate))
	{
		Skins = m_HostageTemplate.default.Skins;
		LinkMesh(m_HostageTemplate.default.Mesh);
	}
	super.PostBeginPlay();
	// End:0x64
	if(__NFUN_119__(Controller, none))
	{
		UnPossessed();
	}
	Controller = __NFUN_278__(ControllerClass);
	Controller.Possess(self);
	m_controller = R6HostageAI(Controller);
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
	m_bUseHostageTemplate=true
	CollisionHeight=85.0000000
	Mesh=SkeletalMesh'R6Hostage_UKX.CasualManMesh'
	KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel18'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var classR6Hostagem_HostageTemplate
