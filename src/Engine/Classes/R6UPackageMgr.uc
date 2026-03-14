//=============================================================================
//  R6UPackageMgr.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================
class R6UPackageMgr extends Object;

// --- Variables ---
var array<array> m_aPackageList;
var bool bShowLog;

// --- Functions ---
function class<Object> GetFirstClassFromPackage(class<Object> ClassType, int iPackageIndex) {}
// ^ NEW IN 1.60
function string GetPackageName(int iPackageIndex) {}
// ^ NEW IN 1.60
function string GetLocalizedString(string SectionName, bool bMultipleToken, string KeyName, int iPackageIndex) {}
// ^ NEW IN 1.60
function InitOperativeClassesMgr() {}
function int GetNbPackage() {}
// ^ NEW IN 1.60
function class<Object> GetNextClassFromPackage() {}
// ^ NEW IN 1.60

defaultproperties
{
}
