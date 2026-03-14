//=============================================================================
// Object - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// Object: The base class all objects.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class Object
    native
    noexport;

const RF_Transactional = 0x00000001;
const RF_Public = 0x00000004;
const RF_Transient = 0x00004000;
const RF_NotForClient = 0x00100000;
const RF_NotForServer = 0x00200000;
const RF_NotForEdit = 0x00400000;
const MaxInt = 0x7fffffff;
const Pi = 3.1415926535897932;

enum EGoCode
{
	GOCODE_Alpha,                   // 0
	GOCODE_Bravo,                   // 1
	GOCODE_Charlie,                 // 2
	GOCODE_Zulu,                    // 3
	GOCODE_None                     // 4
};

enum EMovementMode
{
	MOVE_Assault,                   // 0
	MOVE_Infiltrate,                // 1
	MOVE_Recon                      // 2
};

enum EMovementSpeed
{
	SPEED_Blitz,                    // 0
	SPEED_Normal,                   // 1
	SPEED_Cautious                  // 2
};

enum EPlanAction
{
	PACT_None,                      // 0
	PACT_Frag,                      // 1
	PACT_Flash,                     // 2
	PACT_Gas,                       // 3
	PACT_Smoke,                     // 4
	PACT_SnipeGoCode,               // 5
	PACT_Breach,                    // 6
	PACT_OpenDoor                   // 7
};

enum EPlanActionType
{
	PACTTYP_Normal,                 // 0
	PACTTYP_Milestone,              // 1
	PACTTYP_GoCodeA,                // 2
	PACTTYP_GoCodeB,                // 3
	PACTTYP_GoCodeC,                // 4
	PACTTYP_Delete                  // 5
};

enum ENodeNotify
{
	NODEMSG_NewAction,              // 0
	NODEMSG_NewMode,                // 1
	NODEMSG_NewSpeed,               // 2
	NODEMSG_NewNode,                // 3
	NODEMSG_GoCodeLaunched,         // 4
	NODEMSG_ActionNodeCompleted,    // 5
	NODEMSG_WaitingGoCode,          // 6
	NODEMSG_NodeReached,            // 7
	NODEMSG_PlayerLeft,             // 8
	NODEMSG_SnipeUntilGoCode,       // 9
	NODEMSG_BreachDoorAtGoCode      // 10
};

enum ePlayerTeamSelection
{
	PTS_UnSelected,                 // 0
	PTS_AutoSelect,                 // 1
	PTS_Alpha,                      // 2
	PTS_Bravo,                      // 3
	PTS_Spectator                   // 4
};

enum ECamOrientation
{
	CAMORIENT_None,                 // 0
	CAMORIENT_LookAtActor,          // 1
	CAMORIENT_FacePath,             // 2
	CAMORIENT_Interpolate,          // 3
	CAMORIENT_Dolly                 // 4
};

struct Guid
{
	var int A;
	var int B;
	var int C;
	var int D;
};

struct Vector
{
	var() config float X;
	var() config float Y;
	var() config float Z;
};

struct Plane extends Vector
{
	var() config float W;
};

struct Rotator
{
	var() config int Pitch;
// NEW IN 1.60
	var() config int Yaw;
// NEW IN 1.60
	var() config int Roll;
};

struct Coords
{
	var() config Vector Origin;
// NEW IN 1.60
	var() config Vector XAxis;
// NEW IN 1.60
	var() config Vector YAxis;
// NEW IN 1.60
	var() config Vector ZAxis;
};

struct Range
{
	var() config float Min;
	var() config float Max;
};

struct RangeVector
{
	var() config Range X;
	var() config Range Y;
	var() config Range Z;
};

struct Scale
{
	enum ESheerAxis
	{
		SHEER_None,                     // 0
		SHEER_XY,                       // 1
		SHEER_XZ,                       // 2
		SHEER_YX,                       // 3
		SHEER_YZ,                       // 4
		SHEER_ZX,                       // 5
		SHEER_ZY                        // 6
	};

	var() config Vector Scale;
	var() config float SheerRate;
// NEW IN 1.60
	var() config ESheerAxis SheerAxis;
};

struct Color
{
	var() config byte B;
	var() config byte G;
	var() config byte R;
	var() config byte A;
};

