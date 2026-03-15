//=============================================================================
// TestInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
// For internal testing.
//=============================================================================
class TestInfo extends Info
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

const Pie = 3.14;
const Str = "Tim";
const Lotus = vect(1,2,3);

struct STest
{
	var bool b1;
	var int i;
	var bool b2;
	var bool b3;
};

var() int xnum;  // Test integer; default 777, used by static function assertions
var int MyArray[2];  // Two-element test array indexed via bool cast
var() bool bTrue1;  // Test bool, default true
var() bool bFalse1;  // Test bool, default false
var() bool bTrue2;  // Test bool, default true
var() bool bFalse2;  // Test bool, default false
var bool bBool1;  // Scratch bool set by RecurseTest
var bool bBool2;  // Stores the return value from RecurseTest
var float ppp;  // Test float; default 3.14 (matches the Pie constant)
var Vector v1;  // Test vector used in vector comparison assertions
// NEW IN 1.60
var Vector v2;
// NEW IN 1.60
var STest ST;  // Test struct instance for bool bit-packing validation
var string sxx;  // Test string; default "Tim" (matches the Str constant)
var string TestRepStr;  // Placeholder string for replication tests

function TestQ()  // Tests vector field assignment and component comparison
{
	local Vector V;

	V.X = 2.0000000;
	V.Y = 3.0000000;
	V.Z = 4.0000000;
	assert((V == vect(2.0000000, 3.0000000, 4.0000000)));
	assert((V.Z == float(4)));
	assert((V.Y == float(3)));
	assert((V.X == float(2)));
	return;
}

static function test()  // Static helper: sets default v1 via static class reference
{
	Class'Engine.TestInfo'.default.v1 = vect(1.0000000, 2.0000000, 3.0000000);
	return;
}

function PostBeginPlay()  // Runs IsA and default-property assertions on startup
{
	local Object o;
	local Actor TempActor;

	Log("!!BEGIN");
	default.v1 = vect(5.0000000, 4.0000000, 3.0000000);
	assert((default.v1 == vect(5.0000000, 4.0000000, 3.0000000)));
	test();
	assert((default.v1 == vect(1.0000000, 2.0000000, 3.0000000)));
	assert(IsA('Actor'));
	assert(IsA('TestInfo'));
	assert(IsA('Info'));
	assert((!IsA('LevelInfo')));
	assert((!IsA('Texture')));
	Log("!!END");
	return;
}

function TestStructBools()  // Verifies bit-packed bool fields in STest struct
{
	assert((ST.b1 == false));
	assert((ST.b2 == false));
	assert((ST.b3 == false));
	ST.b1 = true;
	assert((ST.b1 == true));
	assert((ST.b2 == false));
	assert((ST.b3 == false));
	ST.b2 = true;
	assert((ST.b1 == true));
	assert((ST.b2 == true));
	assert((ST.b3 == false));
	ST.b3 = true;
	assert((ST.b1 == true));
	assert((ST.b2 == true));
	assert((ST.b3 == true));
	ST.b1 = false;
	ST.b2 = false;
	ST.b3 = false;
	return;
}

function BeginPlay()  // Instantiates TestObj and runs struct bool tests
{
	local TestObj to;
	local Object oo;

	to = new Class'Engine.TestObj';
	to = new Class'Engine.TestObj';
	to = new (self) Class'Engine.TestObj';
	to = new (self, "") Class'Engine.TestObj';
	to = new (self, "", 0) Class'Engine.TestObj';
	to.test();
	TestStructBools();
	return;
}

function TestX(bool bResource)  // Tests bool-to-int cast and bool-indexed array access
{
	local int N;

	N = int(bResource);
	MyArray[int(bResource)] = 0;
	(MyArray[int(bResource)]++);
	return;
}

function bool RecurseTest()  // Sets bBool1=true then returns false; used to test return values
{
	bBool1 = true;
	return false;
	return;
}

function TestLimitor(Class C)  // Tests class cast to Class<Actor>
{
	local Class<Actor> NewClass;

	NewClass = Class<Actor>(C);
	return;
}

