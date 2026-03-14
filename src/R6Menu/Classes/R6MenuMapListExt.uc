// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuMapListExt extends R6MenuMapList;

// --- Constants ---
const C_RED_ARMOR_INDEX =  3;
const C_GREEN_ARMOR_INDEX =  2;
const C_GAME_TYPE_INDEX =  1;
const C_MAP_INDEX =  0;
const C_fY_ButPos =  117;
const C_fHEIGHT_OF_MAPLIST =  214;

// --- Variables ---
var bool m_bFinalListEmpty;

// --- Functions ---
function SetOrderButtons(bool _bDisable) {}
function GetInitArmor(string _szGameType, out string _szRedArmor, string _szMapName, out string _szGreenArmor, out string _szGreenPkg, out string _szRedPkg) {}
function string FillFinalMapList() {}
function ManageAvailableGameTypes(UWindowList _pSelectItem, optional bool _bKeepItemGameType) {}
function CopyAndAddItemInList(UWindowListControl _ListAddItem, UWindowListBoxItem _ItemToAdd) {}
function AssignParamsToNewItem(Region R, R6WindowListBoxItemExt NewItem, int _index, string _szText, string _szMisc, int _iLineNumber, optional bool _bNotDisplay) {}
function ManageComboChange() {}
function FillMapListItem() {}
function SetAllArmor() {}
function Created() {}
function byte FillGameTypeMapArray(out array<array> _SelectedMapList, out array<array> _SelectedGameTypeList) {}
function Notify(UWindowDialogControl C, byte E) {}

defaultproperties
{
}
