//=============================================================================
// R6BoltActionSniperRifle - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//============================================================================//
//  R6BoltActionSniperRifle.uc
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//============================================================================//
class R6BoltActionSniperRifle extends R6SniperRifle
    abstract;

state NormalFire
{
	function Fire(float Value)
	{
		return;
	}
	stop;
}

