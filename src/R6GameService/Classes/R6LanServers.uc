//=============================================================================
// R6LanServers - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6LanServers.uc : This class contains all inofrmation and functions 
//  for building a list of LAN servers.
//
//  Revision history:
//    2002/04/02 * Created by John Bennett
//============================================================================//
class R6LanServers extends R6ServerList
    native
    config;

const K_REFRESH_TIMEOUT = 1000;
const K_INDREFR_MAXATT = 4;

var int m_iIndRefrAttempts;  // Number of attempts made to refresh an indiavidual server
var int m_iIndRefrEndTime;  // Time at which ind refresh is considered timed out
// NEW IN 1.60
var bool m_bIndRefrInProgress;

function RefreshServers()
{
	m_GameServerList.Remove(0, m_GameServerList.Length);
	m_GSLSortIdx.Remove(0, m_GSLSortIdx.Length);
	m_ClientBeacon.RefreshServers();
	m_bIndRefrInProgress = false;
	return;
}

function RefreshOneServer(int sortedListIdx)
{
	local int serverListIndex;

	serverListIndex = m_GSLSortIdx[sortedListIdx];
	// End:0x1C
	if(m_bIndRefrInProgress)
	{
		return;
	}
	m_iIndRefrAttempts = 0;
	m_bIndRefrInProgress = true;
	m_iIndRefrIndex = serverListIndex;
	SendBeaconToOneServer(serverListIndex);
	return;
}

function SendBeaconToOneServer(int iIndex)
{
	local IpAddr Addr;
	local string szIP;

	(m_iIndRefrAttempts++);
	m_iIndRefrEndTime = (NativeGetMilliSeconds() + 1000);
	szIP = Left(m_GameServerList[iIndex].szIPAddress, InStr(m_GameServerList[iIndex].szIPAddress, ":"));
	m_ClientBeacon.StringToIpAddr(szIP, Addr);
	Addr.Port = m_ClientBeacon.ServerBeaconPort;
	m_ClientBeacon.BroadcastBeacon(Addr);
	return;
}

//===========================================================================
// Created - Should be called when this class is spawned
//===========================================================================
function Created()
{
	super.Created();
	NativeInitFavorites();
	return;
}

//===========================================================================
// LANSeversManager - The manager will process information that is received
// from the LAN by UDPClientBeaconReceiver.  The manager should be called 
// regularly (every second or two).
//===========================================================================
function LANSeversManager()
{
	local int i, j;
	local stGameServer sSvr;
	local bool bFound;
	local int iIndex;
	local string szSvrAddr;
	local bool bListChanged;
	local int iBeaconArraySize;
	local string szCurrentMod;

	bListChanged = false;
	// End:0x15
	if((m_ClientBeacon == none))
	{
		return;
	}
	iBeaconArraySize = m_ClientBeacon.GetBeaconListSize();
	szCurrentMod = Class'Engine.Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
	i = 0;
	J0x55:

	// End:0x3E0 [Loop If]
	if((i < iBeaconArraySize))
	{
		// End:0x3D6
		if(((m_ClientBeacon.GetBeaconIntAddress(i) != 0) && m_ClientBeacon.GetNewDataFlag(i)))
		{
			szSvrAddr = m_ClientBeacon.GetBeaconAddress(i);
			bFound = false;
			j = 0;
			J0xC0:

			// End:0x136 [Loop If]
			if(((j < m_GameServerList.Length) && (!bFound)))
			{
				// End:0x12C
				if((szSvrAddr == m_GameServerList[j].szIPAddress))
				{
					bFound = true;
					iIndex = j;
					// End:0x12C
					if((m_bIndRefrInProgress && (iIndex == m_iIndRefrIndex)))
					{
						m_bIndRefrInProgress = false;
					}
				}
				(j++);
				// [Loop Continue]
				goto J0xC0;
			}
			// End:0x3D6
			if(((!m_ClientBeacon.GetInternetServer(i)) && (m_ClientBeacon.GetModName(i) ~= szCurrentMod)))
			{
				sSvr.sGameData = getSvrData(i);
				sSvr.szIPAddress = szSvrAddr;
				sSvr.bDisplay = true;
				sSvr.bFavorite = IsAFavorite(szSvrAddr);
				sSvr.iPing = NativeGetPingTime(Left(szSvrAddr, InStr(szSvrAddr, ":")));
				sSvr.iGroupID = m_ClientBeacon.GetGroupID(i);
				sSvr.iLobbySrvID = m_ClientBeacon.GetLobbyID(i);
				sSvr.iBeaconPort = m_ClientBeacon.GetBeaconPort(i);
				sSvr.sGameData.bAdversarial = m_ClientBeacon.Level.IsGameTypeAdversarial(sSvr.sGameData.szGameDataGameType);
				sSvr.sGameData.szGameType = m_ClientBeacon.Level.GetGameNameLocalization(sSvr.sGameData.szGameDataGameType);
				// End:0x337
				if(bFound)
				{
					m_GameServerList[iIndex].sGameData = sSvr.sGameData;
					m_GameServerList[iIndex].iPing = sSvr.iPing;
					m_GameServerList[iIndex].iGroupID = sSvr.iGroupID;
					m_GameServerList[iIndex].iLobbySrvID = sSvr.iLobbySrvID;
					m_GameServerList[iIndex].iBeaconPort = sSvr.iBeaconPort;					
				}
				else
				{
					iIndex = m_GameServerList.Length;
					m_GameServerList[m_GameServerList.Length] = sSvr;
					m_GSLSortIdx[m_GSLSortIdx.Length] = (m_GSLSortIdx.Length - 1);
				}
				m_GameServerList[iIndex].bSameVersion = (m_GameServerList[iIndex].sGameData.szGameVersion == Class'Engine.Actor'.static.GetGameVersion(false, (!Class'Engine.Actor'.static.GetModMgr().IsRavenShield())));
				m_ClientBeacon.SetNewDataFlag(i, false);
				m_bServerListChanged = true;
			}
		}
		(i++);
		// [Loop Continue]
		goto J0x55;
	}
	// End:0x438
	if(m_bIndRefrInProgress)
	{
		// End:0x438
		if((NativeGetMilliSeconds() > m_iIndRefrEndTime))
		{
			// End:0x410
			if((m_iIndRefrAttempts < 4))
			{
				SendBeaconToOneServer(m_iIndRefrIndex);				
			}
			else
			{
				m_GameServerList.Remove(m_iIndRefrIndex, 1);
				m_GSLSortIdx.Remove(m_iIndRefrIndex, 1);
				m_bIndRefrInProgress = false;
				m_bServerListChanged = true;
			}
		}
	}
	return;
}

