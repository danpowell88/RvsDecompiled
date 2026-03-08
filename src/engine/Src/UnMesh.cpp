/*=============================================================================
	UnMesh.cpp: UMesh, ULodMesh, USkeletalMesh, UStaticMesh registration.
	Reconstructed for Ravenshield decompilation project.

	Provides IMPLEMENT_CLASS() registrations for the mesh hierarchy.
	These are the geometry container classes used for characters
	(USkeletalMesh), props (UStaticMesh), and legacy vertex-animated
	models (UMesh / ULodMesh). Currently just registrations —
	decompiled method bodies will be added here as mesh code is
	reverse-engineered.

	This file is permanent and will grow as mesh code is decompiled.
=============================================================================*/
#include "EnginePrivate.h"

IMPLEMENT_CLASS(UMesh);
IMPLEMENT_CLASS(ULodMesh);
IMPLEMENT_CLASS(USkeletalMesh);
IMPLEMENT_CLASS(USkeletalMeshInstance);
IMPLEMENT_CLASS(UStaticMesh);
IMPLEMENT_CLASS(UStaticMeshInstance);
