//=============================================================================
// R6FileManagerPlanning - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6FileManagerPlanning.uc : Actor to list file, load and save a file
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/18 * Created by Chaouky Garram
//    2002/03/07 * taken over by Joel Tremblay
//=============================================================================
class R6FileManagerPlanning extends R6FileManager
    native;

var int m_iCurrentTeam;

// Export UR6FileManagerPlanning::execLoadPlanning(FFrame&, void* const)
native(1416) final function bool LoadPlanning(string szMapName, string szLocalizedMapName, string szEnglishGT, string szGameType, string szFileName, R6StartGameInfo sgi, optional out string LoadErrorMsgMapName, optional out string LoadErrorMsgGameType);

// Export UR6FileManagerPlanning::execSavePlanning(FFrame&, void* const)
native(1417) final function bool SavePlanning(string szMapName, string szLocalizedMapName, string szEnglishGT, string szGameType, string szFileName, R6StartGameInfo sgi);

// Export UR6FileManagerPlanning::execGetNumberOfFiles(FFrame&, void* const)
native(1418) final function int GetNumberOfFiles(string MapName, string szGameType);

