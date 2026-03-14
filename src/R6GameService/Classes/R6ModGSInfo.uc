//=============================================================================
// R6ModGSInfo - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// No matching SDK 1.56 source found
//=============================================================================
class R6ModGSInfo extends Object
	native
 config(R6ModGSInfo);

var config byte m_ucModActivationID[16];
var config bool m_bModValidActivationID;
var config string m_szModGlobalID;

// Export UR6ModGSInfo::execNativeInitModInfo(FFrame&, void* const)
 native(1207) final function NativeInitModInfo();

function InitGSMod()
{
	local string szFileName;
	local R6ModMgr pModManager;

	__NFUN_1207__();
	pModManager = Class'Engine.Actor'.static.__NFUN_1524__();
	szFileName = __NFUN_112__(__NFUN_112__(__NFUN_112__("..\\", pModManager.GetIniFilesDir()), "\\"), pModManager.GetModKeyword());
	__NFUN_1010__(szFileName);
	return;
}
