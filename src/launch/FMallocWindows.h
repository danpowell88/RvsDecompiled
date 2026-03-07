/*=============================================================================
	FMallocWindows.h: Local override for launcher module.
	The CSDK version has method bodies commented out (Malloc, Realloc, Free).
	The UT99 version has them inline which is what we need since FMallocWindows
	is instantiated locally in the exe.
	Redirect to the UT99 version which has complete inline implementations.
=============================================================================*/

#include "../../sdk/Ut99PubSrc/Core/Inc/FMallocWindows.h"