struct Box
{
	var Vector Min;
	var Vector Max;
	var byte IsValid;
};

struct BoundingVolume extends Box
{
	var Plane Sphere;
};

struct Matrix
{
	var() Plane XPlane;
	var() Plane YPlane;
	var() Plane ZPlane;
	var() Plane WPlane;
};

struct InterpCurvePoint
{
	var() float InVal;
	var() float OutVal;
};

struct InterpCurve
{
	var() array<InterpCurvePoint> Points;
};

struct Region
{
	var() int X;
	var() int Y;
	var() int W;
	var() int H;
};

struct CompressedPosition
{
	var Vector Location;
	var Rotator Rotation;
	var Vector Velocity;
};

// Internal variables.
var private native const int ObjectInternal[6];
var native const Object Outer;
var native const int ObjectFlags;
var() native const editconst name Name;
var native const editconst Class Class;
// ***********************************************************************************************
// * BEGIN UBI MODIF joel tremblay (16 juil 2003)
// ***********************************************************************************************
var private native const int DName;

// Export UObject::execNot_PreBool(FFrame&, void* const)
    native(129) static final preoperator bool !(bool A);

// Export UObject::execEqualEqual_BoolBool(FFrame&, void* const)
    native(242) static final operator(24) bool ==(bool A, bool B);

// Export UObject::execNotEqual_BoolBool(FFrame&, void* const)
    native(243) static final operator(26) bool !=(bool A, bool B);

// Export UObject::execAndAnd_BoolBool(FFrame&, void* const)
    native(130) static final operator(30) bool &&(bool A, skip bool B);

// Export UObject::execXorXor_BoolBool(FFrame&, void* const)
    native(131) static final operator(30) bool ^^(bool A, bool B);

// Export UObject::execOrOr_BoolBool(FFrame&, void* const)
    native(132) static final operator(32) bool ||(bool A, skip bool B);

// Export UObject::execMultiplyEqual_ByteByte(FFrame&, void* const)
    native(133) static final operator(34) byte *=(out byte A, byte B);

// Export UObject::execDivideEqual_ByteByte(FFrame&, void* const)
    native(134) static final operator(34) byte /=(out byte A, byte B);

// Export UObject::execAddEqual_ByteByte(FFrame&, void* const)
    native(135) static final operator(34) byte +=(out byte A, byte B);

// Export UObject::execSubtractEqual_ByteByte(FFrame&, void* const)
    native(136) static final operator(34) byte -=(out byte A, byte B);

// Export UObject::execAddAdd_PreByte(FFrame&, void* const)
    native(137) static final preoperator byte ++(out byte A);

// Export UObject::execSubtractSubtract_PreByte(FFrame&, void* const)
    native(138) static final preoperator byte --(out byte A);

// Export UObject::execAddAdd_Byte(FFrame&, void* const)
    native(139) static final postoperator byte ++(out byte A);

// Export UObject::execSubtractSubtract_Byte(FFrame&, void* const)
    native(140) static final postoperator byte --(out byte A);

// Export UObject::execComplement_PreInt(FFrame&, void* const)
    native(141) static final preoperator int ~(int A);

// Export UObject::execSubtract_PreInt(FFrame&, void* const)
    native(143) static final preoperator int -(int A);

// Export UObject::execMultiply_IntInt(FFrame&, void* const)
    native(144) static final operator(16) int *(int A, int B);

// Export UObject::execDivide_IntInt(FFrame&, void* const)
    native(145) static final operator(16) int /(int A, int B);

// Export UObject::execAdd_IntInt(FFrame&, void* const)
    native(146) static final operator(20) int +(int A, int B);

// Export UObject::execSubtract_IntInt(FFrame&, void* const)
    native(147) static final operator(20) int -(int A, int B);

// Export UObject::execLessLess_IntInt(FFrame&, void* const)
    native(148) static final operator(22) int <<(int A, int B);

// Export UObject::execGreaterGreater_IntInt(FFrame&, void* const)
    native(149) static final operator(22) int >>(int A, int B);

// Export UObject::execGreaterGreaterGreater_IntInt(FFrame&, void* const)
    native(196) static final operator(22) int >>>(int A, int B);

