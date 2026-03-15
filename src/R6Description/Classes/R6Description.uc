//=============================================================================
// R6Description - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6Description.uc : This classes will provide displayable information about
//                      selectable menu equipment
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6Description extends Object;

var Texture m_2DMenuTexture;  // The 2d image for the menus
var Region m_2dMenuRegion;  // Region in the texture
var string m_NameID;  // Name of the object to be displayed in the menus
var string m_NameTag;  // This is used to select the correct class to spawn in the class name Array
var string m_ClassName;  // Class of item to spawn

