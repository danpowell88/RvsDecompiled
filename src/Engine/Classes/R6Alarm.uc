//=============================================================================
// R6Alarm - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
/********************************************************************
	created:	2001/11/06
	filename: 	R6Alarm.uc
	author:		Jean-Francois Dube
*********************************************************************/
class R6Alarm extends Actor
    abstract
    notplaceable;

function SetAlarm(Vector vLocation)
{
	return;
}

defaultproperties
{
	bHidden=true
}
