//=============================================================================
// R6ActionPointAbstract - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6ActionPointAbstract.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Jean-Francois Dube
//=============================================================================
class R6ActionPointAbstract extends Actor
    abstract
    native
    notplaceable;

var R6ActionPointAbstract prevActionPoint;  // previous point in the current planning
var array<Actor> m_PathToNextPoint;  // list of navigation point to reach the next Action Point

function ResetPathNode()
{
	return;
}

function ResetActionIcon()
{
	return;
}

