//=============================================================================
// R6UPackageMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//  R6UPackageMgr.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// new MPF
class R6UPackageMgr extends Object;

var bool bShowLog;
var array<string> m_aPackageList;

function InitOperativeClassesMgr()
{
	local R6FileManager pFileManager;
	local int iFiles, i;
	local string szPackageFilename;

	pFileManager = new (none) Class'Engine.R6FileManager';
	iFiles = pFileManager.GetNbFile("..\\Mods\\NewOperative\\", "u");
	i = 0;
	J0x42:

	// End:0xBD [Loop If]
	if((i < iFiles))
	{
		pFileManager.GetFileName(i, szPackageFilename);
		// End:0x95
		if(bShowLog)
		{
			Log(("Found Operative package : " $ szPackageFilename));
		}
		m_aPackageList[i] = Left(szPackageFilename, (Len(szPackageFilename) - 2));
		(i++);
		// [Loop Continue]
		goto J0x42;
	}
	return;
}

// NEW IN 1.60
function Class GetFirstClassFromPackage(int iPackageIndex, Class ClassType)
{
	return GetFirstPackageClass((m_aPackageList[iPackageIndex] $ ".u"), ClassType);
	return;
}

// NEW IN 1.60
function Class GetNextClassFromPackage()
{
	return GetNextClass();
	return;
}

function int GetNbPackage()
{
	return m_aPackageList.Length;
	return;
}

function string GetPackageName(int iPackageIndex)
{
	return m_aPackageList[iPackageIndex];
	return;
}

function string GetLocalizedString(int iPackageIndex, string SectionName, string KeyName, bool bMultipleToken)
{
	local string szLocalizedString;

	szLocalizedString = Localize(SectionName, KeyName, ("..\\Mods\\NewOperative\\" $ m_aPackageList[iPackageIndex]), bMultipleToken);
	// End:0x70
	if((szLocalizedString == ""))
	{
		szLocalizedString = ((SectionName $ " ") $ Right(SectionName, (Len(SectionName) - 3)));
	}
	return szLocalizedString;
	return;
}

