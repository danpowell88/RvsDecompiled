/*=============================================================================
	R6AbstractGadget.cpp
=============================================================================*/

#include "R6AbstractPrivate.h"

IMPLEMENT_CLASS(AR6AbstractGadget)

// --- AR6AbstractGadget ---

IMPL_TODO("474B retail body includes property replication for m_WeaponOwner, m_OwnerCharacter, m_AttachmentName")
INT* AR6AbstractGadget::GetOptimizedRepList(BYTE* Recent, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel)
{
	guard(AR6AbstractGadget::GetOptimizedRepList);
	Ptr = Super::GetOptimizedRepList(Recent, Retire, Ptr, Map, Channel);
	// Retail: checks m_eGadgetType==4, then replicates m_WeaponOwner, m_OwnerCharacter, m_AttachmentName
	// via StaticFindObjectChecked + property RepOffset lookups
	return Ptr;
	unguard;
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