static function int OtherStatic(int i)  // Asserts i==246 and default.xnum==777; returns 555
{
	assert((i == 246));
	assert((default.xnum == 777));
	return 555;
	return;
}

static function int TestStatic(int i)  // Asserts i==123 and calls OtherStatic(i*2)
{
	assert((i == 123));
	assert((default.xnum == 777));
	assert((OtherStatic((i * 2)) == 555));
	return i;
	return;
}

function TestContinueFor()  // Tests continue statement behaviour inside a for loop
{
	local int i;

	Log("TestContinue");
	i = 0;
	J0x17:

	// End:0x76 [Loop If]
	if((i < 20))
	{
		Log(("iteration " $ string(i)));
		// End:0x65
		if((((i == 7) || (i == 9)) || (i == 19)))
		{
			// [Explicit Continue]
			goto J0x6C;
		}
		Log("...");
		J0x6C:

		(i++);
		// [Loop Continue]
		goto J0x17;
	}
	Log("DoneContinue");
	return;
}

function TestContinueWhile()  // Tests continue statement behaviour inside a while loop
{
	local int i;

	Log("TestContinue");
	J0x10:

	// End:0x5C [Loop If]
	if(((++i) <= 20))
	{
		Log(("iteration " $ string(i)));
		// End:0x52
		if(((i == 7) || (i == 9)))
		{			
		}
		else
		{
			Log("...");
		}
		// [Loop Continue]
		goto J0x10;
	}
	Log("DoneContinue");
	return;
}

function TestContinueDoUntil()  // Tests continue inside a do-until loop
{
	local int i;

	Log("TestContinue");
	J0x10:

	(i++);
	Log(("iteration " $ string(i)));
	// End:0x59
	if((((i == 7) || (i == 9)) || (i > 18)))
	{		
	}
	else
	{
		Log("...");
	}
	// End:0x10
	if(!((i > 20)))
		goto J0x10;
	Log("DoneContinue");
	return;
}

function TestContinueForEach()  // Tests continue inside a foreach AllActors loop
{
	local Actor A;

	Log("TestContinue");
	// End:0x4F
	foreach AllActors(Class'Engine.Actor', A)
	{
		Log(("actor " $ string(A)));
		// End:0x47
		if((Light(A) == none))
		{
			continue;			
		}
		Log("...");		
	}	
	Log("DoneContinue");
	return;
}

function SubTestOptionalOut(optional out int A, optional out int B, optional out int C)  // Helper: doubles each supplied out parameter
{
	(A *= float(2));
	B = (B * 2);
	(C += C);
	return;
}

function TestOptionalOut()  // Verifies optional out-parameter passing and skipping
{
	local int A, B, C;

	A = 1;
	B = 2;
	C = 3;
	SubTestOptionalOut(A, B, C);
	assert((A == 2));
	assert((B == 4));
	assert((C == 6));
	SubTestOptionalOut(A, B);
	assert((A == 4));
	assert((B == 8));
	assert((C == 6));
	SubTestOptionalOut(, B, C);
	assert((A == 4));
	assert((B == 16));
	assert((C == 12));
	SubTestOptionalOut();
	assert((A == 4));
	assert((B == 16));
	assert((C == 12));
	SubTestOptionalOut(A, B, C);
	assert((A == 8));
	assert((B == 32));
	assert((C == 24));
	Log("TestOptionalOut ok!");
	return;
}

function TestNullContext(Actor A)  // Tests property access when A may be None
{
	bHidden = A.bHidden;
	A.bHidden = bHidden;
	return;
}

function TestSwitch()  // Tests switch/case on int and string types
{
	local string S;
	local int i;
	local bool B;

	S = "Tim";
	i = 2;
	switch(i)
	{
		// End:0x25
		case 0:
			assert(false);
			// End:0x3F
			break;
		// End:0x35
		case 2:
			B = true;
			// End:0x3F
			break;
		// End:0xFFFF
		default:
			assert(false);
			// End:0x3F
			break;
			break;
	}
	assert(B);
	switch(S)
	{
		// End:0x5B
		case "":
			assert(false);
			// End:0x7A
			break;
		// End:0x6C
		case "xyzzy":
			assert(false);
			// End:0x7A
			break;
		// End:0xFFFF
		default:
			B = false;
			// End:0x7A
			break;
			break;
	}
	assert((!B));
	Log("testswitch succeeded");
	return;
}

