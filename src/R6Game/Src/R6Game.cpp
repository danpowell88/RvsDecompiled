/*=============================================================================
	R6Game.cpp: R6Game package init.
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_PACKAGE(R6Game)

#define NAMES_ONLY
#define AUTOGENERATE_NAME(name) R6GAME_API FName R6GAME_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6GameClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
