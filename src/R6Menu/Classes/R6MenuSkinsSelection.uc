// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuSkinsSelection extends UWindowDialogClientWindow;

// --- Constants ---
const C_fY_START_TEXT =  15;
const C_fY_START =  40;
const C_fWIDTH =  140;
const C_fWIDTH_OF_ARMOR_W =  160;
const C_fHEIGHT_OF_ARMOR_IMAGE =  245;
const C_iMAX_MAPLIST_SIZE =  32;
const C_MAP_INDEX =  0;
const C_GAME_TYPE_INDEX =  1;
const C_GREEN_ARMOR_INDEX =  2;
const C_RED_ARMOR_INDEX =  3;

// --- Structs ---
struct ArmorInfo
{
    var class<Object> armorClass;
    var string szArmorPkg;
};

// --- Variables ---
var R6MenuMPArmor m_2DArmor;
var R6WindowTextListBoxExt m_pMapList;
var R6WindowTextListBox m_ArmorListBox;
var R6WindowTextLabelExt m_pTextInfo;
var array<array> m_AArmors;
var class<R6ArmorDescription> m_RedArmorDesc;
var class<R6ArmorDescription> m_GreenArmorDesc;
var bool m_bFirstDisplay;

// --- Functions ---
function bool SameSkins(R6WindowListBoxItemExt Item2, R6WindowListBoxItemExt Item1) {}
function UpdateImages() {}
function R6WindowListBoxItemExt CopyItemInList(R6WindowListBoxItemExt _ItemToAdd, UWindowListControl _ListAddItem) {}
function BuildAvailableMissionArmors() {}
function Created() {}
function FillArmorList() {}
function Notify(UWindowDialogControl C, byte E) {}
function ChangeCurrentMapSkin(int Skin) {}
function CopyAllValues(R6MenuMapListExt _pMyList) {}
function GetAllValues(out R6MenuMapListExt _pMyList) {}
function ShowWindow() {}
function FirstDisplay() {}
function SetButtonRegion(bool _bInverseTex) {}

defaultproperties
{
}
