//=============================================================================
//  R6AbstractPawn.uc : This is the abstract class for the r6pawn class.  We
//                      use an abstract class without any declared function.  
//                      This is useful to avoid circular references
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    July 18th, 2001 * Created by Eric Begin
//=============================================================================
class R6AbstractPawn extends Pawn
    native
    abstract;

// --- Enums ---
enum ESkills
{
    SKILL_Assault,
    SKILL_Demolitions,
    SKILL_Electronics,
    SKILL_Sniper,
    SKILL_Stealth,
    SKILL_SelfControl,
    SKILL_Leadership,
    SKILL_Observation
};

// --- Variables ---
var bool bShowLog;

// --- Functions ---
function ClientGetWeapon(R6EngineWeapon NewWeapon) {}
function GetWeapon(R6AbstractWeapon NewWeapon) {}
event float GetSkill(ESkills eSkillName) {}
// ^ NEW IN 1.60

defaultproperties
{
}
