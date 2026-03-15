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
	if((VSize(NewAccel) > float(3072)))
	{
		NewAccel = (float(3072) * Normal(NewAccel));
	}
	// End:0x67
	if((Delta > float(0)))
	{
		Acceleration = (((DeltaTime * NewAccel) + (Delta * Acceleration)) / (Delta + DeltaTime));		
	}
	else
	{
		Acceleration = NewAccel;
	}
	(Delta += DeltaTime);
	// End:0x99
	if((int(DoubleClickMove) == int(0)))
	{
		DoubleClickMove = InDoubleClick;
	}
	bRun = (int(P.bRun) > 0);
	bDuck = (int(P.bDuck) > 0);
	TimeStamp = Level.TimeSeconds;
	m_bCrawl = P.m_bCrawl;
	return;
}

