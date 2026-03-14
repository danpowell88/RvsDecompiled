//=============================================================================
//  R6BulletDescription.uc : This is mainly to accelerate the foreach search 
//                           when populating menu lists
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6BulletDescription extends R6Description;

// --- Variables ---
//Class of item to spawn if the gun is silenced
var string m_SubsonicClassName;

defaultproperties
{
}
