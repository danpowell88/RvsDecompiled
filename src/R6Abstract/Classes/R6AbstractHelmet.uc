//=============================================================================
// R6AbstractHelmet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6RHelmet.uc : New rainbow helmet base class. Moved here to provide a 
//				   pointer for helmets in UnrealEd.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//		2002/15/03 * Created by Cyrille Lauzon
//=============================================================================
class R6AbstractHelmet extends StaticMeshActor
    abstract;

function SetHelmetStaticMesh(bool bOpen)
{
	return;
}

