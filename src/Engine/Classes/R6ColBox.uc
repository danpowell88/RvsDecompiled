//=============================================================================
// R6ColBox - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6ColBox.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6ColBox extends Actor
    native
    notplaceable;

var bool m_bActive;  // true when colliding, cannot be replaced by bCollideWorld/bCollideActor
var bool m_bCheckForEdges;  // check for edges (not when peeking)
var bool m_bCanStepUp;  // when prone, will try to step up/down
var bool m_bCollisionDetected;  // true when collide with something for a tick.
var float m_fFeetColBoxRadius;

replication
{
	// Pos:0x000
	reliable if(((bNetOwner && (int(Role) < int(ROLE_Authority))) || ((!bNetOwner) && (int(Role) == int(ROLE_Authority)))))
		m_bActive;

	// Pos:0x037
	reliable if((int(Role) == int(ROLE_Authority)))
		m_fFeetColBoxRadius;
}

// Export UR6ColBox::execEnableCollision(FFrame&, void* const)
//#ifdef R6CODE - pgaron 27 jan 2002
native(1503) final function EnableCollision(bool bEnable, optional bool bCheckForEdges, optional bool bCanStepUp);

function logC(string S)
{
	local string Time;
	local name baseName;

	// End:0x1F
	if((Base != none))
	{
		baseName = Base.Name;
	}
	Time = string(Level.TimeSeconds);
	Time = Left(Time, (InStr(Time, ".") + 3));
	Log(((((("[" $ Time) $ "] COL BOX (")) $ "): " $ ???) $ S));
	return;
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	Base.Trigger(Other, EventInstigator);
	return;
}

event UnTrigger(Actor Other, Pawn EventInstigator)
{
	Base.UnTrigger(Other, EventInstigator);
	return;
}

event HitWall(Vector HitNormal, Actor HitWall)
{
	// End:0x37
	if((Pawn(Base) != none))
	{
		Pawn(Base).Controller.HitWall(HitNormal, HitWall);
	}
	return;
}

event Touch(Actor Other)
{
	// End:0x1F
	if((Base != none))
	{
		Base.Touch(Other);
	}
	return;
}

event PostTouch(Actor Other)
{
	Base.PostTouch(Other);
	return;
}

event UnTouch(Actor Other)
{
	// End:0x1F
	if((Base != none))
	{
		Base.UnTouch(Other);
	}
	return;
}

event Bump(Actor Other)
{
	// End:0x32
	if((Pawn(Base) != none))
	{
		Pawn(Base).Controller.NotifyBump(Other);
	}
	return;
}

event bool EncroachingOn(Actor Other)
{
	return Base.EncroachingOn(Other);
	return;
}

event EncroachedBy(Actor Other)
{
	Base.EncroachedBy(Other);
	return;
}

event BaseChange()
{
	return;
}

function int R6TakeDamage(int iKillValue, int iStunValue, Pawn instigatedBy, Vector vHitLocation, Vector vMomentum, int iBulletToArmorModifier, optional int iBulletGoup)
{
	return Base.R6TakeDamage(iKillValue, iStunValue, instigatedBy, vHitLocation, vMomentum, iBulletToArmorModifier, iBulletGoup);
	return;
}

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
	Query.aQueryTarget = Base;
	Base.R6QueryCircumstantialAction(fDistance, Query, PlayerController);
	return;
}

simulated event Destroyed()
{
	EnableCollision(false);
	super.Destroyed();
	return;
}

simulated event bool GetReticuleInfo(Pawn ownerReticule, out string szName)
{
	return Base.GetReticuleInfo(ownerReticule, szName);
	return;
}

defaultproperties
{
	DrawType=0
	bHidden=true
	m_bReticuleInfo=true
	bBlockActors=true
	bBlockPlayers=true
	CollisionRadius=10.0000000
	CollisionHeight=10.0000000
}