// Export UObject::execLess_IntInt(FFrame&, void* const)
    native(150) static final operator(24) bool <(int A, int B);

// Export UObject::execGreater_IntInt(FFrame&, void* const)
    native(151) static final operator(24) bool >(int A, int B);

// Export UObject::execLessEqual_IntInt(FFrame&, void* const)
    native(152) static final operator(24) bool <=(int A, int B);

// Export UObject::execGreaterEqual_IntInt(FFrame&, void* const)
    native(153) static final operator(24) bool >=(int A, int B);

// Export UObject::execEqualEqual_IntInt(FFrame&, void* const)
    native(154) static final operator(24) bool ==(int A, int B);

// Export UObject::execNotEqual_IntInt(FFrame&, void* const)
    native(155) static final operator(26) bool !=(int A, int B);

// Export UObject::execAnd_IntInt(FFrame&, void* const)
    native(156) static final operator(28) int &(int A, int B);

// Export UObject::execXor_IntInt(FFrame&, void* const)
    native(157) static final operator(28) int ^(int A, int B);

// Export UObject::execOr_IntInt(FFrame&, void* const)
    native(158) static final operator(28) int |(int A, int B);

// Export UObject::execMultiplyEqual_IntFloat(FFrame&, void* const)
    native(159) static final operator(34) int *=(out int A, float B);

// Export UObject::execDivideEqual_IntFloat(FFrame&, void* const)
    native(160) static final operator(34) int /=(out int A, float B);

// Export UObject::execAddEqual_IntInt(FFrame&, void* const)
    native(161) static final operator(34) int +=(out int A, int B);

// Export UObject::execSubtractEqual_IntInt(FFrame&, void* const)
    native(162) static final operator(34) int -=(out int A, int B);

// Export UObject::execAddAdd_PreInt(FFrame&, void* const)
    native(163) static final preoperator int ++(out int A);

// Export UObject::execSubtractSubtract_PreInt(FFrame&, void* const)
    native(164) static final preoperator int --(out int A);

// Export UObject::execAddAdd_Int(FFrame&, void* const)
    native(165) static final postoperator int ++(out int A);

// Export UObject::execSubtractSubtract_Int(FFrame&, void* const)
    native(166) static final postoperator int --(out int A);

// Export UObject::execRand(FFrame&, void* const)
// Integer functions.
native(167) static final function int Rand(int Max);

// Export UObject::execMin(FFrame&, void* const)
native(249) static final function int Min(int A, int B);

// Export UObject::execMax(FFrame&, void* const)
native(250) static final function int Max(int A, int B);

// Export UObject::execClamp(FFrame&, void* const)
native(251) static final function int Clamp(int V, int A, int B);

// Export UObject::execSubtract_PreFloat(FFrame&, void* const)
    native(169) static final preoperator float -(float A);

// Export UObject::execMultiplyMultiply_FloatFloat(FFrame&, void* const)
    native(170) static final operator(12) float **(float A, float B);

// Export UObject::execMultiply_FloatFloat(FFrame&, void* const)
    native(171) static final operator(16) float *(float A, float B);

// Export UObject::execDivide_FloatFloat(FFrame&, void* const)
    native(172) static final operator(16) float /(float A, float B);

// Export UObject::execPercent_FloatFloat(FFrame&, void* const)
    native(173) static final operator(18) float %(float A, float B);

// Export UObject::execAdd_FloatFloat(FFrame&, void* const)
    native(174) static final operator(20) float +(float A, float B);

// Export UObject::execSubtract_FloatFloat(FFrame&, void* const)
    native(175) static final operator(20) float -(float A, float B);

// Export UObject::execLess_FloatFloat(FFrame&, void* const)
    native(176) static final operator(24) bool <(float A, float B);

// Export UObject::execGreater_FloatFloat(FFrame&, void* const)
    native(177) static final operator(24) bool >(float A, float B);

// Export UObject::execLessEqual_FloatFloat(FFrame&, void* const)
    native(178) static final operator(24) bool <=(float A, float B);

// Export UObject::execGreaterEqual_FloatFloat(FFrame&, void* const)
    native(179) static final operator(24) bool >=(float A, float B);

// Export UObject::execEqualEqual_FloatFloat(FFrame&, void* const)
    native(180) static final operator(24) bool ==(float A, float B);

