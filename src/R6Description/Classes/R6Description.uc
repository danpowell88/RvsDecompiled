//=============================================================================
//  R6Description.uc : This classes will provide displayable information about
//                      selectable menu equipment
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================
class R6Description extends Object;

// --- Variables ---
//This is used to select the correct class to spawn in the class name Array
var string m_NameTag;
//Name of the object to be displayed in the menus
var string m_NameID;
//The 2d image for the menus
var Texture m_2DMenuTexture;
//Region in the texture
var Region m_2dMenuRegion;
//Class of item to spawn
var string m_ClassName;

defaultproperties
{
}
