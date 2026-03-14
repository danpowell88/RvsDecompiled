//=============================================================================
// R6TeamStartInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
/********************************************************************
	created:	2001/06/19
	filename: 	R6TeamStartInfo.uc
	author:		Joel Tremblay
	
	purpose:	Informations set by the menu 
                list all the selected equipment for characters
	
	Modification:

*********************************************************************/
class R6TeamStartInfo extends Actor
    native
    notplaceable;

var int m_iNumberOfMembers;
var int m_iSpawningPointNumber;
var R6RainbowStartInfo m_CharacterInTeam[4];
var R6AbstractPlanningInfo m_pPlanning;