// Export UObject::execComplementEqual_FloatFloat(FFrame&, void* const)
    native(210) static final operator(24) bool ~=(float A, float B);

// Export UObject::execNotEqual_FloatFloat(FFrame&, void* const)
    native(181) static final operator(26) bool !=(float A, float B);

// Export UObject::execMultiplyEqual_FloatFloat(FFrame&, void* const)
    native(182) static final operator(34) float *=(out float A, float B);

// Export UObject::execDivideEqual_FloatFloat(FFrame&, void* const)
    native(183) static final operator(34) float /=(out float A, float B);

// Export UObject::execAddEqual_FloatFloat(FFrame&, void* const)
    native(184) static final operator(34) float +=(out float A, float B);

// Export UObject::execSubtractEqual_FloatFloat(FFrame&, void* const)
    native(185) static final operator(34) float -=(out float A, float B);

// Export UObject::execAbs(FFrame&, void* const)
// Float functions.
native(186) static final function float Abs(float A);

// Export UObject::execSin(FFrame&, void* const)
native(187) static final function float Sin(float A);

// Export UObject::execAsin(FFrame&, void* const)
native static final function float Asin(float A);

// Export UObject::execCos(FFrame&, void* const)
native(188) static final function float Cos(float A);

// Export UObject::execAcos(FFrame&, void* const)
native static final function float Acos(float A);

// Export UObject::execTan(FFrame&, void* const)
native(189) static final function float Tan(float A);

// Export UObject::execAtan(FFrame&, void* const)
native(190) static final function float Atan(float A);

// Export UObject::execExp(FFrame&, void* const)
native(191) static final function float Exp(float A);

// Export UObject::execLoge(FFrame&, void* const)
native(192) static final function float Loge(float A);

// Export UObject::execSqrt(FFrame&, void* const)
native(193) static final function float Sqrt(float A);

// Export UObject::execSquare(FFrame&, void* const)
native(194) static final function float Square(float A);

// Export UObject::execFRand(FFrame&, void* const)
native(195) static final function float FRand();

// Export UObject::execFMin(FFrame&, void* const)
native(244) static final function float FMin(float A, float B);

// Export UObject::execFMax(FFrame&, void* const)
native(245) static final function float FMax(float A, float B);

// Export UObject::execFClamp(FFrame&, void* const)
native(246) static final function float FClamp(float V, float A, float B);

// Export UObject::execLerp(FFrame&, void* const)
native(247) static final function float Lerp(float Alpha, float A, float B);

// Export UObject::execSmerp(FFrame&, void* const)
native(248) static final function float Smerp(float Alpha, float A, float B);

// Export UObject::execSubtract_PreVector(FFrame&, void* const)
    native(211) static final preoperator Vector -(Vector A);

// Export UObject::execMultiply_VectorFloat(FFrame&, void* const)
    native(212) static final operator(16) Vector *(Vector A, float B);

// Export UObject::execMultiply_FloatVector(FFrame&, void* const)
    native(213) static final operator(16) Vector *(float A, Vector B);

// Export UObject::execMultiply_VectorVector(FFrame&, void* const)
    native(296) static final operator(16) Vector *(Vector A, Vector B);

// Export UObject::execDivide_VectorFloat(FFrame&, void* const)
    native(214) static final operator(16) Vector /(Vector A, float B);

// Export UObject::execAdd_VectorVector(FFrame&, void* const)
    native(215) static final operator(20) Vector +(Vector A, Vector B);

// Export UObject::execSubtract_VectorVector(FFrame&, void* const)
    native(216) static final operator(20) Vector -(Vector A, Vector B);

// Export UObject::execLessLess_VectorRotator(FFrame&, void* const)
    native(275) static final operator(22) Vector <<(Vector A, Rotator B);

// Export UObject::execGreaterGreater_VectorRotator(FFrame&, void* const)
    native(276) static final operator(22) Vector >>(Vector A, Rotator B);

// Export UObject::execEqualEqual_VectorVector(FFrame&, void* const)
    native(217) static final operator(24) bool ==(Vector A, Vector B);

// Export UObject::execNotEqual_VectorVector(FFrame&, void* const)
    native(218) static final operator(26) bool !=(Vector A, Vector B);

