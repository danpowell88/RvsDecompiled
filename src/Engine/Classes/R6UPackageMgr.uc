//=============================================================================
// R6UPackageMgr - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
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
	iFiles = pFileManager.__NFUN_1525__("..\\Mods\\NewOperative\\", "u");
	i = 0;
	J0x42:

	// End:0xBD [Loop If]
	if(__NFUN_150__(i, iFiles))
	{
		pFileManager.__NFUN_1526__(i, szPackageFilename);
		// End:0x95
		if(bShowLog)
		{
			__NFUN_231__(__NFUN_112__("Found Operative package : ", szPackageFilename));
		}
		m_aPackageList[i] = __NFUN_128__(szPackageFilename, __NFUN_147__(__NFUN_125__(szPackageFilename), 2));
		__NFUN_165__(i);
		// [Loop Continue]
		goto J0x42;
	}
	return;
}

// NEW IN 1.60
function Class GetFirstClassFromPackage(int iPackageIndex, Class ClassType)
{
	return __NFUN_1005__(__NFUN_112__(m_aPackageList[iPackageIndex], ".u"), ClassType);
	return;
}

// NEW IN 1.60
function Class GetNextClassFromPackage()
{
	return __NFUN_1006__();
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

	szLocalizedString = Localize(SectionName, KeyName, __NFUN_112__("..\\Mods\\NewOperative\\", m_aPackageList[iPackageIndex]), bMultipleToken);
	// End:0x70
	if(__NFUN_122__(szLocalizedString, ""))
	{
		szLocalizedString = __NFUN_112__(__NFUN_112__(SectionName, " "), __NFUN_234__(SectionName, __NFUN_147__(__NFUN_125__(SectionName), 3)));
	}
	return szLocalizedString;
	return;
}

