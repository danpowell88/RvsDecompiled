//=============================================================================
//  R6MenuGearWidget.uc : GearRoomMenu
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuGearWidget extends R6MenuLaptopWidget;

// --- Enums ---
enum eOperativeTeam
{    
    Red_Team,
    Green_Team,
    Gold_Team,    
    No_Team
};
enum e2DEquipment
{
    Primary_Weapon,
    Primary_WeaponGadget,
    Primary_Bullet,
    Primary_Gadget,
    Secondary_Weapon,
    Secondary_WeaponGadget,
    Secondary_Bullet,
    Secondary_Gadget,
    Armor,
    All_Primary,
    All_Secondary,
    All_PrimaryGadget,
    All_SecondaryGadget,
    All_Armor,
    All_ToAll
};

// --- Variables ---
// var ? bshowlog; // REMOVED IN 1.60
// var ? m_bRebuildAllPlan; // REMOVED IN 1.60
//Current Selected Operative
var R6Operative m_currentOperative;
//Lists on the left of the menu
var R6MenuDynTeamListsControl m_RosterListCtrl;
var class<R6WeaponGadgetDescription> m_OpFirstWeaponGadgetDesc;
// ^ NEW IN 1.60
var class<R6WeaponGadgetDescription> m_OpSecondWeaponGadgetDesc;
var bool bShowLog;
// ^ NEW IN 1.60
//list in witch the current operative has been added
var eOperativeTeam m_currentOperativeTeam;
//Equipment of the selected Operative
var class<R6PrimaryWeaponDescription> m_OpFirstWeaponDesc;
var class<R6SecondaryWeaponDescription> m_OpSecondaryWeaponDesc;
var R6WindowTextLabel m_CodeName;
// ^ NEW IN 1.60
//Right side when looking at an equipment item
var R6MenuEquipmentDetailControl m_EquipmentDetails;
var R6DescPrimaryMags m_PrimaryMagsGadget;
var class<R6BulletDescription> m_OpFirstWeaponBulletDesc;
// ^ NEW IN 1.60
var class<R6BulletDescription> m_OpSecondWeaponBulletDesc;
var class<R6GadgetDescription> m_OpFirstGadgetDesc;
// ^ NEW IN 1.60
var class<R6GadgetDescription> m_OpSecondGadgetDesc;
var class<R6ArmorDescription> m_OpArmorDesc;
var R6WindowTextLabel m_DateTime;
// ^ NEW IN 1.60
//Right side when looking at an operative details
var R6MenuOperativeDetailControl m_OperativeDetails;
//Middle part where we can take a look a selected equipment
var R6MenuEquipmentSelectControl m_Equipment2dSelect;
var Font m_labelFont;
var R6WindowTextLabel m_Location;
var int m_IRosterListLeftPad;
var float m_fPaddingBetweenElements;

// --- Functions ---
// function ? RebuildAllPlanningFile(...); // REMOVED IN 1.60
function ShowWindow() {}
function OperativeSelected(optional UWindowWindow _pActiveWindow, R6Operative selectedOperative, eOperativeTeam _selectedTeam) {}
function SetStartTeamInfo() {}
function EquipmentChanged(class<R6Description> DecriptionClass, int EquipmentSelected) {}
function EquipmentSelected(e2DEquipment EquipmentSelected) {}
function LoadRosterFromStartInfo() {}
//MAKE SURE THIS FUNCTION IS THE SAME AS THE ONE IN THE MULTIPLAYER GEAR ROOM
function TexRegion GetGadgetTexture(class<R6GadgetDescription> _CurrentGadget) {}
// ^ NEW IN 1.60
function SetStartTeamInfoForSaving() {}
function Reset() {}
function Created() {}
function SetupOperative(out R6Operative OpToChek) {}
function bool IsTeamConfigValid() {}
// ^ NEW IN 1.60

defaultproperties
{
}
