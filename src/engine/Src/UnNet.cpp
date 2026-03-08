/*=============================================================================
	UnNet.cpp: UNetDriver, UNetConnection, UChannel class registration.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations for the networking classes.
	These manage client/server connections, channel multiplexing, and
	actor replication. UNetConnection and UChannel method bodies
	currently live in EngineClassImpl.cpp and will migrate here as
	network code is fully decompiled.

	This file is permanent and will grow as networking code is
	decompiled.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(UNetDriver);
IMPLEMENT_CLASS(UNetConnection);
IMPLEMENT_CLASS(UChannel);
IMPLEMENT_CLASS(UActorChannel);
IMPLEMENT_CLASS(UControlChannel);
IMPLEMENT_CLASS(UFileChannel);
IMPLEMENT_CLASS(UPackageMapLevel);
