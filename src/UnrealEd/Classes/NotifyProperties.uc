//=============================================================================
// NotifyProperties - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class NotifyProperties extends Object
	native
	collapsecategories
 hidecategories(Object);

struct NotifyInfo
{
	var() float NotifyFrame;
	var() editinlinenotify AnimNotify Notify;
	var int OldRevisionNum;
};

var int OldArrayCount;
var const int WBrowserAnimationPtr;
var() array<NotifyInfo> Notifys;