// Export UObject::execDot_VectorVector(FFrame&, void* const)
    native(219) static final operator(16) float Dot(Vector A, Vector B);

// Export UObject::execCross_VectorVector(FFrame&, void* const)
    native(220) static final operator(16) Vector Cross(Vector A, Vector B);

// Export UObject::execMultiplyEqual_VectorFloat(FFrame&, void* const)
    native(221) static final operator(34) Vector *=(out Vector A, float B);

// Export UObject::execMultiplyEqual_VectorVector(FFrame&, void* const)
    native(297) static final operator(34) Vector *=(out Vector A, Vector B);

// Export UObject::execDivideEqual_VectorFloat(FFrame&, void* const)
    native(222) static final operator(34) Vector /=(out Vector A, float B);

// Export UObject::execAddEqual_VectorVector(FFrame&, void* const)
    native(223) static final operator(34) Vector +=(out Vector A, Vector B);

// Export UObject::execSubtractEqual_VectorVector(FFrame&, void* const)
    native(224) static final operator(34) Vector -=(out Vector A, Vector B);

// Export UObject::execVSize(FFrame&, void* const)
// Vector functions.
native(225) static final function float VSize(Vector A);

// Export UObject::execNormal(FFrame&, void* const)
native(226) static final function Vector Normal(Vector A);

// Export UObject::execInvert(FFrame&, void* const)
native(227) static final function Invert(out Vector X, out Vector Y, out Vector Z);

// Export UObject::execVRand(FFrame&, void* const)
native(252) static final function Vector VRand();

// Export UObject::execMirrorVectorByNormal(FFrame&, void* const)
native(300) static final function Vector MirrorVectorByNormal(Vector Vect, Vector Normal);

// Export UObject::execEqualEqual_RotatorRotator(FFrame&, void* const)
    native(142) static final operator(24) bool ==(Rotator A, Rotator B);

// Export UObject::execNotEqual_RotatorRotator(FFrame&, void* const)
    native(203) static final operator(26) bool !=(Rotator A, Rotator B);

// Export UObject::execMultiply_RotatorFloat(FFrame&, void* const)
    native(287) static final operator(16) Rotator *(Rotator A, float B);

// Export UObject::execMultiply_FloatRotator(FFrame&, void* const)
    native(288) static final operator(16) Rotator *(float A, Rotator B);

// Export UObject::execDivide_RotatorFloat(FFrame&, void* const)
    native(289) static final operator(16) Rotator /(Rotator A, float B);

// Export UObject::execMultiplyEqual_RotatorFloat(FFrame&, void* const)
    native(290) static final operator(34) Rotator *=(out Rotator A, float B);

// Export UObject::execDivideEqual_RotatorFloat(FFrame&, void* const)
    native(291) static final operator(34) Rotator /=(out Rotator A, float B);

// Export UObject::execAdd_RotatorRotator(FFrame&, void* const)
    native(316) static final operator(20) Rotator +(Rotator A, Rotator B);

// Export UObject::execSubtract_RotatorRotator(FFrame&, void* const)
    native(317) static final operator(20) Rotator -(Rotator A, Rotator B);

// Export UObject::execAddEqual_RotatorRotator(FFrame&, void* const)
    native(318) static final operator(34) Rotator +=(out Rotator A, Rotator B);

// Export UObject::execSubtractEqual_RotatorRotator(FFrame&, void* const)
    native(319) static final operator(34) Rotator -=(out Rotator A, Rotator B);

// Export UObject::execGetAxes(FFrame&, void* const)
native(229) static final function GetAxes(Rotator A, out Vector X, out Vector Y, out Vector Z);

// Export UObject::execGetUnAxes(FFrame&, void* const)
native(230) static final function GetUnAxes(Rotator A, out Vector X, out Vector Y, out Vector Z);

// Export UObject::execRotRand(FFrame&, void* const)
native(320) static final function Rotator RotRand(optional bool bRoll);

// Export UObject::execOrthoRotation(FFrame&, void* const)
native static final function Rotator OrthoRotation(Vector X, Vector Y, Vector Z);

// Export UObject::execNormalize(FFrame&, void* const)
native static final function Rotator Normalize(Rotator Rot);

