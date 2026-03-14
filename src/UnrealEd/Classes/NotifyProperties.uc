// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\UnrealEd.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class NotifyProperties extends Object
    native;

// --- Structs ---
struct NotifyInfo
{
    var float NotifyFrame;
    var AnimNotify Notify;
    var int OldRevisionNum;
};

// --- Variables ---
// var ? OldRevisionNum; // REMOVED IN 1.60
var int OldArrayCount;
var const int WBrowserAnimationPtr;
var array<array> Notifys;
// ^ NEW IN 1.60

defaultproperties
{
}
