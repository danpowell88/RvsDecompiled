//=============================================================================
//  R6FileManagerPlanning.uc : Actor to list file, load and save a file
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/18 * Created by Chaouky Garram
//    2002/03/07 * taken over by Joel Tremblay
//=============================================================================
class R6FileManagerPlanning extends R6FileManager
    native;

// --- Variables ---
var int m_iCurrentTeam;

// --- Functions ---
final native function bool SavePlanning(R6StartGameInfo sgi, string szFileName, string szGameType, string szEnglishGT, string szLocalizedMapName, string szMapName) {}
final native function bool LoadPlanning(string szMapName, string szLocalizedMapName, string szEnglishGT, string szGameType, string szFileName, R6StartGameInfo sgi, out optional string LoadErrorMsgMapName, out optional string LoadErrorMsgGameType) {}
final native function int GetNumberOfFiles(string MapName, string szGameType) {}

defaultproperties
{
}
