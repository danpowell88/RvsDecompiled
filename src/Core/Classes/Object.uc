//=============================================================================
// Object: The base class all objects.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Object extends None
    native;

// --- Constants ---
const Pi =  3.1415926535897932;
const MaxInt =  0x7fffffff;
const RF_NotForEdit =  0x00400000;
const RF_NotForServer =  0x00200000;
const RF_NotForClient =  0x00100000;
const RF_Transient =  0x00004000;
const RF_Public =  0x00000004;
const RF_Transactional =  0x00000001;

// --- Enums ---
enum ECamOrientation
{
	CAMORIENT_None,
	CAMORIENT_LookAtActor,
	CAMORIENT_FacePath,
	CAMORIENT_Interpolate,
	CAMORIENT_Dolly,
};
enum ePlayerTeamSelection
{
    PTS_UnSelected,
    PTS_AutoSelect,
    PTS_Alpha,
    PTS_Bravo,
    PTS_Spectator
};
enum ENodeNotify
{
    NODEMSG_NewAction,
    NODEMSG_NewMode,
    NODEMSG_NewSpeed,
    NODEMSG_NewNode,
    NODEMSG_GoCodeLaunched,
    NODEMSG_ActionNodeCompleted,
    NODEMSG_WaitingGoCode,
    NODEMSG_NodeReached,
    NODEMSG_PlayerLeft,
    NODEMSG_SnipeUntilGoCode,
    NODEMSG_BreachDoorAtGoCode
};
enum EPlanActionType
{
    PACTTYP_Normal,
    PACTTYP_Milestone,
    PACTTYP_GoCodeA,
    PACTTYP_GoCodeB,
    PACTTYP_GoCodeC,
    PACTTYP_Delete
};
enum EPlanAction
{
    PACT_None,
    PACT_Frag,
    PACT_Flash,
    PACT_Gas,
    PACT_Smoke,
    PACT_SnipeGoCode,
    PACT_Breach,
    PACT_OpenDoor
};
enum EMovementSpeed
{
    SPEED_Blitz,
    SPEED_Normal,
    SPEED_Cautious
};
enum EMovementMode
{
    MOVE_Assault,
    MOVE_Infiltrate,
    MOVE_Recon
};
enum EGoCode
{
    GOCODE_Alpha,
    GOCODE_Bravo,
    GOCODE_Charlie,
    GOCODE_Zulu,
    GOCODE_None
};

// --- Structs ---
struct Vector
{
	var() config float X, Y, Z;
};

struct Rotator
{
	var() config int Pitch, Yaw, Roll;
};

struct Plane extends Vector
{
	var() config float W;
};

struct Range
{
	var() config float Min;
	var() config float Max;
};

struct Box
{
	var vector Min, Max;
	var byte IsValid;
};

struct InterpCurvePoint
{
	var() float InVal;
	var() float OutVal;
};

struct InterpCurve
{
	var() array<InterpCurvePoint>	Points;
};

struct Scale
{
	var() config vector Scale;
	var() config float SheerRate;
	var() config enum ESheerAxis
	{
		SHEER_None,
		SHEER_XY,
		SHEER_XZ,
		SHEER_YX,
		SHEER_YZ,
		SHEER_ZX,
		SHEER_ZY,
	} SheerAxis;
};

struct CompressedPosition
{
	var vector Location;
	var rotator Rotation;
	var vector Velocity;
};

struct Region
{
	var() int X;
	var() int Y;
	var() int W;
	var() int H;
};

struct Matrix
{
	var() Plane XPlane;
	var() Plane YPlane;
	var() Plane ZPlane;
	var() Plane WPlane;
};

struct BoundingVolume extends Box
{
	var plane Sphere;
};

struct Color
{
	var() config byte B, G, R, A;
};

struct RangeVector
{
	var() config range X;
	var() config range Y;
	var() config range Z;
};

struct Coords
{
	var() config vector Origin, XAxis, YAxis, ZAxis;
};

