//=============================================================================
// R6ColorPicker - Color picker for the writable map
//=============================================================================
class R6OperativeSelectorItem extends UWindowDialogControl;

// --- Variables ---
var R6Rainbow m_Operative;
var string m_WeaponsName[4];
var R6TeamMemberReplicationInfo m_MemberRepInfo;
var Color m_NormalColor;
var Color m_DarkColor;
var bool m_bIsSinglePlayer;
var byte m_eHealth;
var bool m_bIsDead;
var Plane DefaultFaceCoords;
var const int WeaponHeight;
var const int WeaponY;
var const int WeaponX;
var bool m_bMouseOver;
var string m_szSpeciality;
var Material DefaultFaceTexture;
var Material HealthIconTexture;
var Sound m_OperativeSelectSnd;
var const int LifeY;
var const int LifeX;
var const int SpecY;
var const int SpecX;
var const int NameY;
var const int NameX;
var int m_iOperativeIndex;
var int m_iTeam;
var string m_szName;

// --- Functions ---
function Paint(Canvas C, float X, float Y) {}
function SetCharacterInfo(R6Rainbow Character) {}
function UpdateGadgets() {}
function SetCharacterInfoMP(R6TeamMemberReplicationInfo repInfo) {}
function LMouseDown(float X, float Y) {}
function MouseEnter() {}
function MouseLeave() {}
function UpdatePosition() {}
function UpdatePositionMP() {}
function string GetCharacterName() {}
// ^ NEW IN 1.60

defaultproperties
{
}
