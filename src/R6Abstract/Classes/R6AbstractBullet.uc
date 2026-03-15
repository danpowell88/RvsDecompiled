//=============================================================================
// R6AbstractBullet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6AbstractBullet.uc :   This is the abstract class for the r6Bullet class.  We
//                          use an abstract class without any declared function.  
//                          This is useful to avoid circular references and accessing 
//                          classes that are declared in a package that is compiled later
//
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    Jan 8th, 2003 * Created by Joel Tremblay
//=============================================================================
class R6AbstractBullet extends Actor
    abstract
    native
    notplaceable;

function DoorExploded()
{
	return;
}

