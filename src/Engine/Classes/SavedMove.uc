//=============================================================================
// SavedMove - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
// SavedMove is used during network play to buffer recent client moves,
// for use when the server modifies the clients actual position, etc.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class SavedMove extends Info
    native
    notplaceable
    hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

//rb var bool	bPressedJump;	
var Actor.EDoubleClickDir DoubleClickMove;  // Double click info.
var bool bRun;
var bool bDuck;
// #ifdef R6PlayerMovements
var bool m_bCrawl;
var float TimeStamp;  // Time of this move.
var float Delta;  // Distance moved.
// also stores info in Acceleration attribute
var SavedMove NextMove;  // Next move in linked list.

final function Clear()
{
	TimeStamp = 0.0000000;
	Delta = 0.0000000;
	DoubleClickMove = 0;
	Acceleration = vect(0.0000000, 0.0000000, 0.0000000);
	bRun = false;
	bDuck = false;
	m_bCrawl = false;
	return;
}

final function SetMoveFor(PlayerController P, float DeltaTime, Vector NewAccel, Actor.EDoubleClickDir InDoubleClick)
{
	// End:0x29
	if(__NFUN_177__(__NFUN_225__(NewAccel), float(3072)))
	{
		NewAccel = __NFUN_213__(float(3072), __NFUN_226__(NewAccel));
	}
	// End:0x67
	if(__NFUN_177__(Delta, float(0)))
	{
		Acceleration = __NFUN_214__(__NFUN_215__(__NFUN_213__(DeltaTime, NewAccel), __NFUN_213__(Delta, Acceleration)), __NFUN_174__(Delta, DeltaTime));		
	}
	else
	{
		Acceleration = NewAccel;
	}
	__NFUN_184__(Delta, DeltaTime);
	// End:0x99
	if(__NFUN_154__(int(DoubleClickMove), int(0)))
	{
		DoubleClickMove = InDoubleClick;
	}
	bRun = __NFUN_151__(int(P.bRun), 0);
	bDuck = __NFUN_151__(int(P.bDuck), 0);
	TimeStamp = Level.TimeSeconds;
	m_bCrawl = P.m_bCrawl;
	return;
}

