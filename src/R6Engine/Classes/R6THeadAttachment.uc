//=============================================================================
//  R6THeadAttachment.uc : Terrorist head attachment base class
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Guillaume Borgia
//=============================================================================
class R6THeadAttachment extends StaticMeshActor;

#exec OBJ LOAD FILE=..\Textures\R6THeadAttachment_TSM.utx PACKAGE=R6THeadAttachment_TSM
#exec OBJ LOAD FILE=..\StaticMeshes\R6THeadAttachment_SM.usx PACKAGE=R6THeadAttachment_SM

// --- Functions ---
function bool SetAttachmentStaticMesh(EHeadAttachmentType eAttType, ETerroristType eTerro) {}

defaultproperties
{
}
