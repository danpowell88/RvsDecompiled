//=============================================================================
// Commandlet - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
/// UnrealScript Commandlet (command-line applet) class.
///
/// Commandlets are executed from the ucc.exe command line utility, using the
/// following syntax:
///
///     UCC.exe package_name.commandlet_class_name [parm=value]...
///
/// for example:
///
///     UCC.exe Core.HelloWorldCommandlet
///     UCC.exe Editor.MakeCommandlet
///
/// In addition, if you list your commandlet in the public section of your
/// package's .int file (see Engine.int for example), then your commandlet
/// can be executed without requiring a fully qualified name, for example:
///
///     UCC.exe MakeCommandlet
///
/// As a convenience, if a user tries to run a commandlet and the exact
/// name he types isn't found, then ucc.exe appends the text "commandlet"
/// onto the name and tries again.  Therefore, the following shortcuts
/// perform identically to the above:
///
///     UCC.exe Core.HelloWorld
///     UCC.exe Editor.Make
///     UCC.exe Make
///
/// It is also perfectly valid to call the Main method of a
/// commandlet class directly, for example from within the body
/// of another commandlet.
///
/// Commandlets are executed in a "raw" UnrealScript environment, in which
/// the game isn't loaded, the client code isn't loaded, no levels are
/// loaded, and no actors exist.
//=============================================================================
class Commandlet extends Object
    abstract
    transient
    native
    noexport;

/// Command name to show for "ucc help".
var localized string HelpCmd;
/// Command description to show for "ucc help".
var localized string HelpOneLiner;
/// Usage template to show for "ucc help".
var localized string HelpUsage;
/// Hyperlink for more info.
var localized string HelpWebLink;
/// Parameters and descriptions for "ucc help <this command>".
var localized string HelpParm[16];
var localized string HelpDesc[16];
/// Whether to redirect log output to console stdout.
var bool LogToStdout;
/// Whether to load objects required in server, client, and editor context.
var bool IsServer;
// NEW IN 1.60
var bool IsClient;
// NEW IN 1.60
var bool IsEditor;
/// Whether to load objects immediately, or only on demand.
var bool LazyLoad;
/// Whether to show standard error and warning count on exit.
var bool ShowErrorCount;
/// Whether to show Unreal banner on startup.
var bool ShowBanner;

// Export UCommandlet::execMain(FFrame&, void* const)
/// Entry point.
    native event int Main(string Parms);

defaultproperties
{
	LogToStdout=true
	IsServer=true
	IsClient=true
	IsEditor=true
	LazyLoad=true
	ShowBanner=true
}

// --- Symbols present in SDK 1.56 but NOT found in 1.60 decompile ----------
// REMOVED IN 1.60: var t
// REMOVED IN 1.60: var r
