/*=============================================================================
	R6Engine.cpp: R6Engine package — core R6 game engine classes.
	Reconstructed for Ravenshield decompilation project.

	50 classes, 1126 exports. Pawns, AI controllers, interactive objects,
	deployment zones, doors, ragdolls, climbing, stairs, team management.

	Split into per-class files:
	  R6AIController.cpp, R6Charts.cpp, R6DeploymentZone.cpp, R6Door.cpp,
	  R6HeartBeat.cpp, R6Hostage.cpp, R6InteractiveObject.cpp, R6Ladder.cpp,
	  R6Matinee.cpp, R6Pawn.cpp, R6PlayerController.cpp, R6RagDoll.cpp,
	  R6Rainbow.cpp, R6RainbowAI.cpp, R6Replication.cpp, R6Stairs.cpp,
	  R6Terrorist.cpp, R6TerroristAI.cpp, R6TerroristMgr.cpp
=============================================================================*/

#include "R6EnginePrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(R6Engine)

/*-----------------------------------------------------------------------------
	FName event/callback tokens.
-----------------------------------------------------------------------------*/

#define NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) R6ENGINE_API FName R6ENGINE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6EngineClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
