//=============================================================================
// R6MatineeRainbow - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6MatineeRainbow.uc : A placeable Rainbow Class for Matinee. 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Cyrille Lauzon
//=============================================================================
class R6MatineeRainbow extends R6Rainbow
    native;

//var(R6Equipment)       string	    	 m_PrimaryItem;
//var(R6Equipment)       string			 m_SecondaryItem;
var(R6Equipment) bool m_bActivateGadget;
var(R6Equipment) bool m_bUseRainbowTemplate;
//Private Variables:
var R6RainbowAI m_controller;
var R6MatineeAttach m_MatineeAttach;
var(R6Equipment) Class<R6AbstractWeapon> m_PrimaryWeapon;
var(R6Equipment) Class<R6AbstractWeapon> m_SecondaryWeapon;
var(R6Equipment) Class<R6AbstractGadget> m_PrimaryGadget;
var(R6Equipment) Class<R6AbstractGadget> m_SecondaryGadget;
// NEW IN 1.60
var(R6Equipment) Class<R6Rainbow> m_RainbowTemplate;

//--------------------------------------
//PostBeginPlay
//Desc: Initialize the Rainbow
//--------------------------------------
event PostBeginPlay()
{
	m_MatineeAttach = new (none) Class'R6Engine.R6MatineeAttach';
	// End:0x61
	if(__NFUN_130__(__NFUN_119__(m_RainbowTemplate, none), m_bUseRainbowTemplate))
	{
		Skins = m_RainbowTemplate.default.Skins;
		LinkMesh(m_RainbowTemplate.default.Mesh);
		m_HelmetClass = m_RainbowTemplate.default.m_HelmetClass;
	}
	super.PostBeginPlay();
	m_szPrimaryWeapon = string(m_PrimaryWeapon);
	m_szPrimaryGadget = string(m_PrimaryGadget);
	m_szSecondaryWeapon = string(m_SecondaryWeapon);
	m_szSecondaryGadget = string(m_SecondaryGadget);
	// End:0xAC
	if(__NFUN_119__(Controller, none))
	{
		UnPossessed();
	}
	Controller = __NFUN_278__(ControllerClass);
	m_controller = R6RainbowAI(Controller);
	m_controller.m_PaceMember = self;
	m_controller.m_TeamLeader = self;
	m_controller.Possess(self);
	GiveDefaultWeapon();
	// End:0x132
	if(__NFUN_242__(m_bActivateGadget, true))
	{
		m_bWeaponGadgetActivated = true;
		R6AbstractWeapon(EngineWeapon).m_SelectedWeaponGadget.ActivateGadget(true);
	}
	return;
}

function SetMovementPhysics()
{
	return;
}

function SetAttachVar(Actor AttachActor, string StaticMeshTag, name PawnTag)
{
	__NFUN_231__("R6MatineeRainbow::SetAttachVar");
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
	m_bActivateGadget=true
	m_bUseRainbowTemplate=true
	Mesh=SkeletalMesh'R6Rainbow_UKX.LightMesh'
	KParams=KarmaParamsSkel'R6Engine.KarmaParamsSkel21'
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var classR6Rainbowm_RainbowTemplate
