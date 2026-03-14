// Extracted from retail RavenShield 1.60 -- C:\Ravenshield\gamefiles\system\R6Menu.u
// Class structure decompiled; function bodies not available (ScriptText stripped in retail build)
class R6MenuOptionsPatchService extends R6MenuOptionsTab;

// --- Variables ---
var R6WindowButton m_pStartDownloadButton;
var R6WindowWrappedTextArea m_pPatchStatus;
var R6WindowButtonBox m_pOptionAutoPatchDownload;
var float m_lastUpdateServiceClick;

// --- Functions ---
function RestoreDefaultValue() {}
function ToggleUpdateStatus(bool _bPerformPSAction) {}
function GetDownloadString(float recvdBytes, float totalBytes, out string Str) {}
function UpdateOptionsInEngine() {}
function UpdateOptionsInPage() {}
function GetDownloadMetric(out string metric, out float divider, float totalBytes) {}
function SetUpdateStatusOff(bool _bPerformPSAction) {}
function SetUpdateStatusOn(bool _bPerformPSAction) {}
function UpdatePatchStatus() {}
function Notify(UWindowDialogControl C, byte E) {}
function InitPageOptions() {}
function GetDownloadPercentageStringValues(out string percentProgress, float totalBytes, float recvdBytes, out string bytesProgress) {}
function Tick(float DeltaTime) {}

defaultproperties
{
}