// Export UObject::execClockwiseFrom_IntInt(FFrame&, void* const)
    native static final operator(24) bool ClockwiseFrom(int A, int B);

// Export UObject::execShortestAngle2D(FFrame&, void* const)
//#ifdef R6CODE
// Return the shortest angle (between 0 and 32767) between two parts of a rotator (ie, two yaw)
native(1851) static final function int ShortestAngle2D(int iAngle1, int iAngle2);

// Export UObject::execGetRegistryKey(FFrame&, void* const)
native(1854) static final function bool GetRegistryKey(string Dir, string Key, out string Value);

// Export UObject::execSetRegistryKey(FFrame&, void* const)
native(1855) static final function bool SetRegistryKey(string Dir, string Key, string Value);

// Export UObject::execConcat_StrStr(FFrame&, void* const)
    native(112) static final operator(40) string $(coerce string A, coerce string B);

// Export UObject::execAt_StrStr(FFrame&, void* const)
    native(168) static final operator(40) string @(coerce string A, coerce string B);

// Export UObject::execLess_StrStr(FFrame&, void* const)
    native(115) static final operator(24) bool <(string A, string B);

// Export UObject::execGreater_StrStr(FFrame&, void* const)
    native(116) static final operator(24) bool >(string A, string B);

// Export UObject::execLessEqual_StrStr(FFrame&, void* const)
    native(120) static final operator(24) bool <=(string A, string B);

// Export UObject::execGreaterEqual_StrStr(FFrame&, void* const)
    native(121) static final operator(24) bool >=(string A, string B);

// Export UObject::execEqualEqual_StrStr(FFrame&, void* const)
    native(122) static final operator(24) bool ==(string A, string B);

// Export UObject::execNotEqual_StrStr(FFrame&, void* const)
    native(123) static final operator(26) bool !=(string A, string B);

// Export UObject::execComplementEqual_StrStr(FFrame&, void* const)
    native(124) static final operator(24) bool ~=(string A, string B);

// Export UObject::execLen(FFrame&, void* const)
// String functions.
native(125) static final function int Len(coerce string S);

// Export UObject::execInStr(FFrame&, void* const)
native(126) static final function int InStr(coerce string S, coerce string t);

// Export UObject::execMid(FFrame&, void* const)
native(127) static final function string Mid(coerce string S, int i, optional int j);

// Export UObject::execLeft(FFrame&, void* const)
native(128) static final function string Left(coerce string S, int i);

// Export UObject::execRight(FFrame&, void* const)
native(234) static final function string Right(coerce string S, int i);

// Export UObject::execCaps(FFrame&, void* const)
native(235) static final function string Caps(coerce string S);

// Export UObject::execChr(FFrame&, void* const)
native(236) static final function string Chr(int i);

// Export UObject::execAsc(FFrame&, void* const)
native(237) static final function int Asc(string S);

// Export UObject::execRemoveInvalidChars(FFrame&, void* const)
// #ifdef R6CODE
native(238) static final function string RemoveInvalidChars(string S);

// Export UObject::execItoa(FFrame&, void* const)
native(1227) static final function string Itoa(int i);

// Export UObject::execAtoi(FFrame&, void* const)
native(1228) static final function int Atoi(coerce string S);

// Export UObject::execStrnicmp(FFrame&, void* const)
native(1306) static final function int Strnicmp(coerce string A, coerce string B, int iCount);

// Export UObject::execEqualEqual_ObjectObject(FFrame&, void* const)
    native(114) static final operator(24) bool ==(Object A, Object B);

// Export UObject::execNotEqual_ObjectObject(FFrame&, void* const)
    native(119) static final operator(26) bool !=(Object A, Object B);

// Export UObject::execEqualEqual_NameName(FFrame&, void* const)
    native(254) static final operator(24) bool ==(name A, name B);

// Export UObject::execNotEqual_NameName(FFrame&, void* const)
    native(255) static final operator(26) bool !=(name A, name B);

// Export UObject::execInterpCurveEval(FFrame&, void* const)
// InterpCurve operator
native static final function float InterpCurveEval(InterpCurve curve, float Input);

