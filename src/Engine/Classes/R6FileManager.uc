//=============================================================================
// R6FileManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
class R6FileManager extends Object
 native;

var array<string> m_pFileList;

// Export UR6FileManager::execGetNbFile(FFrame&, void* const)
 native(1525) final function int GetNbFile(string szPath, string szExt);

// Export UR6FileManager::execGetFileName(FFrame&, void* const)
 native(1526) final function GetFileName(int iFileID, out string szFileName);

// Export UR6FileManager::execDeleteFile(FFrame&, void* const)
 native(1527) final function bool DeleteFile(string szPathFile);

// Export UR6FileManager::execFindFile(FFrame&, void* const)
 native(1528) final function bool FindFile(string szPathAndFilename);

