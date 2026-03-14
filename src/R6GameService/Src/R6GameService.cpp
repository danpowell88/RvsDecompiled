/*=============================================================================
	R6GameService.cpp: R6GameService package init.
=============================================================================*/

#include "R6GameServicePrivate.h"

IMPLEMENT_PACKAGE(R6GameService)

#define NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) R6GAMESERVICE_API FName R6GAMESERVICE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name) IMPLEMENT_FUNCTION(cls,idx,name)
#include "R6GameServiceClasses.h"
#undef AUTOGENERATE_FUNCTION
#undef AUTOGENERATE_NAME
#undef NAMES_ONLY

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/

