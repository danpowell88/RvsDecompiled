//================================================================================
// UWindowSimulateAction.
//================================================================================

class UWindowSimulateAction extends UWindowWindow
	Config(R6SimulateAction);

struct SimulateAction
{
	var float ClickX;
	var float ClickY;
	var bool bCompleteAction;
};
var bool m_bMouseDown;
var bool m_bEndOfSequence;
var float m_fGetTime;
var UWindowRootWindow m_Root;
var config array<SimulateAction> m_AllSimulateAction;


function Created ()
{
}

function Tick (float Delta)
{
}

function TrySimulateAction ()
{
}

