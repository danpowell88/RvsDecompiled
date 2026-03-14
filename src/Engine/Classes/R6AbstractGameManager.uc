//=============================================================================
//  R6AbstractGameManager.uc : game manager object.
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//  Revision history:
//      * 18-08-2003 : Created by Yannick Joly
//=============================================================================

class R6AbstractGameManager extends Object
    native;

var BOOL m_bGSClientInitialized;     // The GG client SDK has been intialized
var bool m_bStartedByGSClient;  // Flag to indicate if the game was launched by the ubi.com client
var BOOL m_bReturnToGSClient;   // Minimize game and return to ubi.com client
var BOOL m_bGSClientAlreadyInit;

function InitializeGSClient();
function GSClientManager(Console LocalConsole);

defaultproperties
{
}
