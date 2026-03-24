/*=============================================================================
	R6AbstractExtractionZone.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractExtractionZone)

// --- AR6AbstractExtractionZone ---

IMPL_TODO("GWarn vtable slot 0x28 (MapCheck) not declared in headers; retail also checks m_iPlanningFloor==-1")
void AR6AbstractExtractionZone::CheckForErrors()
{
	guard(AR6AbstractExtractionZone::CheckForErrors);
	ANavigationPoint::CheckForErrors();
	// Retail: if (*(INT*)((BYTE*)this + 0x70) == -1)
	//   GWarn->MapCheck(1, this, *FString::Printf(TEXT("Planning floor is -1")));
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
