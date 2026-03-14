// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\Engine.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6FileManager extends Object
    native;

// --- Variables ---
var array<array> m_pFileList;

// --- Functions ---
final native function int GetNbFile(string szExt, string szPath) {}
final native function GetFileName(out string szFileName, int iFileID) {}
final native function bool DeleteFile(string szPathFile) {}
final native function bool FindFile(string szPathAndFilename) {}

defaultproperties
{
}