function Tick(float DeltaTime)  // Main test runner: invokes all sub-tests every frame
{
	local Class C;
	local Class<TestInfo> TC;
	local Actor A;

	Log(("time=" $ string(Level.TimeSeconds)));
	TestOptionalOut();
	TestNullContext(self);
	TestNullContext(none);
	TestSwitch();
	v1 = vect(1.0000000, 2.0000000, 3.0000000);
	v2 = vect(2.0000000, 4.0000000, 6.0000000);
	assert((v1 != v2));
	assert((!(v1 == v2)));
	assert((v1 == vect(1.0000000, 2.0000000, 3.0000000)));
	assert((v2 == vect(2.0000000, 4.0000000, 6.0000000)));
	assert((vect(1.0000000, 2.0000000, 5.0000000) != v1));
	assert(((v1 * float(2)) == v2));
	assert((v1 == (v2 / float(2))));
	assert((3.1400000 == 3.1400000));
	assert((3.1400000 != float(2)));
	assert(("Tim" == "Tim"));
	assert(("Tim" != "Bob"));
	assert((vect(1.0000000, 2.0000000, 3.0000000) == vect(1.0000000, 2.0000000, 3.0000000)));
	assert((GetPropertyText("sxx") == "Tim"));
	assert((GetPropertyText("ppp") != "123"));
	assert((GetPropertyText("bogus") == ""));
	xnum = 345;
	assert((GetPropertyText("xnum") == "345"));
	SetPropertyText("xnum", "999");
	assert((xnum == 999));
	assert((xnum != 666));
	assert((bTrue1 == true));
	assert((bFalse1 == false));
	assert((bTrue2 == true));
	assert((bFalse2 == false));
	assert((default.bTrue1 == true));
	assert((default.bFalse1 == false));
	assert((default.bTrue2 == true));
	assert((default.bFalse2 == false));
	assert((Class'Engine.TestInfo'.default.bTrue1 == true));
	assert((Class'Engine.TestInfo'.default.bFalse1 == false));
	assert((Class'Engine.TestInfo'.default.bTrue2 == true));
	assert((Class'Engine.TestInfo'.default.bFalse2 == false));
	TC = Class;
	assert((TC.default.bTrue1 == true));
	assert((TC.default.bFalse1 == false));
	assert((TC.default.bTrue2 == true));
	assert((TC.default.bFalse2 == false));
	C = Class;
	assert((Class<TestInfo>(C).default.bTrue1 == true));
	assert((Class<TestInfo>(C).default.bFalse1 == false));
	assert((Class<TestInfo>(C).default.bTrue2 == true));
	assert((Class<TestInfo>(C).default.bFalse2 == false));
	assert((default.xnum == 777));
	TestStatic(123);
	TC.static.TestStatic(123);
	Class<TestInfo>(C).static.TestStatic(123);
	bBool2 = RecurseTest();
	assert((bBool2 == false));
	TestStructBools();
	TestQ();
	Log("All tests passed");
	return;
}

function f()  // Empty stub overridden in state machine tests
{
	return;
}

function temp()  // Scratch function; not called in production
{
	local int i;
	local PlayerController PlayerOwner;
	local name LeftList[20];

	temp();
	return;
}

state AA
{	stop;
}

state BB
{	stop;
}

state CCAA extends AA
{	stop;
}

state DDAA extends AA
{	stop;
}

state EEDDAA extends DDAA
{	stop;
}

defaultproperties
{
	xnum=777
	bTrue1=true
	bTrue2=true
	ppp=3.1400000
	sxx="Tim"
	RemoteRole=2
	bHidden=false
	bAlwaysRelevant=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var STest
