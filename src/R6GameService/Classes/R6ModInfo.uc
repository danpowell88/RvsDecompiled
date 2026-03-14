//=============================================================================
//  R6ModInfo.uc : This class contains all information and functions 
//  for connecting to a gameservice or master server
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/08/05 * Created by Yannick Joly
//============================================================================//

class R6ModInfo extends object
	config(R6ModInfo)
    native;

var string m_szMODCDKey;            // Athena CD Key
var config BYTE	    m_ucModActivationID[16];    // AS CDKey validation server activation ID
var	config string   m_szModGlobalID;            // ubi AS globalID -- related to ActID
var config BOOL	      m_bModValidActivationID;			// CDKey validation server activation ID valid flag



// User information

function Created()
{
    InitMod();
}

function InitMod()
{
    local String szRegPath;
    local string szFilename;
    local R6ModMgr pModManager;
    local string _szEncryptedCdkey;

    
    szRegPath = "SOFTWARE\\Red Storm Entertainment\\"$class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
    GetRegistryKey(szRegPath, "CDKey", _szEncryptedCdkey);

    if (class'eviLCore'.static.IsCDKeyValidOnMachine(_szEncryptedCdkey) )
    {
        m_szMODCDKey = class'eviLCore'.static.DecryptCDKey(_szEncryptedCdkey);
    }
    else
    {
        m_szMODCDKey = "";
        m_bModValidActivationID = false;// CDKey validation server activation ID valid flag
    }


    class'Actor'.static.GetModMgr().RegisterObject(self);
//    log("InitMod(): szRegPath = "$szRegPath$" m_szMODCDKey = "$m_szMODCDKey);
    
    pModManager = class'Actor'.static.GetModMgr();
    szFilename = "..\\" $ pModManager.GetIniFilesDir() $ "\\" $ pModManager.GetModKeyword();
    LoadConfig(szFilename);
//        if (bCDKeyLog) log("Created m_bASValidActivationID:"@m_bModValidActivationID);
}

defaultproperties
{
}
