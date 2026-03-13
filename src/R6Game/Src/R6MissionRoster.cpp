/*=============================================================================
	R6MissionRoster.cpp
=============================================================================*/

#include "R6GamePrivate.h"

IMPLEMENT_CLASS(UR6MissionRoster)

// --- UR6MissionRoster ---

void UR6MissionRoster::TransferFile(FArchive& Ar)
{
	// Serialize the operative count.  FUN_1000a250(Ar, &m_MissionOperatives) at 0x1000a250
	// does the count BOS + array resize; we replicate that inline here.
	FArray* pArr = (FArray*)&m_MissionOperatives;
	INT Count    = pArr->Num();
	Ar.ByteOrderSerialize(&Count, sizeof(Count));

	UBOOL bLoading = (*(INT*)((BYTE*)&Ar + 0x14) != 0);  // ArIsLoading at Ar+0x14
	UBOOL bSaving  = (*(INT*)((BYTE*)&Ar + 0x18) != 0);  // ArIsSaving  at Ar+0x18

	if (bLoading)
	{
		pArr->Empty(sizeof(UR6Operative*));
		if (Count > 0)
			pArr->AddZeroed(sizeof(UR6Operative*), Count);
	}

	// A shared FString is reused for the class-name each iteration
	FString OperativeName;

	for (INT i = 0; i < m_MissionOperatives.Num(); i++)
	{
		if (bSaving)
		{
			// Saving: serialize "Package.ClassName" + operative data
			UR6Operative* pOp = m_MissionOperatives(i);
			if (pOp && pOp->Class)
			{
				// Build "OuterPackage.ClassName" string
				UObject* pPkg = pOp->Class->GetOuter();
				OperativeName = FString(pPkg ? pPkg->GetName() : TEXT(""))
				              + TEXT(".")
				              + FString(pOp->Class->GetName());
			}
			Ar << OperativeName;
			m_MissionOperatives(i)->TransferFile(Ar);
		}
		else
		{
			if (bLoading)
			{
				// Loading: read class name, resolve class, construct instance
				Ar << OperativeName;

				// Try to load the class by its full name
				UClass* pClass = (UClass*)UObject::StaticLoadObject(
					UR6Operative::StaticClass(), NULL, *OperativeName, NULL, 2, NULL);

				// Verify it's a valid operative class
				UBOOL bValid = pClass && pClass->IsChildOf(UR6Operative::StaticClass());
				if (!bValid)
				{
					// Fall back to the retired operative stand-in
					pClass = (UClass*)UObject::StaticLoadObject(
						UR6Operative::StaticClass(), NULL,
						TEXT("R6Game.R6RetiredOperative"), NULL, 2, NULL);
					bValid = pClass && pClass->IsChildOf(UR6Operative::StaticClass());
				}

				UR6Operative* pNewOp = NULL;
				if (bValid)
					pNewOp = (UR6Operative*)UObject::StaticConstructObject(
						pClass, UObject::GetTransientPackage(),
						NAME_None, 0, NULL, GError, NULL);

				m_MissionOperatives(i) = pNewOp;
			}

			// Call TransferFile regardless of load/transaction mode
			UR6Operative* pOp = m_MissionOperatives(i);
			if (pOp)
				pOp->TransferFile(Ar);
		}
	}
}

/*-----------------------------------------------------------------------------
	The End.
-----------------------------------------------------------------------------*/