struct Guid
{
	var int A, B, C, D;
};

// --- Variables ---
// var ? D; // REMOVED IN 1.60
// var ? IsValid; // REMOVED IN 1.60
// var ? Location; // REMOVED IN 1.60
// var ? Max; // REMOVED IN 1.60
// var ? Rotation; // REMOVED IN 1.60
// var ? Sphere; // REMOVED IN 1.60
// var ? Velocity; // REMOVED IN 1.60
var native const Object Outer;
// Internal variables.
var native const int ObjectInternal[6];
// ***********************************************************************************************
// * BEGIN UBI MODIF joel tremblay (16 juil 2003)
// ***********************************************************************************************
var native const int DName;
var native const editconst class<Object> Class;
var native const editconst name Name;
// ^ NEW IN 1.60
var native const int ObjectFlags;

// --- Functions ---
// function ? InitMod(...); // REMOVED IN 1.60
static final native operator Vector DivideEqual_VectorFloat(out Vector A, float B) {}
// ^ NEW IN 1.60
static final native operator int Xor_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator Vector AddEqual_VectorVector(Vector B, out Vector A) {}
// ^ NEW IN 1.60
static final native operator int Or_IntInt(int B, int A) {}
// ^ NEW IN 1.60
static final native operator int And_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator Vector SubtractEqual_VectorVector(Vector B, out Vector A) {}
// ^ NEW IN 1.60
static final native operator Vector MultiplyEqual_VectorVector(out Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native function float VSize(Vector A) {}
// ^ NEW IN 1.60
static final native operator int MultiplyEqual_IntFloat(float B, out int A) {}
// ^ NEW IN 1.60
static final native function Vector Normal(Vector A) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator Vector MultiplyEqual_VectorFloat(out Vector A, float B) {}
// ^ NEW IN 1.60
static final native operator bool GreaterEqual_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native function Invert(out Vector Z, out Vector Y, out Vector X) {}
// ^ NEW IN 1.60
static final native operator int DivideEqual_IntFloat(float B, out int A) {}
// ^ NEW IN 1.60
static final native operator bool LessEqual_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native function Vector MirrorVectorByNormal(Vector Normal, Vector Vect) {}
// ^ NEW IN 1.60
static final native operator Vector Cross_VectorVector(Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native operator bool Greater_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_RotatorRotator(Rotator B, Rotator A) {}
// ^ NEW IN 1.60
static final native operator int AddEqual_IntInt(int B, out int A) {}
// ^ NEW IN 1.60
static final native operator bool Less_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_RotatorRotator(Rotator B, Rotator A) {}
// ^ NEW IN 1.60
static final native operator float Dot_VectorVector(Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native operator int GreaterGreaterGreater_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator Rotator Multiply_RotatorFloat(float B, Rotator A) {}
// ^ NEW IN 1.60
static final native operator int SubtractEqual_IntInt(int B, out int A) {}
// ^ NEW IN 1.60
static final native operator int GreaterGreater_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator Rotator Multiply_FloatRotator(Rotator B, float A) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_VectorVector(Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native operator int LessLess_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator Rotator Divide_RotatorFloat(float B, Rotator A) {}
// ^ NEW IN 1.60
static final native operator int AddAdd_PreInt(out int A) {}
// ^ NEW IN 1.60
static final native operator int Subtract_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_VectorVector(Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native operator Rotator MultiplyEqual_RotatorFloat(float B, out Rotator A) {}
// ^ NEW IN 1.60
static final native operator int Add_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator int SubtractSubtract_PreInt(out int A) {}
// ^ NEW IN 1.60
static final native operator int Divide_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator Vector GreaterGreater_VectorRotator(Vector A, Rotator B) {}
// ^ NEW IN 1.60
static final native operator Rotator Add_RotatorRotator(Rotator B, Rotator A) {}
// ^ NEW IN 1.60
static final native operator int Multiply_IntInt(int A, int B) {}
// ^ NEW IN 1.60
static final native operator int AddAdd_Int(out int A) {}
// ^ NEW IN 1.60
static final native operator Rotator Subtract_RotatorRotator(Rotator B, Rotator A) {}
// ^ NEW IN 1.60
static final native operator Vector LessLess_VectorRotator(Vector A, Rotator B) {}
// ^ NEW IN 1.60
static final native operator int Subtract_PreInt(int A) {}
// ^ NEW IN 1.60
static final native operator Rotator AddEqual_RotatorRotator(Rotator B, out Rotator A) {}
// ^ NEW IN 1.60
static final native operator int SubtractSubtract_Int(out int A) {}
// ^ NEW IN 1.60
static final native operator int Complement_PreInt(int A) {}
// ^ NEW IN 1.60
static final native operator Vector Subtract_VectorVector(Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native operator Rotator SubtractEqual_RotatorRotator(Rotator B, out Rotator A) {}
// ^ NEW IN 1.60
static final native operator byte SubtractSubtract_Byte(out byte A) {}
// ^ NEW IN 1.60
static final native function int Rand(int Max) {}
// ^ NEW IN 1.60
static final native operator byte AddAdd_Byte(out byte A) {}
// ^ NEW IN 1.60
static final native operator Vector Add_VectorVector(Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native function GetAxes(out Vector Z, out Vector Y, out Vector X, Rotator A) {}
// ^ NEW IN 1.60
static final native operator byte SubtractSubtract_PreByte(out byte A) {}
// ^ NEW IN 1.60
static final native function int Min(int B, int A) {}
// ^ NEW IN 1.60
static final native operator byte AddAdd_PreByte(out byte A) {}
// ^ NEW IN 1.60
static final native operator Vector Divide_VectorFloat(Vector A, float B) {}
// ^ NEW IN 1.60
static final native function GetUnAxes(out Vector Z, out Vector Y, out Vector X, Rotator A) {}
// ^ NEW IN 1.60
static final native function Rotator RotRand(optional bool bRoll) {}
// ^ NEW IN 1.60
static final native function int Max(int B, int A) {}
// ^ NEW IN 1.60
static final native operator byte SubtractEqual_ByteByte(out byte A, byte B) {}
// ^ NEW IN 1.60
static final native operator byte AddEqual_ByteByte(out byte A, byte B) {}
// ^ NEW IN 1.60
static final native operator Vector Multiply_VectorVector(Vector A, Vector B) {}
// ^ NEW IN 1.60
static final native function Rotator OrthoRotation(Vector Z, Vector Y, Vector X) {}
// ^ NEW IN 1.60
static final native function Rotator Normalize(Rotator Rot) {}
// ^ NEW IN 1.60
static final native function int Clamp(int B, int A, int V) {}
// ^ NEW IN 1.60
static final native operator byte DivideEqual_ByteByte(out byte A, byte B) {}
// ^ NEW IN 1.60
static final native operator bool ClockwiseFrom_IntInt(int B, int A) {}
// ^ NEW IN 1.60
static final native operator byte MultiplyEqual_ByteByte(out byte A, byte B) {}
// ^ NEW IN 1.60
static final native operator Vector Multiply_FloatVector(float A, Vector B) {}
// ^ NEW IN 1.60
static final native function int ShortestAngle2D(int iAngle2, int iAngle1) {}
// ^ NEW IN 1.60
static final native operator bool OrOr_BoolBool(bool A, bool B) {}
// ^ NEW IN 1.60
static final native operator float Subtract_PreFloat(float A) {}
// ^ NEW IN 1.60
static final native operator bool XorXor_BoolBool(bool A, bool B) {}
// ^ NEW IN 1.60
static final native operator Vector Multiply_VectorFloat(Vector A, float B) {}
// ^ NEW IN 1.60
static final native function bool GetRegistryKey(out string Value, string Key, string Dir) {}
// ^ NEW IN 1.60
static final native operator bool AndAnd_BoolBool(bool A, bool B) {}
// ^ NEW IN 1.60
static final native operator float MultiplyMultiply_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native function bool SetRegistryKey(string Value, string Key, string Dir) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_BoolBool(bool A, bool B) {}
// ^ NEW IN 1.60
static final native function float Smerp(float Alpha, float A, float B) {}
// ^ NEW IN 1.60
static final native operator string Concat_StrStr(coerce string B, coerce string A) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_BoolBool(bool A, bool B) {}
// ^ NEW IN 1.60
static final native operator float Multiply_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native operator string At_StrStr(coerce string B, coerce string A) {}
// ^ NEW IN 1.60
static final native operator bool Not_PreBool(bool A) {}
// ^ NEW IN 1.60
static final native operator bool Less_StrStr(string B, string A) {}
// ^ NEW IN 1.60
static final native operator bool Greater_StrStr(string B, string A) {}
// ^ NEW IN 1.60
static final native operator float Divide_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native operator bool LessEqual_StrStr(string B, string A) {}
// ^ NEW IN 1.60
static final native operator bool GreaterEqual_StrStr(string B, string A) {}
// ^ NEW IN 1.60
static final native function float Lerp(float Alpha, float A, float B) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_StrStr(string B, string A) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_StrStr(string B, string A) {}
// ^ NEW IN 1.60
static final native operator float Percent_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native operator bool ComplementEqual_StrStr(string B, string A) {}
// ^ NEW IN 1.60
static final native function int Len(coerce string S) {}
// ^ NEW IN 1.60
static final native function int InStr(coerce string t, coerce string S) {}
// ^ NEW IN 1.60
static final native function float FClamp(float V, float A, float B) {}
// ^ NEW IN 1.60
static final native function string Mid(optional int j, int i, coerce string S) {}
// ^ NEW IN 1.60
static final native operator float Add_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native function string Left(int i, coerce string S) {}
// ^ NEW IN 1.60
static final native function string Right(int i, coerce string S) {}
// ^ NEW IN 1.60
static final native function string Caps(coerce string S) {}
// ^ NEW IN 1.60
static final native function string Chr(int i) {}
// ^ NEW IN 1.60
static final native operator float Subtract_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native function int Asc(string S) {}
// ^ NEW IN 1.60
static final native function string RemoveInvalidChars(string S) {}
// ^ NEW IN 1.60
static final native function float FMax(float A, float B) {}
// ^ NEW IN 1.60
static final native function string Itoa(int i) {}
// ^ NEW IN 1.60
static final native function int Atoi(coerce string S) {}
// ^ NEW IN 1.60
static final native operator bool Less_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native function int Strnicmp(int iCount, coerce string B, coerce string A) {}
// ^ NEW IN 1.60
static final native function float FMin(float A, float B) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_ObjectObject(Object B, Object A) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_ObjectObject(Object B, Object A) {}
// ^ NEW IN 1.60
static final native operator bool Greater_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_NameName(name B, name A) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_NameName(name B, name A) {}
// ^ NEW IN 1.60
static final native function float Square(float A) {}
// ^ NEW IN 1.60
// InterpCurve operator
static final native function float InterpCurveEval(float Input, InterpCurve curve) {}
// ^ NEW IN 1.60
static final native function float Sqrt(float A) {}
// ^ NEW IN 1.60
static final native function LogSnd(optional name Tag, coerce string S) {}
// ^ NEW IN 1.60
static final native operator bool LessEqual_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native function Log(optional name Tag, coerce string S) {}
// ^ NEW IN 1.60
static final native function Warn(coerce string S) {}
// ^ NEW IN 1.60
static final native function float Loge(float A) {}
// ^ NEW IN 1.60
// #ifdef R6CODE
static native function string Localize(optional bool bForceEnglish, optional bool bMultipleToken, optional bool bNoDebug, string PackageName, string KeyName, string SectionName) {}
// ^ NEW IN 1.60
static final native function float Exp(float A) {}
// ^ NEW IN 1.60
final native function GotoState(optional name Label, optional name NewState) {}
// ^ NEW IN 1.60
static final native operator bool GreaterEqual_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
final native function bool IsInState(name TestState) {}
// ^ NEW IN 1.60
static final native function bool ClassIsChildOf(class<Object> ParentClass, class<Object> TestClass) {}
// ^ NEW IN 1.60
static final native function float Atan(float A) {}
// ^ NEW IN 1.60
final native function bool IsA(name ClassName) {}
// ^ NEW IN 1.60
static final native function float Tan(float A) {}
// ^ NEW IN 1.60
final native function Enable(name ProbeFunc) {}
// ^ NEW IN 1.60
static final native operator bool EqualEqual_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
final native function Disable(name ProbeFunc) {}
// ^ NEW IN 1.60
// Properties.
final native function string GetPropertyText(string PropName) {}
// ^ NEW IN 1.60
static final native function float Acos(float A) {}
// ^ NEW IN 1.60
final native function SetPropertyText(string PropValue, string PropName) {}
static final native function float Cos(float A) {}
// ^ NEW IN 1.60
static final native function name GetEnum(int i, Object E) {}
// ^ NEW IN 1.60
static final native operator bool ComplementEqual_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native function Object DynamicLoadObject(optional bool MayFail, class<Object> ObjectClass, string ObjectName) {}
// ^ NEW IN 1.60
static final native function Object FindObject(class<Object> ObjectClass, string ObjectName) {}
// ^ NEW IN 1.60
static final native function float Asin(float A) {}
// ^ NEW IN 1.60
final native function SaveConfig(optional string FileName) {}
// ^ NEW IN 1.60
static final native function float Sin(float A) {}
// ^ NEW IN 1.60
final native function LoadConfig(optional string FileName) {}
// ^ NEW IN 1.60
static final native operator bool NotEqual_FloatFloat(float B, float A) {}
// ^ NEW IN 1.60
static final native function ResetConfig(optional string VarNameToReset) {}
static final native function class<Object> GetFirstPackageClass(class<Object> ObjectClass, string Package) {}
// ^ NEW IN 1.60
static final native function float Abs(float A) {}
// ^ NEW IN 1.60
static final native function Clock(int iCounter) {}
// ^ NEW IN 1.60
static final native operator float SubtractEqual_FloatFloat(out float A, float B) {}
// ^ NEW IN 1.60
static final native function Unclock(int iCounter) {}
// ^ NEW IN 1.60
static final native operator float MultiplyEqual_FloatFloat(float B, out float A) {}
// ^ NEW IN 1.60
static final native operator Vector Subtract_PreVector(Vector A) {}
// ^ NEW IN 1.60
static final native operator float AddEqual_FloatFloat(float B, out float A) {}
// ^ NEW IN 1.60
final function float RandRange(float Min, float Max) {}
// ^ NEW IN 1.60
static final native operator float DivideEqual_FloatFloat(out float A, float B) {}
// ^ NEW IN 1.60
static final native operator Rotator DivideEqual_RotatorFloat(float B, out Rotator A) {}
// ^ NEW IN 1.60
static final native function float FRand() {}
// ^ NEW IN 1.60
static final native function Vector VRand() {}
// ^ NEW IN 1.60
final native function name GetStateName() {}
// ^ NEW IN 1.60
static final native function StaticSaveConfig() {}
static final native function class<Object> GetNextClass() {}
// ^ NEW IN 1.60
static final native function class<Object> RewindToFirstClass() {}
// ^ NEW IN 1.60
static final native function FreePackageObjects() {}
// ^ NEW IN 1.60
static final native function ClearOuter() {}
// ^ NEW IN 1.60
//
// Called immediately when entering a state, while within
// the GotoState call that caused the state change.
//
event BeginState() {}
//
// Called immediately before going out of the current state,
// while within the GotoState call that caused the state change.
//
event EndState() {}

defaultproperties
{
}
