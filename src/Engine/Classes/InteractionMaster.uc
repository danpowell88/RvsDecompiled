// ====================================================================
//  Class:  Engine.InteractionMaster
//
//  The InteractionMaster controls the entire interaction system.  It's
//  job is to take input and Pre/PostRender call and route them to individual
//  Interactions and/or viewports.
//
// 	The stubs here in script are for just the GlobalInteracations as those
// 	are the only Interactions the IM routes directly too.  A new stub is
// 	created in order to limit the number of C++ -> Uscript switches.
//
// (c) 2001, Epic Games, Inc.  All Rights Reserved 
// ====================================================================
class InteractionMaster extends Interactions
    native
    transient;

// --- Variables ---
// var ? CLient; // REMOVED IN 1.60
// Holds a listing of all global Interactions
var transient array<array> GlobalInteractions;
var transient Client Client;
// ^ NEW IN 1.60
// Holds a pointer to the base menu system
var transient const Interaction BaseMenu;
// Holds the special Interaction that acts as the console
var transient const Interaction Console;
//#ifdef R6PLANNINGPHASE
//global information about the game.
var R6StartGameInfo m_StartGameInfo;
var R6GameMenuCom m_MenuCommunication;

// --- Functions ---
native function Travel(string URL) {}
event Process_Message(array<array> InteractionArray, float MsgLife, coerce string Msg) {}
event Process_PostRender(array<array> InteractionArray, Canvas Canvas) {}
event Process_Tick(array<array> InteractionArray, float DeltaTime) {}
event Process_PreRender(array<array> InteractionArray, Canvas Canvas) {}
event bool Process_KeyEvent(array<array> InteractionArray, float Delta, out EInputAction Action, out EInputKey Key) {}
// ^ NEW IN 1.60
event bool Process_KeyType(array<array> InteractionArray, out EInputKey Key) {}
// ^ NEW IN 1.60
event Interaction AddInteraction(optional Player AttachTo, string InteractionName) {}
// ^ NEW IN 1.60
event RemoveInteraction(Interaction RemoveMe) {}
event SetFocusTo(optional Player ViewportOwner, Interaction Inter) {}

defaultproperties
{
}
