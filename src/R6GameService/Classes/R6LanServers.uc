//=============================================================================
//  R6LanServers.uc : This class contains all inofrmation and functions 
//  for building a list of LAN servers.
//
//  Revision history:
//    2002/04/02 * Created by John Bennett
//============================================================================//
class R6LanServers extends R6ServerList
    native;

// --- Constants ---
const K_REFRESH_TIMEOUT =  1000;
const K_INDREFR_MAXATT =  4;

// --- Variables ---
var bool m_bIndRefrInProgress;
// ^ NEW IN 1.60
// Number of attempts made to refresh an indiavidual server
var int m_iIndRefrAttempts;
// Time at which ind refresh is considered timed out
var int m_iIndRefrEndTime;

// --- Functions ---
function SendBeaconToOneServer(int iIndex) {}
function RefreshOneServer(int sortedListIdx) {}
//===========================================================================
// LANSeversManager - The manager will process information that is received
// from the LAN by UDPClientBeaconReceiver.  The manager should be called
// regularly (every second or two).
//===========================================================================
function LANSeversManager() {}
function RefreshServers() {}
//===========================================================================
// Created - Should be called when this class is spawned
//===========================================================================
function Created() {}

defaultproperties
{
}
