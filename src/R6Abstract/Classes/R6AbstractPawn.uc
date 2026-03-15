//=============================================================================
// R6AbstractPawn - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6AbstractPawn.uc : This is the abstract class for the r6pawn class.  We
//                      use an abstract class without any declared function.  
//                      This is useful to avoid circular references
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    July 18th, 2001 * Created by Eric Begin
//=============================================================================
class R6AbstractPawn extends Pawn
    abstract
    native;

enum ESkills
{
	SKILL_Assault,                  // 0
	SKILL_Demolitions,              // 1
	SKILL_Electronics,              // 2
	SKILL_Sniper,                   // 3
	SKILL_Stealth,                  // 4
	SKILL_SelfControl,              // 5
	SKILL_Leadership,               // 6
	SKILL_Observation               // 7
};

var(Debug) bool bShowLog;

replication
{
	// Pos:0x000
	unreliable if((int(Role) == int(ROLE_Authority)))
		ClientGetWeapon;
}

event float GetSkill(R6AbstractPawn.ESkills eSkillName)
{
	return;
}

function GetWeapon(R6AbstractWeapon NewWeapon)
{
	// End:0x24
	if(bShowLog)
	{
		Log(("ak: GetWeapon " $ string(NewWeapon)));
	}
	return;
}

function ClientGetWeapon(R6EngineWeapon NewWeapon)
{
	// End:0x36
	if(((int(Level.NetMode) == int(NM_Standalone)) || (int(Level.NetMode) == int(NM_ListenServer))))
	{
		return;
	}
	// End:0x62
	if(bShowLog)
	{
		Log(("IN: ClientGetWeapon() " $ string(NewWeapon)));
	}
	GetWeapon(R6AbstractWeapon(NewWeapon));
	// End:0x9F
	if(bShowLog)
	{
		Log(("OUT: ClientGetWeapon() " $ string(NewWeapon)));
	}
	return;
}

