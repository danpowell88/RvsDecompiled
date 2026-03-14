//=============================================================================
// For internal testing.
//=============================================================================
class TestInfo extends Info;

// --- Constants ---
const Pie = 3.14;
const Str = "Tim";
const Lotus = vect(1,2,3);

// --- Structs ---
struct STest
{
    var bool b1;
    var bool b2;
    var bool b3;
    var int i;
};

// --- Variables ---
// var ? b1; // REMOVED IN 1.60
// var ? b2; // REMOVED IN 1.60
// var ? b3; // REMOVED IN 1.60
// var ? i; // REMOVED IN 1.60
var STest ST;
// ^ NEW IN 1.60
var Vector v1;
// ^ NEW IN 1.60
var int xnum;
// ^ NEW IN 1.60
var Vector v2;
var bool bFalse2;
// ^ NEW IN 1.60
var bool bTrue2;
// ^ NEW IN 1.60
var bool bFalse1;
// ^ NEW IN 1.60
var bool bTrue1;
// ^ NEW IN 1.60
var bool bBool2;
var int MyArray[2];
var bool bBool1;
var float ppp;
var string sxx;
var string TestRepStr;

// --- Functions ---
function f() {}
function SubTestOptionalOut(out optional int B, out optional int C, out optional int A) {}
function TestNullContext(Actor A) {}
function TestContinueForEach() {}
static function int TestStatic(int i) {}
// ^ NEW IN 1.60
function TestX(bool bResource) {}
function TestSwitch() {}
function TestContinueWhile() {}
function BeginPlay() {}
function TestContinueDoUntil() {}
function Tick(float DeltaTime) {}
function TestContinueFor() {}
function TestQ() {}
function TestOptionalOut() {}
static function int OtherStatic(int i) {}
// ^ NEW IN 1.60
function TestLimitor(class<Object> C) {}
static function test() {}
function PostBeginPlay() {}
function TestStructBools() {}
function bool RecurseTest() {}
// ^ NEW IN 1.60
function temp() {}

state AA
{
    function f() {}
}

state DDAA
{
    function f() {}
}

state BB
{
    function f() {}
}

state CCAA
{
    function f() {}
}

state EEDDAA
{
    function f() {}
}

defaultproperties
{
}