// Export UObject::execLogSnd(FFrame&, void* const)
// Logging.
native(2718) static final function LogSnd(coerce string S, optional name Tag);

// Export UObject::execLog(FFrame&, void* const)
native(231) static final function Log(coerce string S, optional name Tag);

// Export UObject::execWarn(FFrame&, void* const)
native(232) static final function Warn(coerce string S);

// Export UObject::execLocalize(FFrame&, void* const)
// #ifdef R6CODE
native static function string Localize(string SectionName, string KeyName, string PackageName, optional bool bNoDebug, optional bool bMultipleToken, optional bool bForceEnglish);

// Export UObject::execGotoState(FFrame&, void* const)
// Goto state and label.
native(113) final function GotoState(optional name NewState, optional name Label);

// Export UObject::execIsInState(FFrame&, void* const)
native(281) final function bool IsInState(name TestState);

// Export UObject::execGetStateName(FFrame&, void* const)
native(284) final function name GetStateName();

// Export UObject::execClassIsChildOf(FFrame&, void* const)
// Objects.
native(258) static final function bool ClassIsChildOf(Class TestClass, Class ParentClass);

// Export UObject::execIsA(FFrame&, void* const)
native(303) final function bool IsA(name ClassName);

// Export UObject::execEnable(FFrame&, void* const)
// Probe messages.
native(117) final function Enable(name ProbeFunc);

// Export UObject::execDisable(FFrame&, void* const)
native(118) final function Disable(name ProbeFunc);

// Export UObject::execGetPropertyText(FFrame&, void* const)
// Properties.
native final function string GetPropertyText(string PropName);

// Export UObject::execSetPropertyText(FFrame&, void* const)
native final function SetPropertyText(string PropName, string PropValue);

// Export UObject::execGetEnum(FFrame&, void* const)
native static final function name GetEnum(Object E, int i);

// Export UObject::execDynamicLoadObject(FFrame&, void* const)
native static final function Object DynamicLoadObject(string ObjectName, Class ObjectClass, optional bool MayFail);

// Export UObject::execFindObject(FFrame&, void* const)
native static final function Object FindObject(string ObjectName, Class ObjectClass);

// Export UObject::execSaveConfig(FFrame&, void* const)
// Configuration.
// #ifdef R6CODE
native(536) final function SaveConfig(optional string FileName);

// Export UObject::execStaticSaveConfig(FFrame&, void* const)
native static final function StaticSaveConfig();

// Export UObject::execLoadConfig(FFrame&, void* const)
// #ifdef R6CODE
native(1010) final function LoadConfig(optional string FileName);

// Export UObject::execResetConfig(FFrame&, void* const)
native static final function ResetConfig(optional string VarNameToReset);

// Return a random number within the given range.
final function float RandRange(float Min, float Max)
{
	return __NFUN_174__(Min, __NFUN_171__(__NFUN_175__(Max, Min), __NFUN_195__()));
	return;
}

// Export UObject::execGetFirstPackageClass(FFrame&, void* const)
//R6DESCRIPTIONS
//Make sure you call FreePackageObjects after your last GetNextObject() call
native(1005) static final function Class GetFirstPackageClass(string Package, Class ObjectClass);

// Export UObject::execGetNextClass(FFrame&, void* const)
native(1006) static final function Class GetNextClass();

// Export UObject::execRewindToFirstClass(FFrame&, void* const)
native(1301) static final function Class RewindToFirstClass();

// Export UObject::execFreePackageObjects(FFrame&, void* const)
native(1007) static final function FreePackageObjects();

// Export UObject::execClearOuter(FFrame&, void* const)
// R6CODE
native(1850) static final function ClearOuter();

// Export UObject::execClock(FFrame&, void* const)
native(1852) static final function Clock(int iCounter);

// Export UObject::execUnclock(FFrame&, void* const)
native(1853) static final function Unclock(int iCounter);

//
// Called immediately when entering a state, while within
// the GotoState call that caused the state change.
//
event BeginState()
{
	return;
}

//
// Called immediately before going out of the current state,
// while within the GotoState call that caused the state change.
// 
event EndState()
{
	return;
}


// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var l
// REMOVED IN 1.60: var s
// REMOVED IN 1.60: var ESheerAxis
// REMOVED IN 1.60: function InitMod
