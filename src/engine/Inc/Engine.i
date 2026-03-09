






















#pragma pack(push, 4)







































































































































class FTime
{





public:
	        FTime      ()               {v=0;}
	        FTime      (float f)        {v=(__int64)(f*4294967296.f);}
	        FTime      (double d)       {v=(__int64)(d*4294967296.f);}
	float   GetFloat   ()               {return v/4294967296.f;}
	FTime   operator+  (float f) const  {return FTime(v+(__int64)(f*4294967296.f));}
	float   operator-  (FTime t) const  {return (v-t.v)/4294967296.f;}
	FTime   operator*  (float f) const  {return FTime(v*f);}
	FTime   operator/  (float f) const  {return FTime(v/f);}
	FTime&  operator+= (float f)        {v=v+(__int64)(f*4294967296.f); return *this;}
	FTime&  operator*= (float f)        {v=(__int64)(v*f); return *this;}
	FTime&  operator/= (float f)        {v=(__int64)(v/f); return *this;}
	int     operator== (FTime t)        {return v==t.v;}
	int     operator!= (FTime t)        {return v!=t.v;}
	int     operator>  (FTime t)        {return v>t.v;}
	FTime&  operator=  (const FTime& t) {v=t.v; return *this;}
private:
	FTime (__int64 i) {v=i;}
	__int64 v;
};


	































	
	



enum {DEFAULT_ALIGNMENT = 8 }; 
enum {CACHE_LINE_SIZE   = 32}; 






















	



typedef unsigned char		BYTE;		
typedef unsigned short		_WORD;		
typedef unsigned long		DWORD;		
typedef unsigned __int64	QWORD;		


typedef	signed char			SBYTE;		
typedef signed short		SWORD;		
typedef signed int  		INT;		
typedef signed __int64		SQWORD;		


typedef char				ANSICHAR;	
typedef unsigned short      UNICHAR;	
typedef unsigned char		ANSICHARU;	
typedef unsigned short      UNICHARU;	


typedef signed int			UBOOL;		
typedef float				FLOAT;		
typedef double				DOUBLE;		
typedef unsigned long       SIZE_T;     


typedef unsigned long       BITFIELD;	


#pragma warning(disable : 4305) 
#pragma warning(disable : 4244) 
#pragma warning(disable : 4699) 
#pragma warning(disable : 4200) 
#pragma warning(disable : 4100) 
#pragma warning(disable : 4514) 
#pragma warning(disable : 4201) 
#pragma warning(disable : 4710) 
#pragma warning(disable : 4702) 
#pragma warning(disable : 4711) 
#pragma warning(disable : 4725) 
#pragma warning(disable : 4127) 
#pragma warning(disable : 4512) 
#pragma warning(disable : 4530) 
#pragma warning(disable : 4245) 
#pragma warning(disable : 4238) 
#pragma warning(disable : 4251) 
#pragma warning(disable : 4275) 
#pragma warning(disable : 4511) 
#pragma warning(disable : 4284) 
#pragma warning(disable : 4355) 
#pragma warning(disable : 4097) 
#pragma warning(disable : 4291) 


















































	__declspec(dllimport) ANSICHAR* winToANSI( ANSICHAR* ACh, const UNICHAR* InUCh, INT Count );
	__declspec(dllimport) INT winGetSizeANSI( const UNICHAR* InUCh );
	__declspec(dllimport) UNICHAR* winToUNICODE( UNICHAR* Ch, const ANSICHAR* InUCh, INT Count );
	__declspec(dllimport) INT winGetSizeUNICODE( const ANSICHAR* InACh );
	
	
	
	











extern "C"
{
	extern void*      hInstance;
	extern __declspec(dllimport) UBOOL GIsMMX;
	extern __declspec(dllimport) UBOOL GIsPentiumPro;
	extern __declspec(dllimport) UBOOL GIsKatmai;
	extern __declspec(dllimport) UBOOL GIsK6;
	extern __declspec(dllimport) UBOOL GIs3DNow;
	extern __declspec(dllimport) UBOOL GTimestamp;
}











inline INT appRound( FLOAT F )
{
	INT I;
	__asm fld [F]
	__asm fistp [I]
	return I;
}







inline INT appFloor( FLOAT F )
{
	static FLOAT Half=0.5;
	INT I;
	__asm fld [F]
	__asm fsub [Half]
	__asm fistp [I]
	return I;
}







#pragma warning (push)
#pragma warning (disable : 4035)
#pragma warning (disable : 4715)
inline DWORD appCycles()
{
	if( GTimestamp ) __asm
	{
		xor   eax,eax	          
		_emit 0x0F		          
		_emit 0x31		          
		xor   edx,edx	          
	}
}
#pragma warning (pop)







#pragma warning (push)
#pragma warning (disable : 4035)

__declspec(dllimport) extern DOUBLE GSecondsPerCycle;
__declspec(dllimport) DOUBLE appSecondsSlow();
inline FTime appSeconds()
{
	if( GTimestamp )
	{
		DWORD L,H;
		__asm
		{
			xor   eax,eax	
			xor   edx,edx	
			_emit 0x0F		
			_emit 0x31		
			mov   [L],eax   
			mov   [H],edx   
		}
		return ((double)L +  4294967296.0 * (double)H) * GSecondsPerCycle;
	}
	else return appSecondsSlow();
}
#pragma warning (pop)







inline void appMemcpy( void* Dest, const void* Src, INT Count )
{	
	__asm
	{
		mov		ecx, Count
		mov		esi, Src
		mov		edi, Dest
		mov     ebx, ecx
		shr     ecx, 2
		and     ebx, 3
		rep     movsd
		mov     ecx, ebx
		rep     movsb
	}
}







inline void appMemzero( void* Dest, INT Count )
{	
	__asm
	{
		mov		ecx, [Count]
		mov		edi, [Dest]
		xor     eax, eax
		mov		ebx, ecx
		shr		ecx, 2
		and		ebx, 3
		rep     stosd
		mov     ecx, ebx
		rep     stosb
	}
}



inline void DoFemms()
{
	__asm _emit 0x0f
	__asm _emit 0x0e
}




inline void appDebugBreak()
{
	__asm
	{
		int 3
	}
}


extern "C" void* __cdecl _alloca(size_t);






















enum {MAXBYTE		= 0xff       };
enum {MAXWORD		= 0xffffU    };
enum {MAXDWORD		= 0xffffffffU};
enum {MAXSBYTE		= 0x7f       };
enum {MAXSWORD		= 0x7fff     };
enum {MAXINT		= 0x7fffffff };
enum {INDEX_NONE	= -1         };
enum {UNICODE_BOM   = 0xfeff     };
enum ENoInit {E_NoInit = 0};


	
		typedef UNICHAR  TCHAR;
		typedef UNICHARU TCHARU;
	
	
	
	
	
	inline TCHAR    FromAnsi   ( ANSICHAR In ) { return (BYTE)In;                                            }
	inline TCHAR    FromUnicode( UNICHAR In  ) { return In;                                                  }
	inline ANSICHAR ToAnsi     ( TCHAR In    ) { return (_WORD)In<0x100 ? (ANSICHAR)In : (ANSICHAR)MAXSBYTE; }
	inline UNICHAR  ToUnicode  ( TCHAR In    ) { return In;                                                  }



















class	UObject;
class		UExporter;
class		UFactory;
class		UField;
class			UConst;
class			UEnum;
class			UProperty;
class				UByteProperty;
class				UIntProperty;
class				UBoolProperty;
class				UFloatProperty;
class				UObjectProperty;
class					UClassProperty;
class				UNameProperty;
class				UStructProperty;
class               UStrProperty;
class               UArrayProperty;
class			UStruct;
class				UFunction;
class				UState;
class					UClass;
class		ULinker;
class			ULinkerLoad;
class			ULinkerSave;
class		UPackage;
class		USubsystem;
class			USystem;
class		UTextBuffer;
class       URenderDevice;
class		UPackageMap;

class FName;
class FArchive;
class FCompactIndex;
class FExec;
class FGuid;
class FMemCache;
class FMemStack;
class FPackageInfo;
class FTransactionBase;
class FUnknown;
class FRepLink;
class FArray;
class FLazyLoader;
class FString;
class FMalloc;

template<class T> class TArray;
template<class T> class TTransArray;
template<class T> class TLazyArray;
template<class TK, class TI> class TMap;
template<class TK, class TI> class TMultiMap;

__declspec(dllimport) extern class FOutputDevice* GNull;
















	
	
	
	enum EName {







NAME_None = 0,


NAME_ByteProperty = 1,
NAME_IntProperty = 2,
NAME_BoolProperty = 3,
NAME_FloatProperty = 4,
NAME_ObjectProperty = 5,
NAME_NameProperty = 6,
NAME_StringProperty = 7,
NAME_ClassProperty = 8,
NAME_ArrayProperty = 9,
NAME_StructProperty = 10,
NAME_VectorProperty = 11,
NAME_RotatorProperty = 12,
NAME_StrProperty = 13,
NAME_MapProperty = 14,
NAME_FixedArrayProperty = 15,


NAME_Core = 20,
NAME_Engine = 21,
NAME_Editor = 22,
NAME_UnrealI = 23,
NAME_UnrealShare = 24,


NAME_Byte = 80,
NAME_Int = 81,
NAME_Bool = 82,
NAME_Float = 83,
NAME_Name = 84,
NAME_String = 85,
NAME_Struct = 86,
NAME_Vector = 87,
NAME_Rotator = 88,
NAME_Color = 90,
NAME_Plane = 91,


NAME_Begin = 100,
NAME_State = 102,
NAME_Function = 103,
NAME_Self = 104,
NAME_True = 105,
NAME_False = 106,
NAME_Transient = 107,
NAME_Enum = 117,
NAME_Replication = 119,
NAME_Reliable = 120,
NAME_Unreliable = 121,
NAME_Always = 122,


NAME_Field = 150,
NAME_Object = 151,
NAME_TextBuffer = 152,
NAME_Linker = 153,
NAME_LinkerLoad = 154,
NAME_LinkerSave = 155,
NAME_Subsystem = 156,
NAME_Factory = 157,
NAME_TextBufferFactory = 158,
NAME_Exporter = 159,
NAME_StackNode = 160,
NAME_Property = 161,
NAME_Camera = 162,


NAME_Vect = 600,
NAME_Rot = 601,
NAME_ArrayCount = 605,
NAME_EnumCount = 606,


NAME_Else = 620,
NAME_If = 621,
NAME_Goto = 622,
NAME_Stop = 623,
NAME_Until = 625,
NAME_While = 626,
NAME_Do = 627,
NAME_Break = 628,
NAME_For = 629,
NAME_ForEach = 630,
NAME_Assert = 631,
NAME_Switch = 632,
NAME_Case = 633,
NAME_Default = 634,
NAME_Continue = 635,


NAME_Private = 640,
NAME_Const = 641,
NAME_Out = 642,
NAME_Export = 643,
NAME_Skip = 646,
NAME_Coerce = 647,
NAME_Optional = 648,
NAME_Input = 649,
NAME_Config = 650,
NAME_Travel = 652,
NAME_EditConst = 653,
NAME_Localized = 654,
NAME_GlobalConfig = 655,
NAME_SafeReplace = 656,
NAME_New = 657,


NAME_Expands = 660,
NAME_Intrinsic = 661,
NAME_Within = 662,
NAME_Abstract = 663,
NAME_Package = 664,
NAME_Guid = 665,
NAME_Parent = 666,
NAME_Class = 667,
NAME_Extends = 668,
NAME_NoExport = 669,
NAME_NoUserCreate = 670,
NAME_PerObjectConfig = 671,
NAME_NativeReplication = 672,


NAME_Auto = 675,
NAME_Ignores = 676,


NAME_Global = 680,
NAME_Super = 681,
NAME_Outer = 682,


NAME_Operator = 690,
NAME_PreOperator = 691,
NAME_PostOperator = 692,
NAME_Final = 693,
NAME_Iterator = 694,
NAME_Latent = 695,
NAME_Return = 696,
NAME_Singular = 697,
NAME_Simulated = 698,
NAME_Exec = 699,
NAME_Event = 700,
NAME_Static = 701,
NAME_Native = 702,
NAME_Invariant = 703,


NAME_Var = 710,
NAME_Local = 711,
NAME_Import = 712,
NAME_From = 713,


NAME_Spawn = 720,
NAME_Array = 721,
NAME_Map = 722,


NAME_Tag = 740,
NAME_Role = 742,
NAME_RemoteRole = 743,
NAME_System = 744,
NAME_User = 745,


NAME_Log = 760,
NAME_Critical = 761,
NAME_Init = 762,
NAME_Exit = 763,
NAME_Cmd = 764,
NAME_Play = 765,
NAME_Console = 766,
NAME_Warning = 767,
NAME_ExecWarning = 768,
NAME_ScriptWarning = 769,
NAME_ScriptLog = 770,
NAME_Dev = 771,
NAME_DevNet = 772,
NAME_DevPath = 773,
NAME_DevNetTraffic = 774,
NAME_DevAudio = 775,
NAME_DevLoad = 776,
NAME_DevSave = 777,
NAME_DevGarbage = 778,
NAME_DevKill = 779,
NAME_DevReplace = 780,
NAME_DevMusic = 781,
NAME_DevSound = 782,
NAME_DevCompile = 783,
NAME_DevBind = 784,
NAME_Localization = 785,
NAME_Compatibility = 786,
NAME_NetComeGo = 787,
NAME_Title = 788,
NAME_Error = 789,
NAME_Heading = 790,
NAME_SubHeading = 791,
NAME_FriendlyError = 792,
NAME_Progress = 793,
NAME_UserPrompt = 794,


NAME_White = 800,
NAME_Black = 801,
NAME_Red = 802,
NAME_Green = 803,
NAME_Blue = 804,
NAME_Cyan = 805,
NAME_Magenta = 806,
NAME_Yellow = 807,
NAME_DefaultColor = 808,


NAME_KeyType = 820,
NAME_KeyEvent = 821,
NAME_Write = 822,
NAME_Message = 823,
NAME_InitialState = 824,
NAME_Texture = 825,
NAME_Sound = 826,
NAME_FireTexture = 827,
NAME_IceTexture = 828,
NAME_WaterTexture = 829,
NAME_WaveTexture = 830,
NAME_WetTexture = 831,
NAME_Main = 832,
NAME_NotifyLevelChange = 833,
NAME_VideoChange = 834,
NAME_SendText = 835,
NAME_SendBinary = 836,
NAME_ConnectFailure = 837,













NAME_Spawned = 300, 
NAME_Destroyed = 301, 


NAME_GainedChild = 302, 
NAME_LostChild = 303, 
NAME_Probe4 = 304,
NAME_Probe5 = 305,


NAME_Trigger = 306, 
NAME_UnTrigger = 307, 


NAME_Timer = 308, 
NAME_HitWall = 309, 
NAME_Falling = 310, 
NAME_Landed = 311, 
NAME_ZoneChange = 312, 
NAME_Touch = 313, 
NAME_UnTouch = 314, 
NAME_Bump = 315, 
NAME_BeginState = 316, 
NAME_EndState = 317, 
NAME_BaseChange = 318, 
NAME_Attach = 319, 
NAME_Detach = 320, 
NAME_ActorEntered = 321, 
NAME_ActorLeaving = 322, 
NAME_KillCredit = 323, 
NAME_AnimEnd = 324, 
NAME_EndedRotation = 325, 
NAME_InterpolateEnd = 326, 
NAME_EncroachingOn = 327, 
NAME_EncroachedBy = 328, 
NAME_FootZoneChange = 329, 
NAME_HeadZoneChange = 330, 
NAME_PainTimer = 331, 
NAME_SpeechTimer = 332, 
NAME_MayFall = 333,
NAME_Probe34 = 334,


NAME_Die = 335, 


NAME_Tick = 336, 
NAME_PlayerTick = 337, 
NAME_Expired = 338, 
NAME_Probe39 = 339,


NAME_SeePlayer = 340, 
NAME_EnemyNotVisible = 341, 
NAME_HearNoise = 342, 
NAME_UpdateEyeHeight = 343, 
NAME_SeeMonster = 344, 
NAME_SeeFriend = 345, 
NAME_SpecialHandling = 346, 
NAME_BotDesireability = 347, 
NAME_Probe48 = 348,
NAME_Probe49 = 349,
NAME_Probe50 = 350,
NAME_Probe51 = 351,
NAME_Probe52 = 352,
NAME_Probe53 = 353,
NAME_Probe54 = 354,
NAME_Probe55 = 355,
NAME_Probe56 = 356,
NAME_Probe57 = 357,
NAME_Probe58 = 358,
NAME_Probe59 = 359,
NAME_Probe60 = 360,
NAME_Probe61 = 361,
NAME_Probe62 = 362,


NAME_All = 363, 






	};
	
	
	











class __declspec(dllimport) FOutputDevice
{
public:
	virtual void Serialize( const TCHAR* V, EName Event )=0;
	void Log( const TCHAR* S );
	void Log( enum EName Type, const TCHAR* S );
	void Log( const FString& S );
	void Log( enum EName Type, const FString& S );
	void Logf( const TCHAR* Fmt, ... );
	void Logf( enum EName Type, const TCHAR* Fmt, ... );
};

class __declspec(dllimport) FOutputDeviceError : public FOutputDevice
{
public:
	virtual void HandleError()=0;
};

class __declspec(dllimport) FMalloc
{
public:
	virtual void* Malloc( DWORD Count, const TCHAR* Tag )=0;
	virtual void* Realloc( void* Original, DWORD Count, const TCHAR* Tag )=0;
	virtual void Free( void* Original )=0;
	virtual void DumpAllocs()=0;
	virtual void HeapCheck()=0;
	virtual void Init()=0;
	virtual void Exit()=0;
};

class FConfigCache
{
public:
	virtual UBOOL GetBool( const TCHAR* Section, const TCHAR* Key, UBOOL& Value, const TCHAR* Filename=0 )=0;
	virtual UBOOL GetInt( const TCHAR* Section, const TCHAR* Key, INT& Value, const TCHAR* Filename=0 )=0;
	virtual UBOOL GetFloat( const TCHAR* Section, const TCHAR* Key, FLOAT& Value, const TCHAR* Filename=0 )=0;
	virtual UBOOL GetString( const TCHAR* Section, const TCHAR* Key, TCHAR* Value, INT Size, const TCHAR* Filename=0 )=0;
	virtual UBOOL GetString( const TCHAR* Section, const TCHAR* Key, class FString& Str, const TCHAR* Filename=0 )=0;
	virtual const TCHAR* GetStr( const TCHAR* Section, const TCHAR* Key, const TCHAR* Filename=0 )=0;
	virtual UBOOL GetSection( const TCHAR* Section, TCHAR* Value, INT Size, const TCHAR* Filename=0 )=0;
	virtual TMultiMap<FString,FString>* GetSectionPrivate( const TCHAR* Section, UBOOL Force, UBOOL Const, const TCHAR* Filename=0 )=0;
	virtual void EmptySection( const TCHAR* Section, const TCHAR* Filename=0 )=0;
	virtual void SetBool( const TCHAR* Section, const TCHAR* Key, UBOOL Value, const TCHAR* Filename=0 )=0;
	virtual void SetInt( const TCHAR* Section, const TCHAR* Key, INT Value, const TCHAR* Filename=0 )=0;
	virtual void SetFloat( const TCHAR* Section, const TCHAR* Key, FLOAT Value, const TCHAR* Filename=0 )=0;
	virtual void SetString( const TCHAR* Section, const TCHAR* Key, const TCHAR* Value, const TCHAR* Filename=0 )=0;
	virtual void Flush( UBOOL Read, const TCHAR* Filename=0 )=0;
	virtual void Detach( const TCHAR* Filename )=0;
	virtual void Init( const TCHAR* InSystem, const TCHAR* InUser, UBOOL RequireConfig )=0;
	virtual void Exit()=0;
	virtual void Dump( FOutputDevice& Ar )=0;
	virtual ~FConfigCache() {};
};

class __declspec(dllimport) FExec
{
public:
	virtual UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar )=0;
};

class __declspec(dllimport) FNotifyHook
{
public:
	virtual void NotifyDestroy( void* Src ) {}
	virtual void NotifyPreChange( void* Src ) {}
	virtual void NotifyPostChange( void* Src ) {}
	virtual void NotifyExec( void* Src, const TCHAR* Cmd ) {}
};

class FContextSupplier
{
public:
	virtual FString GetContext()=0;
};

class __declspec(dllimport) FFeedbackContext : public FOutputDevice
{
public:
	virtual UBOOL YesNof( const TCHAR* Fmt, ... )=0;
	virtual void BeginSlowTask( const TCHAR* Task, UBOOL StatusWindow, UBOOL Cancelable )=0;
	virtual void EndSlowTask()=0;
	virtual UBOOL __cdecl StatusUpdatef( INT Numerator, INT Denominator, const TCHAR* Fmt, ... )=0;
	virtual void SetContext( FContextSupplier* InSupplier )=0;
};

typedef void( *STRUCT_AR )( FArchive& Ar, void* TPtr );
typedef void( *STRUCT_DTOR )( void* TPtr );
class __declspec(dllimport) FTransactionBase
{
public:
	virtual void SaveObject( UObject* Object )=0;
	virtual void SaveArray( UObject* Object, FArray* Array, INT Index, INT Count, INT Oper, INT ElementSize, STRUCT_AR Serializer, STRUCT_DTOR Destructor )=0;
	virtual void Apply()=0;
};

enum EFileTimes  { FILETIME_Create=0, FILETIME_LastAccess=1, FILETIME_LastWrite=2 };
enum EFileWrite  { FILEWRITE_NoFail=0x01, FILEWRITE_NoReplaceExisting=0x02, FILEWRITE_EvenIfReadOnly=0x04, FILEWRITE_Unbuffered=0x08, FILEWRITE_Append=0x10, FILEWRITE_AllowRead=0x20 };
enum EFileRead   { FILEREAD_NoFail=0x01 };
class __declspec(dllimport) FFileManager
{
public:
	virtual FArchive* CreateFileReader( const TCHAR* Filename, DWORD ReadFlags=0, FOutputDevice* Error=GNull )=0;
	virtual FArchive* CreateFileWriter( const TCHAR* Filename, DWORD WriteFlags=0, FOutputDevice* Error=GNull )=0;
	virtual INT FileSize( const TCHAR* Filename )=0;
	virtual UBOOL Delete( const TCHAR* Filename, UBOOL RequireExists=0, UBOOL EvenReadOnly=0 )=0;
	virtual UBOOL Copy( const TCHAR* Dest, const TCHAR* Src, UBOOL Replace=1, UBOOL EvenIfReadOnly=0, UBOOL Attributes=0, void (*Progress)(FLOAT Fraction)=0 )=0;
	virtual UBOOL Move( const TCHAR* Dest, const TCHAR* Src, UBOOL Replace=1, UBOOL EvenIfReadOnly=0, UBOOL Attributes=0 )=0;
	virtual SQWORD GetGlobalTime( const TCHAR* Filename )=0;
	virtual UBOOL SetGlobalTime( const TCHAR* Filename )=0;
	virtual UBOOL MakeDirectory( const TCHAR* Path, UBOOL Tree=0 )=0;
	virtual UBOOL DeleteDirectory( const TCHAR* Path, UBOOL RequireExists=0, UBOOL Tree=0 )=0;
	virtual TArray<FString> FindFiles( const TCHAR* Filename, UBOOL Files, UBOOL Directories )=0;
	virtual UBOOL SetDefaultDirectory( const TCHAR* Filename )=0;
	virtual FString GetDefaultDirectory()=0;
	virtual void Init(UBOOL Startup) {}
};





__declspec(dllimport) extern FMemStack				GMem;
__declspec(dllimport) extern FOutputDevice*			GLog;
__declspec(dllimport) extern FOutputDevice*			GNull;
__declspec(dllimport) extern FOutputDevice*		    GThrow;
__declspec(dllimport) extern FOutputDeviceError*		GError;
__declspec(dllimport) extern FFeedbackContext*		GWarn;
__declspec(dllimport) extern FConfigCache*			GConfig;
__declspec(dllimport) extern FTransactionBase*		GUndo;
__declspec(dllimport) extern FOutputDevice*			GLogHook;
__declspec(dllimport) extern FExec*					GExec;
__declspec(dllimport) extern FMalloc*				GMalloc;
__declspec(dllimport) extern FFileManager*			GFileManager;
__declspec(dllimport) extern USystem*				GSys;
__declspec(dllimport) extern UProperty*				GProperty;
__declspec(dllimport) extern BYTE*					GPropAddr;
__declspec(dllimport) extern USubsystem*				GWindowManager;
__declspec(dllimport) extern TCHAR				    GErrorHist[4096];
__declspec(dllimport) extern TCHAR                   GTrue[64], GFalse[64], GYes[64], GNo[64], GNone[64];
__declspec(dllimport) extern TCHAR					GCdPath[];
__declspec(dllimport) extern DOUBLE GSecondsPerCycle;
__declspec(dllimport) extern unsigned short *  GMachineCPU;
__declspec(dllimport) extern	FTime					GTempTime;
__declspec(dllimport) extern void					(*GTempFunc)(void*);
__declspec(dllimport) extern SQWORD					GTicks;
__declspec(dllimport) extern INT                     GScriptCycles;
__declspec(dllimport) extern DWORD					GPageSize;
__declspec(dllimport) extern DWORD					GProcessorCount;
__declspec(dllimport) extern unsigned long GPhysicalMemory;
__declspec(dllimport) extern DWORD                   GUglyHackFlags;
__declspec(dllimport) extern UBOOL					GIsScriptable;
__declspec(dllimport) extern UBOOL					GIsEditor;
__declspec(dllimport) extern UBOOL					GIsClient;
__declspec(dllimport) extern UBOOL					GIsServer;
__declspec(dllimport) extern UBOOL					GIsCriticalError;
__declspec(dllimport) extern UBOOL					GIsStarted;
__declspec(dllimport) extern UBOOL					GIsRunning;
__declspec(dllimport) extern UBOOL					GIsSlowTask;
__declspec(dllimport) extern UBOOL					GIsGuarded;
__declspec(dllimport) extern UBOOL					GIsRequestingExit;
__declspec(dllimport) extern UBOOL					GIsStrict;
__declspec(dllimport) extern UBOOL                   GScriptEntryTag;
__declspec(dllimport) extern UBOOL                   GLazyLoad;
__declspec(dllimport) extern UBOOL					GUnicode;
__declspec(dllimport) extern UBOOL					GUnicodeOS;
__declspec(dllimport) extern class FGlobalMath		GMath;
__declspec(dllimport) extern	URenderDevice*			GRenderDevice;
__declspec(dllimport) extern class FArchive*         GDummySave;
__declspec(dllimport) extern DWORD					GCurrentViewport;

__declspec(dllimport) extern unsigned short *  GMachineOS;
__declspec(dllimport) extern unsigned short *  GMachineVideo;

extern "C" __declspec(dllexport) TCHAR GPackage[];













__declspec(dllimport) extern DWORD GCRCTable[];







	
		
		
		
	











	








__declspec(dllimport) void appInit( const TCHAR* InPackage, const TCHAR* InCmdLine, FMalloc* InMalloc, FOutputDevice* InLog, FOutputDeviceError* InError, FFeedbackContext* InWarn, FFileManager* InFileManager, FConfigCache*(*ConfigFactory)(), UBOOL RequireConfig );
__declspec(dllimport) void appPreExit();
__declspec(dllimport) void appExit();





__declspec(dllimport) void appRequestExit( UBOOL Force );

__declspec(dllimport) void __cdecl appFailAssert( const ANSICHAR* Expr, const ANSICHAR* File, INT Line );
__declspec(dllimport) void __cdecl appUnwindf( const TCHAR* Fmt, ... );
__declspec(dllimport) const TCHAR* appGetSystemErrorMessage( INT Error=0 );
__declspec(dllimport) const void appDebugMessagef( const TCHAR* Fmt, ... );

__declspec(dllimport) const void appMsgf( const TCHAR* Fmt, ... );
__declspec(dllimport) const void appGetLastError( void );









	
	






__declspec(dllimport) void* appGetDllHandle( const TCHAR* DllName );
__declspec(dllimport) void appFreeDllHandle( void* DllHandle );
__declspec(dllimport) void* appGetDllExport( void* DllHandle, const TCHAR* ExportName );
__declspec(dllimport) void appLaunchURL( const TCHAR* URL, const TCHAR* Parms=0, FString* Error=0 );
__declspec(dllimport) void* appCreateProc( const TCHAR* URL, const TCHAR* Parms , UBOOL bRealTime );
__declspec(dllimport) UBOOL appGetProcReturnCode( void* ProcHandle, INT* ReturnCode );
__declspec(dllimport) void appEnableFastMath( UBOOL Enable );
__declspec(dllimport) class FGuid appCreateGuid();
__declspec(dllimport) void appCreateTempFilename( const TCHAR* Path, TCHAR* Result256 );
__declspec(dllimport) void appCleanFileCache();
__declspec(dllimport) UBOOL appFindPackageFile( const TCHAR* In, const FGuid* Guid, TCHAR* Out );





__declspec(dllimport) void appClipboardCopy( const TCHAR* Str );
__declspec(dllimport) FString appClipboardPaste();















	
		
		
		
	

















	
	
	
	









__declspec(dllimport) void __cdecl appThrowf( const TCHAR* Fmt, ... );










	
	












	
	



















	
	






__declspec(dllimport) FString appFormat( FString Src, const TMultiMap<FString,FString>& Map );





__declspec(dllimport) const TCHAR* Localize( const TCHAR* Section, const TCHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0, UBOOL Optional=0 );
__declspec(dllimport) const TCHAR* LocalizeError( const TCHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );
__declspec(dllimport) const TCHAR* LocalizeProgress( const TCHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );
__declspec(dllimport) const TCHAR* LocalizeQuery( const TCHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );
__declspec(dllimport) const TCHAR* LocalizeGeneral( const TCHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );


	__declspec(dllimport) const TCHAR* Localize( const ANSICHAR* Section, const ANSICHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0, UBOOL Optional=0 );
	__declspec(dllimport) const TCHAR* LocalizeError( const ANSICHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );
	__declspec(dllimport) const TCHAR* LocalizeProgress( const ANSICHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );
	__declspec(dllimport) const TCHAR* LocalizeQuery( const ANSICHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );
	__declspec(dllimport) const TCHAR* LocalizeGeneral( const ANSICHAR* Key, const TCHAR* Package=GPackage, const TCHAR* LangExt=0 );







__declspec(dllimport) const TCHAR* appFExt( const TCHAR* Filename );
__declspec(dllimport) UBOOL appUpdateFileModTime( TCHAR* Filename );
__declspec(dllimport) FString appGetGMTRef();





__declspec(dllimport) const TCHAR* appCmdLine();
__declspec(dllimport) const TCHAR* appBaseDir();
__declspec(dllimport) const TCHAR* appPackage();
__declspec(dllimport) const TCHAR* appComputerName();
__declspec(dllimport) const TCHAR* appUserName();













__declspec(dllimport) void appSystemTime( INT& Year, INT& Month, INT& DayOfWeek, INT& Day, INT& Hour, INT& Min, INT& Sec, INT& MSec );
__declspec(dllimport) const TCHAR* appTimestamp();
__declspec(dllimport) double appSecondsSlow();
__declspec(dllimport) void appSleep( FLOAT Seconds );





inline TCHAR appToUpper( TCHAR c )
{
	return (c<'a' || c>'z') ? (c) : (TCHAR)(c+'A'-'a');
}
inline TCHAR appToLower( TCHAR c )
{
	return (c<'A' || c>'Z') ? (c) : (TCHAR)(c+'a'-'A');
}
inline UBOOL appIsAlpha( TCHAR c )
{
	return (c>='a' && c<='z') || (c>='A' && c<='Z');
}
inline UBOOL appIsDigit( TCHAR c )
{
	return c>='0' && c<='9';
}
inline UBOOL appIsAlnum( TCHAR c )
{
	return (c>='a' && c<='z') || (c>='A' && c<='Z') || (c>='0' && c<='9');
}





__declspec(dllimport) const ANSICHAR* appToAnsi( const TCHAR* Str );
__declspec(dllimport) const UNICHAR* appToUnicode( const TCHAR* Str );
__declspec(dllimport) const TCHAR* appFromAnsi( const ANSICHAR* Str );
__declspec(dllimport) const TCHAR* appFromUnicode( const UNICHAR* Str );
__declspec(dllimport) UBOOL appIsPureAnsi( const TCHAR* Str );

__declspec(dllimport) TCHAR* appStrcpy( TCHAR* Dest, const TCHAR* Src );
__declspec(dllimport) INT appStrcpy( const TCHAR* String );
__declspec(dllimport) INT appStrlen( const TCHAR* String );
__declspec(dllimport) TCHAR* appStrstr( const TCHAR* String, const TCHAR* Find );
__declspec(dllimport) TCHAR* appStrchr( const TCHAR* String, INT c );
__declspec(dllimport) TCHAR* appStrcat( TCHAR* Dest, const TCHAR* Src );
__declspec(dllimport) INT appStrcmp( const TCHAR* String1, const TCHAR* String2 );
__declspec(dllimport) INT appStricmp( const TCHAR* String1, const TCHAR* String2 );
__declspec(dllimport) INT appStrncmp( const TCHAR* String1, const TCHAR* String2, INT Count );
__declspec(dllimport) TCHAR* appStaticString1024();
__declspec(dllimport) ANSICHAR* appAnsiStaticString1024();

__declspec(dllimport) const TCHAR* appSpc( int Num );
__declspec(dllimport) TCHAR* appStrncpy( TCHAR* Dest, const TCHAR* Src, int Max);
__declspec(dllimport) TCHAR* appStrncat( TCHAR* Dest, const TCHAR* Src, int Max);
__declspec(dllimport) TCHAR* appStrupr( TCHAR* String );
__declspec(dllimport) const TCHAR* appStrfind(const TCHAR* Str, const TCHAR* Find);
__declspec(dllimport) DWORD appStrCrc( const TCHAR* Data );
__declspec(dllimport) DWORD appStrCrcCaps( const TCHAR* Data );
__declspec(dllimport) INT appAtoi( const TCHAR* Str );
__declspec(dllimport) FLOAT appAtof( const TCHAR* Str );
__declspec(dllimport) INT appStrtoi( const TCHAR* Start, TCHAR** End, INT Base );
__declspec(dllimport) INT appStrnicmp( const TCHAR* A, const TCHAR* B, INT Count );
__declspec(dllimport) INT appSprintf( TCHAR* Dest, const TCHAR* Fmt, ... );
__declspec(dllimport) void appTrimSpaces( ANSICHAR* String);


	__declspec(dllimport) INT appGetVarArgs( TCHAR* Dest, INT Count, const TCHAR*& Fmt );





typedef int QSORT_RETURN;
typedef QSORT_RETURN(__cdecl* QSORT_COMPARE)( const void* A, const void* B );
__declspec(dllimport) void appQsort( void* Base, INT Num, INT Width, QSORT_COMPARE Compare );




inline DWORD appStrihash( const TCHAR* Data )
{
	DWORD Hash=0;
	while( *Data )
	{
		TCHAR Ch = appToUpper(*Data++);
		BYTE  B  = (BYTE)Ch;
		Hash     = ((Hash >> 8) & 0x00FFFFFF) ^ GCRCTable[(Hash ^ B) & 0x000000FF];

		B        = (BYTE)(Ch>>8);
		Hash     = ((Hash >> 8) & 0x00FFFFFF) ^ GCRCTable[(Hash ^ B) & 0x000000FF];

	}
	return Hash;
}





__declspec(dllimport) UBOOL ParseCommand( const TCHAR** Stream, const TCHAR* Match );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, class FName& Name );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, DWORD& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, class FGuid& Guid );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, TCHAR* Value, INT MaxLen );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, BYTE& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, SBYTE& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, _WORD& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, SWORD& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, FLOAT& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, INT& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, FString& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, QWORD& Value );
__declspec(dllimport) UBOOL Parse( const TCHAR* Stream, const TCHAR* Match, SQWORD& Value );
__declspec(dllimport) UBOOL ParseUBOOL( const TCHAR* Stream, const TCHAR* Match, UBOOL& OnOff );
__declspec(dllimport) UBOOL ParseObject( const TCHAR* Stream, const TCHAR* Match, class UClass* Type, class UObject*& DestRes, class UObject* InParent );
__declspec(dllimport) UBOOL ParseLine( const TCHAR** Stream, TCHAR* Result, INT MaxLen, UBOOL Exact=0 );
__declspec(dllimport) UBOOL ParseLine( const TCHAR** Stream, FString& Resultd, UBOOL Exact=0 );
__declspec(dllimport) UBOOL ParseToken( const TCHAR*& Str, TCHAR* Result, INT MaxLen, UBOOL UseEscape );
__declspec(dllimport) UBOOL ParseToken( const TCHAR*& Str, FString& Arg, UBOOL UseEscape );
__declspec(dllimport) FString ParseToken( const TCHAR*& Str, UBOOL UseEscape );
__declspec(dllimport) void ParseNext( const TCHAR** Stream );
__declspec(dllimport) UBOOL ParseParam( const TCHAR* Stream, const TCHAR* Param );





__declspec(dllimport) DOUBLE appExp( DOUBLE Value );
__declspec(dllimport) DOUBLE appLoge( DOUBLE Value );
__declspec(dllimport) DOUBLE appFmod( DOUBLE A, DOUBLE B );
__declspec(dllimport) DOUBLE appSin( DOUBLE Value );
__declspec(dllimport) DOUBLE appCos( DOUBLE Value );
__declspec(dllimport) DOUBLE appAcos( DOUBLE Value );
__declspec(dllimport) DOUBLE appTan( DOUBLE Value );
__declspec(dllimport) DOUBLE appAtan( DOUBLE Value );
__declspec(dllimport) DOUBLE appAtan2( DOUBLE Y, DOUBLE X );

__declspec(dllimport) DOUBLE appPow( DOUBLE A, DOUBLE B );
__declspec(dllimport) UBOOL appIsNan( DOUBLE Value );
__declspec(dllimport) INT appRand();
__declspec(dllimport) FLOAT appFrand();

__declspec(dllimport) FLOAT appRandRange( FLOAT Min, FLOAT Max );
__declspec(dllimport) INT appRandRange( INT Min, INT Max );











__declspec(dllimport) INT appCeil( FLOAT Value );







__declspec(dllimport) UBOOL appLoadFileToArray( TArray<BYTE>& Result, const TCHAR* Filename, FFileManager* FileManager=GFileManager );
__declspec(dllimport) UBOOL appLoadFileToString( FString& Result, const TCHAR* Filename, FFileManager* FileManager=GFileManager );
__declspec(dllimport) UBOOL appSaveArrayToFile( const TArray<BYTE>& Array, const TCHAR* Filename, FFileManager* FileManager=GFileManager );
__declspec(dllimport) UBOOL appSaveStringToFile( const FString& String, const TCHAR* Filename, FFileManager* FileManager=GFileManager );





__declspec(dllimport) void* appMemmove( void* Dest, const void* Src, INT Count );
__declspec(dllimport) INT appMemcmp( const void* Buf1, const void* Buf2, INT Count );
__declspec(dllimport) UBOOL appMemIsZero( const void* V, int Count );
__declspec(dllimport) DWORD appMemCrc( const void* Data, INT Length, DWORD CRC=0 );
__declspec(dllimport) void appMemswap( void* Ptr1, void* Ptr2, DWORD Size );
__declspec(dllimport) void appMemset( void* Dest, INT C, INT Count );



















inline void* operator new( unsigned int Size, const TCHAR* Tag )
{
	{;
	return GMalloc->Malloc( Size, Tag );
	};
}
inline void* operator new( unsigned int Size )
{
	{;
	return GMalloc->Malloc( Size, L"new" );
	};
}
inline void operator delete( void* Ptr )
{
	{;
	GMalloc->Free( Ptr );
	};
}


inline void* operator new[]( unsigned int Size, const TCHAR* Tag )
{
	{;
	return GMalloc->Malloc( Size, Tag );
	};
}
inline void* operator new[]( unsigned int Size )
{
	{;
	return GMalloc->Malloc( Size, L"new" );
	};
}
inline void operator delete[]( void* Ptr )
{
	{;
	GMalloc->Free( Ptr );
	};
}






__declspec(dllimport) BYTE appCeilLogTwo( DWORD Arg );








struct FMD5Context
{
	DWORD state[4];
	DWORD count[2];
	BYTE buffer[64];
};






__declspec(dllimport) void appMD5Init( FMD5Context* context );
__declspec(dllimport) void appMD5Update( FMD5Context* context, BYTE* input, INT inputLen );
__declspec(dllimport) void appMD5Final( BYTE* digest, FMD5Context* context );
__declspec(dllimport) void appMD5Transform( DWORD* state, BYTE* block );
__declspec(dllimport) void appMD5Encode( BYTE* output, DWORD* input, INT len );
__declspec(dllimport) void appMD5Decode( DWORD* output, BYTE* input, INT len );




































































class __declspec(dllimport) FArchive
{
public:
	
	virtual ~FArchive()
	{}
	virtual void Serialize( void* V, INT Length )
	{}
	virtual void SerializeBits( void* V, INT LengthBits )
	{
		Serialize( V, (LengthBits+7)/8 );
		if( IsLoading() )
			((BYTE*)V)[LengthBits/8] &= ((1<<(LengthBits&7))-1);
	}
	virtual void SerializeInt( DWORD& Value, DWORD Max )
	{

	}
	virtual void Preload( UObject* Object )
	{}
	virtual void CountBytes( SIZE_T InNum, SIZE_T InMax )
	{}
	virtual FArchive& operator<<( class FName& N )
	{
		return *this;
	}
	virtual FArchive& operator<<( class UObject*& Res )
	{
		return *this;
	}
	virtual INT MapName( FName* Name )
	{
		return 0;
	}
	virtual INT MapObject( UObject* Object )
	{
		return 0;
	}
	virtual INT Tell()
	{
		return INDEX_NONE;
	}
	virtual INT TotalSize()
	{
		return INDEX_NONE;
	}
	virtual UBOOL AtEnd()
	{
		INT Pos = Tell();
		return Pos!=INDEX_NONE && Pos>=TotalSize();
	}
	virtual void Seek( INT InPos )
	{}
	virtual void AttachLazyLoader( FLazyLoader* LazyLoader )
	{}
	virtual void DetachLazyLoader( FLazyLoader* LazyLoader )
	{}
	virtual void Precache( INT HintCount )
	{}
	virtual void Flush()
	{}
	virtual UBOOL Close()
	{
		return !ArIsError;
	}
	virtual UBOOL GetError()
	{
		return ArIsError;
	}

	
	FArchive& ByteOrderSerialize( void* V, INT Length )
	{

		Serialize( V, Length );













		return *this;
	}

	
	FArchive()
	:	ArVer			(69)
	,	ArNetVer		(400)

	,	ArLicenseeVer	(0x00)

	,	ArIsLoading		(0)
	,	ArIsSaving		(0)
	,   ArIsTrans		(0)
	,	ArIsPersistent  (0)
	,   ArIsError       (0)
	,	ArForEdit		(1)
	,	ArForClient		(1)
	,	ArForServer		(1)
	{}

	
	INT Ver()				{return ArVer;}
	INT NetVer()			{return ArNetVer&0x7fffffff;}

	INT LicenseeVer()		{return ArLicenseeVer;}

	UBOOL IsLoading()		{return ArIsLoading;}
	UBOOL IsSaving()		{return ArIsSaving;}
	UBOOL IsTrans()			{return ArIsTrans;}
	UBOOL IsNet()			{return (ArNetVer&0x80000000)!=0;}
	UBOOL IsPersistent()    {return ArIsPersistent;}
	UBOOL IsError()         {return ArIsError;}
	UBOOL ForEdit()			{return ArForEdit;}
	UBOOL ForClient()		{return ArForClient;}
	UBOOL ForServer()		{return ArForServer;}

	
	friend FArchive& operator<<( FArchive& Ar, ANSICHAR& C )
	{
		Ar.Serialize( &C, 1 );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, BYTE& B )
	{
		Ar.Serialize( &B, 1 );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, SBYTE& B )
	{
		Ar.Serialize( &B, 1 );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, _WORD& W )
	{
		Ar.ByteOrderSerialize( &W, sizeof(W) );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, SWORD& S )
	{
		Ar.ByteOrderSerialize( &S, sizeof(S) );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, DWORD& D )
	{
		Ar.ByteOrderSerialize( &D, sizeof(D) );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, INT& I )
	{
		Ar.ByteOrderSerialize( &I, sizeof(I) );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, FLOAT& F )
	{
		Ar.ByteOrderSerialize( &F, sizeof(F) );
		return Ar;
	}
	friend FArchive& operator<<( FArchive &Ar, QWORD& Q )
	{
		Ar.ByteOrderSerialize( &Q, sizeof(Q) );
		return Ar;
	}
	friend FArchive& operator<<( FArchive& Ar, SQWORD& S )
	{
		Ar.ByteOrderSerialize( &S, sizeof(S) );
		return Ar;
	}
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FTime& F );
protected:
	
	INT ArVer;
	INT ArNetVer;
	INT ArLicenseeVer;
	UBOOL ArIsLoading;
	UBOOL ArIsSaving;
	UBOOL ArIsTrans;
	UBOOL ArIsPersistent;
	UBOOL ArForEdit;
	UBOOL ArForClient;
	UBOOL ArForServer;
	UBOOL ArIsError;
};









class __declspec(dllimport) FCompactIndex
{
public:
	INT Value;
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FCompactIndex& I );
};




template <class T> T Arctor( FArchive& Ar )
{
	T Tmp;
	Ar << Tmp;
	return Tmp;
}

























template <class T> struct TTypeInfoBase
{
public:
	typedef const T& ConstInitType;
	static UBOOL NeedsDestructor() {return 1;}
	static UBOOL DefinitelyNeedsDestructor() {return 0;}
	static const T& ToInit( const T& In ) {return In;}
};
template <class T> struct TTypeInfo : public TTypeInfoBase<T>
{
};

template <> struct TTypeInfo<BYTE> : public TTypeInfoBase<BYTE>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<SBYTE> : public TTypeInfoBase<SBYTE>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<ANSICHAR> : public TTypeInfoBase<ANSICHAR>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<INT> : public TTypeInfoBase<INT>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<DWORD> : public TTypeInfoBase<DWORD>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<_WORD> : public TTypeInfoBase<_WORD>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<SWORD> : public TTypeInfoBase<SWORD>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<QWORD> : public TTypeInfoBase<QWORD>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<SQWORD> : public TTypeInfoBase<SQWORD>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<FName> : public TTypeInfoBase<FName>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};
template <> struct TTypeInfo<UObject*> : public TTypeInfoBase<UObject*>
{
public:
	static UBOOL NeedsDestructor() {return 0;}
};





template< class T > inline T Abs( const T A )
{
	return (A>=(T)0) ? A : -A;
}
template< class T > inline T Sgn( const T A )
{
	return (A>0) ? 1 : ((A<0) ? -1 : 0);
}
template< class T > inline T Max( const T A, const T B )
{
	return (A>=B) ? A : B;
}
template< class T > inline T Min( const T A, const T B )
{
	return (A<=B) ? A : B;
}
template< class T > inline T Square( const T A )
{
	return A*A;
}
template< class T > inline T Clamp( const T X, const T Min, const T Max )
{
	return X<Min ? Min : X<Max ? X : Max;
}
template< class T > inline T Align( const T Ptr, INT Alignment )
{
	return (T)(((DWORD)Ptr + Alignment - 1) & ~(Alignment-1));
}
template< class T > inline void Exchange( T& A, T& B )
{
	const T Temp = A;
	A = B;
	B = Temp;
}
template< class T > T Lerp( T& A, T& B, FLOAT Alpha )
{
	return A + Alpha * (B-A);
}
inline DWORD GetTypeHash( const BYTE A )
{
	return A;
}
inline DWORD GetTypeHash( const SBYTE A )
{
	return A;
}
inline DWORD GetTypeHash( const _WORD A )
{
	return A;
}
inline DWORD GetTypeHash( const SWORD A )
{
	return A;
}
inline DWORD GetTypeHash( const INT A )
{
	return A;
}
inline DWORD GetTypeHash( const DWORD A )
{
	return A;
}
inline DWORD GetTypeHash( const QWORD A )
{
	return (DWORD)A+((DWORD)(A>>32) * 23);
}
inline DWORD GetTypeHash( const SQWORD A )
{
	return (DWORD)A+((DWORD)(A>>32) * 23);
}
inline DWORD GetTypeHash( const TCHAR* S )
{
	return appStrihash(S);
}


















template <class T> class TAllocator
{};








class __declspec(dllimport) FArray
{
public:
	void* GetData()
	{
		return Data;
	}
	const void* GetData() const
	{
		return Data;
	}
	UBOOL IsValidIndex( INT i ) const
	{
		return i>=0 && i<ArrayNum;
	}
	INT Num() const
	{
		;
		;
		return ArrayNum;
	}
	void InsertZeroed( INT Index, INT Count, INT ElementSize )
	{
		{;
		Insert( Index, Count, ElementSize );
		appMemzero( (BYTE*)Data+Index*ElementSize, Count*ElementSize );
		};
	}
	void Insert( INT Index, INT Count, INT ElementSize )
	{
		{;
		;
		;
		;
		;
		;

		INT OldNum = ArrayNum;
		if( (ArrayNum+=Count)>ArrayMax )
		{
			ArrayMax = ArrayNum + 3*ArrayNum/8 + 32;
			Realloc( ElementSize );
		}
		appMemmove
		(
			(BYTE*)Data + (Index+Count )*ElementSize,
			(BYTE*)Data + (Index       )*ElementSize,
			              (OldNum-Index)*ElementSize
		);

		};
	}
	INT Add( INT Count, INT ElementSize )
	{
		{;
		;
		;
		;

		INT Index = ArrayNum;
		if( (ArrayNum+=Count)>ArrayMax )
		{
			ArrayMax = ArrayNum + 3*ArrayNum/8 + 32;
			Realloc( ElementSize );
		}

		return Index;
		};
	}
	INT AddZeroed( INT ElementSize, INT n=1 )
	{
		{;
		INT Index = Add( n, ElementSize );
		appMemzero( (BYTE*)Data+Index*ElementSize, n*ElementSize );
		return Index;
		};
	}
	void Shrink( INT ElementSize )
	{
		{;
		;
		;
		if( ArrayMax != ArrayNum )
		{
			ArrayMax = ArrayNum;
			Realloc( ElementSize );
		}
		};
	}
	void Empty( INT ElementSize, INT Slack=0 )
	{
		{;
		ArrayNum = 0;
		ArrayMax = Slack;
		Realloc( ElementSize );
		};
	}
	FArray()
	:	ArrayNum( 0 )
	,	ArrayMax( 0 )
	,	Data	( 0 )
	{}
	FArray( ENoInit )
	{}
	~FArray()
	{
		{;
		if( Data )
			GMalloc->Free( Data );
		Data = 0;
		ArrayNum = ArrayMax = 0;
		};
	}
	void CountBytes( FArchive& Ar, INT ElementSize )
	{
		{;
		Ar.CountBytes( ArrayNum*ElementSize, ArrayMax*ElementSize );
		};
	}
	void Remove( INT Index, INT Count, INT ElementSize );
protected:
	void Realloc( INT ElementSize );
	FArray( INT InNum, INT ElementSize )
	:	ArrayNum( InNum )
	,	ArrayMax( InNum )
	,	Data    ( 0  )
	{
		Realloc( ElementSize );
	}
	void* Data;
	INT	  ArrayNum;
	INT	  ArrayMax;
};




template< class T > class TArray : public FArray
{
public:
	typedef T ElementType;
	TArray()
	:	FArray()
	{}
	TArray( INT InNum )
	:	FArray( InNum, sizeof(T) )
	{}
	TArray( const TArray& Other )
	:	FArray( Other.ArrayNum, sizeof(T) )
	{
		{;
		if( TTypeInfo<T>::NeedsDestructor() )
		{
			ArrayNum=0;
			for( INT i=0; i<Other.ArrayNum; i++ )
				new(*this)T(Other(i));
		}
		else if( sizeof(T)!=1 )
		{
			for( INT i=0; i<ArrayNum; i++ )
				(*this)(i) = Other(i);
		}
		else
		{
			appMemcpy( &(*this)(0), &Other(0), ArrayNum * sizeof(T) );
		}
		};
	}
	TArray( ENoInit )
	: FArray( E_NoInit )
	{}
	~TArray()
	{
		;
		;
		Remove( 0, ArrayNum );
	}
    T& operator()( INT i )
	{
		{;
		;
		;
		;
		return ((T*)Data)[i];
		};
	}
	const T& operator()( INT i ) const
	{
		{;
		;
		;
		;
		return ((T*)Data)[i];
		};
	}
	T Pop()
	{
		{;
		{if(!(ArrayNum>0)) appFailAssert( "ArrayNum>0", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 388 );};
		;
		T Result = ((T*)Data)[ArrayNum-1];
		Remove( ArrayNum-1 );
		return Result;
		};
	}
	T& Last( INT c=0 )
	{
		{;
		{if(!(c<ArrayNum)) appFailAssert( "c<ArrayNum", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 398 );};
		;
		return ((T*)Data)[ArrayNum-c-1];
		};
	}
	const T& Last( INT c=0 ) const
	{
		{;
		;
		;
		return ((T*)Data)[ArrayNum-c-1];
		};
	}
	void Shrink()
	{
		{;
		FArray::Shrink( sizeof(T) );
		};
	}
	UBOOL FindItem( const T& Item, INT& Index ) const
	{
		{;
		for( Index=0; Index<ArrayNum; Index++ )
			if( (*this)(Index)==Item )
				return 1;
		return 0;
		};
	}
	INT FindItemIndex( const T& Item ) const
	{
		{;
		for( INT Index=0; Index<ArrayNum; Index++ )
			if( (*this)(Index)==Item )
				return Index;
		return INDEX_NONE;
		};
	}
	friend FArchive& operator<<( FArchive& Ar, TArray& A )
	{
		{static const TCHAR __FUNC_NAME__[]=L"TArray<<"; try{;
		A.CountBytes( Ar );
		if( sizeof(T)==1 )
		{
			
			Ar << (*(FCompactIndex*)&(A.ArrayNum));
			if( Ar.IsLoading() )
			{
				A.ArrayMax = A.ArrayNum;
				A.Realloc( sizeof(T) );
			}
			Ar.Serialize( &A(0), A.Num() );
		}
		else if( Ar.IsLoading() )
		{
			
			INT NewNum;
			Ar << (*(FCompactIndex*)&(NewNum));
			A.Empty( NewNum );
			for( INT i=0; i<NewNum; i++ )
				Ar << *new(A)T;
		}
		else
		{
			
			Ar << (*(FCompactIndex*)&(A.ArrayNum));
			for( INT i=0; i<A.ArrayNum; i++ )
				Ar << A( i );
		}
		return Ar;
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
	void CountBytes( FArchive& Ar )
	{
		{;
		FArray::CountBytes( Ar, sizeof(T) );
		};
	}

	
	INT Add( INT n=1 )
	{
		{;
		;
		return FArray::Add( n, sizeof(T) );
		};
	}
	void Insert( INT Index, INT Count=1 )
	{
		{;
		;
		FArray::Insert( Index, Count, sizeof(T) );
		};
	}
	void InsertZeroed( INT Index, INT Count=1 )
	{
		{;
		;
		FArray::InsertZeroed( Index, Count, sizeof(T) );
		};
	}
	void Remove( INT Index, INT Count=1 )
	{
		{;
		{if(!(Index>=0)) appFailAssert( "Index>=0", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 501 );};
		{if(!(Index<=ArrayNum)) appFailAssert( "Index<=ArrayNum", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 502 );};
		{if(!(Index+Count<=ArrayNum)) appFailAssert( "Index+Count<=ArrayNum", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 503 );};
		if( TTypeInfo<T>::NeedsDestructor() )
			for( INT i=Index; i<Index+Count; i++ )
				(&(*this)(i))->~T();
		FArray::Remove( Index, Count, sizeof(T) );
		};
	}
	void Empty( INT Slack=0 )
	{
		{;
		if( TTypeInfo<T>::NeedsDestructor() )
			for( INT i=0; i<ArrayNum; i++ )
				(&(*this)(i))->~T();
		FArray::Empty( sizeof(T), Slack );
		};
	}

	
	TArray& operator=( const TArray& Other )
	{
		{;
		if( this != &Other )
		{
			Empty( Other.ArrayNum );
			for( INT i=0; i<Other.ArrayNum; i++ )
				new( *this )T( Other(i) );
		}
		return *this;
		};
	}
	INT AddItem( const T& Item )
	{
		{;
		;
		INT Index=Add();
		(*this)(Index)=Item;
		return Index;
		};
	}
	INT AddZeroed( INT n=1 )
	{
		{;
		return FArray::AddZeroed( sizeof(T), n );
		};
	}
	INT AddUniqueItem( const T& Item )
	{
		{;
		;
		for( INT Index=0; Index<ArrayNum; Index++ )
			if( (*this)(Index)==Item )
				return Index;
		return AddItem( Item );
		};
	}
	INT RemoveItem( const T& Item )
	{
		{;
		INT OriginalNum=ArrayNum;
		for( INT Index=0; Index<ArrayNum; Index++ )
			if( (*this)(Index)==Item )
				Remove( Index-- );
		return OriginalNum - ArrayNum;
		};
	}

	
	class TIterator
	{
	public:
		TIterator( TArray<T>& InArray ) : Array(InArray), Index(-1) { ++*this;      }
		void operator++()      { ++Index;                                           }
		void RemoveCurrent()   { Array.Remove(Index--); }
		INT GetIndex()   const { return Index;                                      }
		operator UBOOL() const { return Index < Array.Num();                        }
		T& operator*()   const { return Array(Index);                               }
		T* operator->()  const { return &Array(Index);                              }
		T& GetCurrent()  const { return Array( Index );                             }
		T& GetPrev()     const { return Array( Index ? Index-1 : Array.Num()-1 );   }
		T& GetNext()     const { return Array( Index<Array.Num()-1 ? Index+1 : 0 ); }
	private:
		TArray<T>& Array;
		INT Index;
	};
};




template <class T> void* operator new( size_t Size, TArray<T>& Array )
{
	{;
	INT Index = Array.FArray::Add(1,sizeof(T));
	return &Array(Index);
	};
}
template <class T> void* operator new( size_t Size, TArray<T>& Array, INT Index )
{
	{;
	Array.FArray::Insert(Index,1,sizeof(T));
	return &Array(Index);
	};
}




template <class T> inline void ExchangeArray( TArray<T>& A, TArray<T>& B )
{
	{;
	appMemswap( &A, &B, sizeof(FArray) );
	};
}





template< class T > class TTransArray : public TArray<T>
{
public:
	
	TTransArray( UObject* InOwner, INT InNum=0 )
	:	TArray<T>( InNum )
	,	Owner( InOwner )
	{
		;
	}
	TTransArray( UObject* InOwner, const TArray<T>& Other )
	:	TArray<T>( Other )
	,	Owner( InOwner )
	{
		;
	}
	TTransArray& operator=( const TTransArray& Other )
	{
		operator=( (const TArray<T>&)Other );
		return *this;
	}

	
	INT Add( INT Count=1 )
	{
		{;
		INT Index = TArray<T>::Add( Count );
		if( GUndo )
			GUndo->SaveArray( Owner, this, Index, Count, 1, sizeof(T), SerializeItem, DestructItem );
		return Index;
		};
	}
	void Insert( INT Index, INT Count=1 )
	{
		{;
		FArray::Insert( Index, Count, sizeof(T) );
		if( GUndo )
			GUndo->SaveArray( Owner, this, Index, Count, 1, sizeof(T), SerializeItem, DestructItem );
		};
	}
	void Remove( INT Index, INT Count=1 )
	{
		{;
		if( GUndo )
			GUndo->SaveArray( Owner, this, Index, Count, -1, sizeof(T), SerializeItem, DestructItem );
		TArray<T>::Remove( Index, Count );
		};
	}
	void Empty( INT Slack=0 )
	{
		{;
		if( GUndo )
			GUndo->SaveArray( Owner, this, 0, ArrayNum, -1, sizeof(T), SerializeItem, DestructItem );
		TArray<T>::Empty( Slack );
		};
	}

	
	TTransArray& operator=( const TArray<T>& Other )
	{
		{;
		if( this != &Other )
		{
			Empty( Other.Num() );
			for( INT i=0; i<Other.Num(); i++ )
				new( *this )T( Other(i) );
		}
		return *this;
		};
	}
	INT AddItem( const T& Item )
	{
		{;
		INT Index=Add();
		(*this)(Index)=Item;
		return Index;
		};
	}
	INT AddZeroed( INT n=1 )
	{
		{;
		INT Index = Add(n);
		appMemzero( &(*this)(Index), n*sizeof(T) );
		return Index;
		};
	}
	INT AddUniqueItem( const T& Item )
	{
		{;
		for( INT Index=0; Index<ArrayNum; Index++ )
			if( (*this)(Index)==Item )
				return Index;
		return AddItem( Item );
		};
	}
	INT RemoveItem( const T& Item )
	{
		{;
		INT OriginalNum=ArrayNum;
		for( INT Index=0; Index<ArrayNum; Index++ )
			if( (*this)(Index)==Item )
				Remove( Index-- );
		return OriginalNum - ArrayNum;
		};
	}

	
	UObject* GetOwner()
	{
		return Owner;
	}
	void ModifyItem( INT Index )
	{
		{;
		if( GUndo )
			GUndo->SaveArray( Owner, this, Index, 1, 0, sizeof(T), SerializeItem, DestructItem );
		};
	}
	void ModifyAllItems()
	{
		{;
		if( GUndo )
			GUndo->SaveArray( Owner, this, 0, Num(), 0, sizeof(T), SerializeItem, DestructItem );
		};
	}
	friend FArchive& operator<<( FArchive& Ar, TTransArray& A )
	{
		{static const TCHAR __FUNC_NAME__[]=L"TTransArray<<"; try{;
		if( !Ar.IsTrans() )
			Ar << (TArray<T>&)A;
		return Ar;
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
protected:
	static void SerializeItem( FArchive& Ar, void* TPtr )
	{
		{;
		Ar << *(T*)TPtr;
		};
	}
	static void DestructItem( void* TPtr )
	{
		{;
		((T*)TPtr)->~T();
		};
	}
	UObject* Owner;
private:

	
	TTransArray( const TArray<T>& Other )
	{}
};




template <class T> void* operator new( size_t Size, TTransArray<T>& Array )
{
	{;
	INT Index = Array.Add();
	return &Array(Index);
	};
}
template <class T> void* operator new( size_t Size, TTransArray<T>& Array, INT Index )
{
	{;
	Array.Insert(Index);
	return &Array(Index);
	};
}








class FLazyLoader
{
	friend class ULinkerLoad;
protected:
	FArchive*	 SavedAr;
	INT          SavedPos;
public:
	FLazyLoader()
	: SavedAr( 0 )
	, SavedPos( 0 )
	{}
	virtual void Load()=0;
	virtual void Unload()=0;
};




template <class T> class TLazyArray : public TArray<T>, public FLazyLoader
{
public:
	TLazyArray( INT InNum=0 )
	: TArray<T>( InNum )
	, FLazyLoader()
	{}
	~TLazyArray()
	{
		{static const TCHAR __FUNC_NAME__[]=L"TLazyArray::~TLazyArray"; try{;
		if( SavedAr )
			SavedAr->DetachLazyLoader( this );
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
























	void Load()
	{
		
		{static const TCHAR __FUNC_NAME__[]=L"TLazyArray::Load"; try{;
		if( SavedPos>0 )
		{
			
			INT PushedPos = SavedAr->Tell();
			SavedAr->Seek( SavedPos );
			*SavedAr << (TArray<T>&)*this;
			SavedPos *= -1;
			SavedAr->Seek( PushedPos );
		}
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
	void Unload()



	{
		
		{static const TCHAR __FUNC_NAME__[]=L"TLazyArray::Unload"; try{;
		if( SavedPos<0 )
		{
			
			Empty();
			SavedPos *= -1;
		}
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}

	friend FArchive& operator<<( FArchive& Ar, TLazyArray& This )
	{
		{static const TCHAR __FUNC_NAME__[]=L"TLazyArray<<"; try{;
		if( Ar.IsLoading() )
		{
			INT SeekPos=0;
			if( Ar.Ver() <= 61 )
			{
				
				Ar.AttachLazyLoader( &This );
				INT SkipCount;
				Ar << (*(FCompactIndex*)&(SkipCount));
				SeekPos = Ar.Tell() + SkipCount*sizeof(T);
					
			}
			else
			{
				Ar << SeekPos;
				Ar.AttachLazyLoader( &This );
			}
			if( !GLazyLoad )
				This.Load();
			Ar.Seek( SeekPos );
		}
		else if( Ar.IsSaving() && Ar.Ver()>61 )
		{
			
			INT CountPos = Ar.Tell();
			Ar << CountPos << (TArray<T>&)This;
			INT EndPos = Ar.Tell();
			Ar.Seek( CountPos );
			Ar << EndPos;
			Ar.Seek( EndPos );
		}
		else Ar << (TArray<T>&)This;
		return Ar;
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
};






















class __declspec(dllimport) FString : protected TArray<TCHAR>
{
public:
	FString()
	: TArray<TCHAR>()
	{}
	FString( const FString& Other )
	: TArray<TCHAR>( Other.ArrayNum )
	{
		if( ArrayNum )
			appMemcpy( &(*this)(0), &Other(0), ArrayNum*sizeof(TCHAR) );
	}
	FString( const TCHAR* In )
	: TArray<TCHAR>( *In ? (appStrlen(In)+1) : 0 )
	{
		if( ArrayNum )
			appMemcpy( &(*this)(0), In, ArrayNum*sizeof(TCHAR) );
	}
	FString( ENoInit )
	: TArray<TCHAR>( E_NoInit )
	{}
	explicit FString( BYTE   Arg, INT Digits=1 );
	explicit FString( SBYTE  Arg, INT Digits=1 );
	explicit FString( _WORD  Arg, INT Digits=1 );
	explicit FString( SWORD  Arg, INT Digits=1 );
	explicit FString( INT    Arg, INT Digits=1 );
	explicit FString( DWORD  Arg, INT Digits=1 );
	explicit FString( FLOAT  Arg, INT Digits=1, INT RightDigits=0, UBOOL LeadZero=1 );
	FString& operator=( const TCHAR* Other )
	{
		if( &(*this)(0)!=Other )
		{
			ArrayNum = ArrayMax = *Other ? appStrlen(Other)+1 : 0;
			Realloc( sizeof(TCHAR) );
			if( ArrayNum )
				appMemcpy( &(*this)(0), Other, ArrayNum*sizeof(TCHAR) );
		}
		return *this;
	}
	FString& operator=( const FString& Other )
	{
		if( this != &Other )
		{
			ArrayNum = ArrayMax = Other.Num();
			Realloc( sizeof(TCHAR) );
			if( ArrayNum )
				appMemcpy( &(*this)(0), *Other, ArrayNum*sizeof(TCHAR) );
		}
		return *this;
	}
	~FString()
	{
		TArray<TCHAR>::Empty();		
	}
	void Empty()
	{
		TArray<TCHAR>::Empty();
	}
	void Shrink()
	{
		TArray<TCHAR>::Shrink();
	}
	const TCHAR* operator*() const
	{
		return Num() ? &(*this)(0) : L"";
	}
	operator UBOOL() const
	{
		return Num()!=0;
	}
	TArray<TCHAR>& GetCharArray()
	{
		
		
		return (TArray<TCHAR>&)*this;
	}
	FString& operator+=( const TCHAR* Str )
	{
		if( ArrayNum )
		{
			INT Index = ArrayNum-1;
			Add( appStrlen(Str) );
			appStrcpy( &(*this)(Index), Str );
		}
		else if( *Str )
		{
			Add( appStrlen(Str)+1 );
			appStrcpy( &(*this)(0), Str );
		}
		return *this;
	}
	FString& operator+=( const FString& Str )
	{
		return operator+=( *Str );
	}
	FString operator+( const TCHAR* Str )
	{
		return FString( *this ) += Str;
	}
	FString operator+( const FString& Str )
	{
		return operator+( *Str );
	}
	FString& operator*=( const TCHAR* Str )
	{
		if( ArrayNum>1 && (*this)(ArrayNum-2)!=L"\\"[0] )
			*this += L"\\";
		return *this += Str;
	}
	FString& operator*=( const FString& Str )
	{
		return operator*=( *Str );
	}
	FString operator*( const TCHAR* Str ) const
	{
		return FString( *this ) *= Str;
	}
	FString operator*( const FString& Str ) const
	{
		return operator*( *Str );
	}
	UBOOL operator<=( const TCHAR* Other ) const
	{
		return !(appStricmp( **this, Other ) > 0);
	}
	UBOOL operator<( const TCHAR* Other ) const
	{
		return appStricmp( **this, Other ) < 0;
	}
	UBOOL operator>=( const TCHAR* Other ) const
	{
		return !(appStricmp( **this, Other ) < 0);
	}
	UBOOL operator>( const TCHAR* Other ) const
	{
		return appStricmp( **this, Other ) > 0;
	}
	UBOOL operator==( const TCHAR* Other ) const
	{
		return appStricmp( **this, Other )==0;
	}
	UBOOL operator==( const FString& Other ) const
	{
		return appStricmp( **this, *Other )==0;
	}
	UBOOL operator!=( const TCHAR* Other ) const
	{
		return appStricmp( **this, Other )!=0;
	}
	UBOOL operator!=( const FString& Other ) const
	{
		return appStricmp( **this, *Other )!=0;
	}
	INT Len() const
	{
		return Num() ? Num()-1 : 0;
	}
	FString Left( INT Count ) const
	{
		return FString( Clamp(Count,0,Len()), **this );
	}
	FString LeftChop( INT Count ) const
	{
		return FString( Clamp(Len()-Count,0,Len()), **this );
	}
	FString Right( INT Count ) const
	{
		return FString( **this + Len()-Clamp(Count,0,Len()) );
	}
	FString Mid( INT Start, INT Count=MAXINT ) const
	{
		DWORD End = Start+Count;
		Start    = Clamp( (DWORD)Start, (DWORD)0,     (DWORD)Len() );
		End      = Clamp( (DWORD)End,   (DWORD)Start, (DWORD)Len() );
		return FString( End-Start, **this + Start );
	}
	INT InStr( const TCHAR* SubStr, UBOOL Right=0 ) const
	{
		if( !Right )
		{
			TCHAR* Tmp = appStrstr(**this,SubStr);
			return Tmp ? (Tmp-**this) : -1;
		}
		else
		{
			for( INT i=Len()-1; i>=0; i-- )
			{
				INT j;
				for( j=0; SubStr[j]; j++ )
					if( (*this)(i+j)!=SubStr[j] )
						break;
				if( !SubStr[j] )
					return i;
			}
			return -1;
		}
	}
	INT InStr( const FString& SubStr, UBOOL Right=0 ) const
	{
		return InStr( *SubStr, Right );
	}
	UBOOL Split( const FString& InS, FString* LeftS, FString* RightS, UBOOL Right=0 ) const
	{
		INT InPos = InStr(InS,Right);
		if( InPos<0 )
			return 0;
		if( LeftS )
			*LeftS = Left(InPos);
		if( RightS )
			*RightS = Mid(InPos+InS.Len());
		return 1;
	}
	FString Caps() const
	{
		FString New( **this );
		for( INT i=0; i<ArrayNum; i++ )
			New(i) = appToUpper(New(i));
		return New;
	}
	FString Locs() const
	{
		FString New( **this );
		for( INT i=0; i<ArrayNum; i++ )
			New(i) = appToLower(New(i));
		return New;
	}
	FString LeftPad( INT ChCount );
	FString RightPad( INT ChCount );
	static FString Printf( const TCHAR* Fmt, ... );
	static FString Chr( TCHAR Ch );
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FString& S );
	friend struct FStringNoInit;
private:
	FString( INT InCount, const TCHAR* InSrc )
	:	TArray<TCHAR>( InCount ? InCount+1 : 0 )
	{
		if( ArrayNum )
			appStrncpy( &(*this)(0), InSrc, InCount+1 );
	}
};
struct __declspec(dllimport) FStringNoInit : public FString
{
	FStringNoInit()
	: FString( E_NoInit )
	{}
	FStringNoInit& operator=( const TCHAR* Other )
	{
		if( &(*this)(0)!=Other )
		{
			ArrayNum = ArrayMax = *Other ? appStrlen(Other)+1 : 0;
			Realloc( sizeof(TCHAR) );
			if( ArrayNum )
				appMemcpy( &(*this)(0), Other, ArrayNum*sizeof(TCHAR) );
		}
		return *this;
	}
	FStringNoInit& operator=( const FString& Other )
	{
		if( this != &Other )
		{
			ArrayNum = ArrayMax = Other.Num();
			Realloc( sizeof(TCHAR) );
			if( ArrayNum )
				appMemcpy( &(*this)(0), *Other, ArrayNum*sizeof(TCHAR) );
		}
		return *this;
	}
};
inline DWORD GetTypeHash( const FString& S )
{
	return appStrihash(*S);
}
template <> struct TTypeInfo<FString> : public TTypeInfoBase<FString>
{
	typedef const TCHAR* ConstInitType;
	static const TCHAR* ToInit( const FString& In ) {return *In;}
	static UBOOL DefinitelyNeedsDestructor() {return 0;}
};




inline void ExchangeString( FString& A, FString& B )
{
	{;
	appMemswap( &A, &B, sizeof(FString) );
	};
}








class FStringOutputDevice : public FString, public FOutputDevice
{
public:
	FStringOutputDevice( const TCHAR* InStr=L"" )
	: FString( InStr )
	{}
	void Serialize( const TCHAR* Data, EName Event )
	{
		*this += (TCHAR*)Data;
	}
};




class FBufferWriter : public FArchive
{
public:
	FBufferWriter( TArray<BYTE>& InBytes )
	: Bytes( InBytes )
	, Pos( 0 )
	{
		ArIsSaving = 1;
	}
	void Serialize( void* InData, INT Length )
	{
		if( Pos+Length>Bytes.Num() )
			Bytes.Add( Pos+Length-Bytes.Num() );
		if( Length == 1 )
			Bytes(Pos) = ((BYTE*)InData)[0];
		else
			appMemcpy( &Bytes(Pos), InData, Length );
		Pos += Length;
	}
	INT Tell()
	{
		return Pos;
	}
	void Seek( INT InPos )
	{
		Pos = InPos;
	}
	INT TotalSize()
	{
		return Bytes.Num();
	}
private:
	TArray<BYTE>& Bytes;
	INT Pos;
};




class FBufferArchive : public FBufferWriter, public TArray<BYTE>
{
public:
	FBufferArchive()
	: FBufferWriter( (TArray<BYTE>&)*this )
	{}
};




class __declspec(dllimport) FBufferReader : public FArchive
{
public:
	FBufferReader( const TArray<BYTE>& InBytes )
	:	Bytes	( InBytes )
	,	Pos 	( 0 )
	{
		ArIsLoading = ArIsTrans = 1;
	}
	void Serialize( void* Data, INT Num )
	{
		{if(!(Pos>=0)) appFailAssert( "Pos>=0", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 1320 );};
		{if(!(Pos+Num<=Bytes.Num())) appFailAssert( "Pos+Num<=Bytes.Num()", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 1321 );};
		if( Num == 1 )
			((BYTE*)Data)[0] = Bytes(Pos);
		else
			appMemcpy( Data, &Bytes(Pos), Num );
		Pos += Num;
	}
	INT Tell()
	{
		return Pos;
	}
	INT TotalSize()
	{
		return Bytes.Num();
	}
	void Seek( INT InPos )
	{
		{if(!(InPos>=0)) appFailAssert( "InPos>=0", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 1338 );};
		{if(!(InPos<=Bytes.Num())) appFailAssert( "InPos<=Bytes.Num()", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnTemplate.h", 1339 );};
		Pos = InPos;
	}
	UBOOL AtEnd()
	{
		return Pos>=Bytes.Num();
	}
private:
	const TArray<BYTE>& Bytes;
	INT Pos;
};








template< class TK, class TI > class TMapBase
{
protected:
	class TPair
	{
	public:
		INT HashNext;
		TK Key;
		TI Value;
		TPair(typename TTypeInfo<TK>::ConstInitType InKey,typename TTypeInfo<TI>::ConstInitType InValue )
		: Key( InKey ), Value( InValue )
		{}
		TPair()
		{}
		friend FArchive& operator<<( FArchive& Ar, TPair& F )
		{
			{;
			return Ar << F.Key << F.Value;
			};
		}
	};
	void Rehash()
	{
		{;
		;
		;
		INT* NewHash = new(L"HashMapHash")INT[HashCount];
		{for( INT i=0; i<HashCount; i++ )
		{
			NewHash[i] = INDEX_NONE;
		}}
		{for( INT i=0; i<Pairs.Num(); i++ )
		{
			TPair& Pair    = Pairs(i);
			INT    iHash   = (GetTypeHash(Pair.Key) & (HashCount-1));
			Pair.HashNext  = NewHash[iHash];
			NewHash[iHash] = i;
		}}
		if( Hash )
			delete Hash;
		Hash = NewHash;
		};
	}
	void Relax()
	{
		{;
		while( HashCount>Pairs.Num()*2+8 )
			HashCount /= 2;
		Rehash();
		};
	}
	TI& Add(typename TTypeInfo<TK>::ConstInitType InKey,typename TTypeInfo<TI>::ConstInitType InValue )
	{
		{;
		TPair& Pair   = *new(Pairs)TPair( InKey, InValue );
		INT    iHash  = (GetTypeHash(Pair.Key) & (HashCount-1));
		Pair.HashNext = Hash[iHash];
		Hash[iHash]   = Pairs.Num()-1;
		if( HashCount*2+8 < Pairs.Num() )
		{
			HashCount *= 2;
			Rehash();
		}
		return Pair.Value;
		};
	}
	TArray<TPair> Pairs;
	INT* Hash;
	INT HashCount;
public:
	TMapBase()
	:	Hash( 0 )
	,	HashCount( 8 )
	{
		{;
		Rehash();
		};
	}
	TMapBase( const TMapBase& Other )
	:	Pairs( Other.Pairs )
	,	HashCount( Other.HashCount )
	,	Hash( 0 )
	{
		{;
		Rehash();
		};
	}
	~TMapBase()
	{
		{;
		if( Hash )
			delete Hash;
		Hash = 0;
		HashCount = 0;
		};
	}
	TMapBase& operator=( const TMapBase& Other )
	{
		{;
		Pairs     = Other.Pairs;
		HashCount = Other.HashCount;
		Rehash();
		return *this;
		};
	}
	void Empty()
	{
		{;
		;
		Pairs.Empty();
		HashCount = 8;
		Rehash();
		};
	}
	TI& Set(typename TTypeInfo<TK>::ConstInitType InKey,typename TTypeInfo<TI>::ConstInitType InValue )
	{
		{;
		for( INT i=Hash[(GetTypeHash(InKey) & (HashCount-1))]; i!=INDEX_NONE; i=Pairs(i).HashNext )
			if( Pairs(i).Key==InKey )
				{Pairs(i).Value=InValue; return Pairs(i).Value;}
		return Add( InKey, InValue );
		};
	}
	INT Remove(typename TTypeInfo<TK>::ConstInitType InKey )
	{
		{;
		INT Count=0;
		for( INT i=Pairs.Num()-1; i>=0; i-- )
			if( Pairs(i).Key==InKey )
				{Pairs.Remove(i); Count++;}
		if( Count )
			Relax();
		return Count;
		};
	}
	TI* Find( const TK& Key )
	{
		{;
		for( INT i=Hash[(GetTypeHash(Key) & (HashCount-1))]; i!=INDEX_NONE; i=Pairs(i).HashNext )
			if( Pairs(i).Key==Key )
				return &Pairs(i).Value;
		return 0;
		};
	}
	TI FindRef( const TK& Key )
	{
		{;
		for( INT i=Hash[(GetTypeHash(Key) & (HashCount-1))]; i!=INDEX_NONE; i=Pairs(i).HashNext )
			if( Pairs(i).Key==Key )
				return Pairs(i).Value;
		return 0;
		};
	}
	const TI* Find( const TK& Key ) const
	{
		{;
		for( INT i=Hash[(GetTypeHash(Key) & (HashCount-1))]; i!=INDEX_NONE; i=Pairs(i).HashNext )
			if( Pairs(i).Key==Key )
				return &Pairs(i).Value;
		return 0;
		};
	}
	friend FArchive& operator<<( FArchive& Ar, TMapBase& M )
	{
		{;
		Ar << M.Pairs;
		if( Ar.IsLoading() )
			M.Rehash();
		return Ar;
		};
	}
	void Dump( FOutputDevice& Ar )
	{
		{static const TCHAR __FUNC_NAME__[]=L"TMapBase::Dump"; try{;
		Ar.Logf( L"TMapBase: %i items, %i hash slots", Pairs.Num(), HashCount );
		for( INT i=0; i<HashCount; i++ )
		{
			INT c=0;
			for( INT j=Hash[i]; j!=INDEX_NONE; j=Pairs(j).HashNext )
				c++;
			Ar.Logf( L"   Hash[%i] = %i", i, c );
		}
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
	class TIterator
	{
	public:
		TIterator( TMapBase& InMap ) : Pairs( InMap.Pairs ), Index( 0 ) {}
		void operator++()          { ++Index; }
		void RemoveCurrent()       { Pairs.Remove(Index--); }
		operator UBOOL() const     { return Index<Pairs.Num(); }
		TK& Key() const            { return Pairs(Index).Key; }
		TI& Value() const          { return Pairs(Index).Value; }
	private:
		TArray<TPair>& Pairs;
		INT Index;
	};
	friend class TIterator;
};
template< class TK, class TI > class TMap : public TMapBase<TK,TI>
{
public:
	TMap& operator=( const TMap& Other )
	{
		TMapBase<TK,TI>::operator=( Other );
		return *this;
	}

	int Num()
	{
		{;
		return Pairs.Num();
		};
	}
};
template< class TK, class TI > class TMultiMap : public TMapBase<TK,TI>
{
public:
	TMultiMap& operator=( const TMultiMap& Other )
	{
		TMapBase<TK,TI>::operator=( Other );
		return *this;
	}
	void MultiFind( const TK& Key, TArray<TI>& Values ) 
	{
		{;
		for( INT i=Hash[(GetTypeHash(Key) & (HashCount-1))]; i!=INDEX_NONE; i=Pairs(i).HashNext )
			if( Pairs(i).Key==Key )
				new(Values)TI(Pairs(i).Value);
		};
	}
	TI& Add(typename TTypeInfo<TK>::ConstInitType InKey,typename TTypeInfo<TI>::ConstInitType InValue )
	{
		return TMapBase<TK,TI>::Add( InKey, InValue );
	}
	TI& AddUnique(typename TTypeInfo<TK>::ConstInitType InKey,typename TTypeInfo<TI>::ConstInitType InValue )
	{
		for( INT i=Hash[(GetTypeHash(InKey) & (HashCount-1))]; i!=INDEX_NONE; i=Pairs(i).HashNext )
			if( Pairs(i).Key==InKey && Pairs(i).Value==InValue )
				return Pairs(i).Value;
		return Add( InKey, InValue );
	}
	INT RemovePair(typename TTypeInfo<TK>::ConstInitType InKey,typename TTypeInfo<TI>::ConstInitType InValue )
	{
		{;
		INT Count=0;
		for( INT i=Pairs.Num()-1; i>=0; i-- )
			if( Pairs(i).Key==InKey && Pairs(i).Value==InValue )
				{Pairs.Remove(i); Count++;}
		if( Count )
			Relax();
		return Count;
		};
	}
	TI* FindPair( const TK& Key, const TK& Value )
	{
		{;
		for( INT i=Hash[(GetTypeHash(Key) & (HashCount-1))]; i!=INDEX_NONE; i=Pairs(i).HashNext )
			if( Pairs(i).Key==Key && Pairs(i).Value==Value )
				return &Pairs(i).Value;
		return 0;
		};
	}
};









template<class T> struct TStack
{
	T* Min;
	T* Max;
};
template<class T> void Sort( T* First, INT Num )
{
	{static const TCHAR __FUNC_NAME__[]=L"Sort"; try{;
	if( Num<2 )
		return;
	TStack<T> RecursionStack[32]={{First,First+Num-1}}, Current, Inner;
	for( TStack<T>* StackTop=RecursionStack; StackTop>=RecursionStack; --StackTop )
	{
		Current = *StackTop;
	Loop:
		INT Count = Current.Max - Current.Min + 1;
		if( Count <= 8 )
		{
			
			while( Current.Max > Current.Min )
			{
				T *Max, *Item;
				for( Max=Current.Min, Item=Current.Min+1; Item<=Current.Max; Item++ )
					if( Compare(*Item, *Max) > 0 )
						Max = Item;
				Exchange( *Max, *Current.Max-- );
			}
		}
		else
		{
			
			Exchange( Current.Min[Count/2], Current.Min[0] );

			
			Inner.Min = Current.Min;
			Inner.Max = Current.Max+1;
			for( ; ; )
			{
				while( ++Inner.Min<=Current.Max && Compare(*Inner.Min, *Current.Min) <= 0 );
				while( --Inner.Max> Current.Min && Compare(*Inner.Max, *Current.Min) >= 0 );
				if( Inner.Min>Inner.Max )
					break;
				Exchange( *Inner.Min, *Inner.Max );
			}
			Exchange( *Current.Min, *Inner.Max );

			
			if( Inner.Max-1-Current.Min >= Current.Max-Inner.Min )
			{
				if( Current.Min+1 < Inner.Max )
				{
					StackTop->Min = Current.Min;
					StackTop->Max = Inner.Max - 1;
					StackTop++;
				}
				if( Current.Max>Inner.Min )
				{
					Current.Min = Inner.Min;
					goto Loop;
				}
			}
			else
			{
				if( Current.Max>Inner.Min )
				{
					StackTop->Min = Inner  .Min;
					StackTop->Max = Current.Max;
					StackTop++;
				}
				if( Current.Min+1<Inner.Max )
				{
					Current.Max = Inner.Max - 1;
					goto Loop;
				}
			}
		}
	}
	}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
}








template< class T > class TDoubleLinkedList : public T
{
public:
	TDoubleLinkedList* Next;
	TDoubleLinkedList** PrevLink;
	void Unlink()
	{
		if( Next )
			Next->PrevLink = PrevLink;
		*PrevLink = Next;
	}
	void Link( TDoubleLinkedList*& Before )
	{
		if( Before )
			Before->PrevLink = &Next;
		Next     = Before;
		PrevLink = &Before;
		Before   = this;
	}
};








union __declspec(dllimport) FRainbowPtr
{
	
	void*  PtrVOID;
	BYTE*  PtrBYTE;
	_WORD* PtrWORD;
	DWORD* PtrDWORD;
	QWORD* PtrQWORD;
	FLOAT* PtrFLOAT;

	
	FRainbowPtr() {}
	FRainbowPtr( void* Ptr ) : PtrVOID(Ptr) {};
};



















enum {NAME_SIZE	= 64};


typedef INT NAME_INDEX;


enum EFindName
{
	FNAME_Find,			
	FNAME_Add,			
	FNAME_Intrinsic,	
};








struct FNameEntry
{
	
	NAME_INDEX	Index;				
	DWORD		Flags;				
	FNameEntry*	HashNext;			

	
	TCHAR		Name[NAME_SIZE];	

	
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FNameEntry& E );
	__declspec(dllimport) friend FNameEntry* AllocateNameEntry( const TCHAR* Name, DWORD Index, DWORD Flags, FNameEntry* HashNext );
};
template <> struct TTypeInfo<FNameEntry*> : public TTypeInfoBase<FNameEntry*>
{
	static UBOOL NeedsDestructor() {return 0;}
};











class __declspec(dllimport) FName 
{
public:
	
	const TCHAR* operator*() const
	{
		;
		;
		return Names(Index)->Name;
	}
	NAME_INDEX GetIndex() const
	{
		;
		;
		return Index;
	}
	DWORD GetFlags() const
	{
		;
		;
		return Names(Index)->Flags;
	}
	void SetFlags( DWORD Set ) const
	{
		;
		;
		Names(Index)->Flags |= Set;
	}
	void ClearFlags( DWORD Clear ) const
	{
		;
		;
		Names(Index)->Flags &= ~Clear;
	}
	UBOOL operator==( const FName& Other ) const
	{
		return Index==Other.Index;
	}
	UBOOL operator!=( const FName& Other ) const
	{
		return Index!=Other.Index;
	}
	UBOOL IsValid()
	{
		return Index>=0 && Index<Names.Num() && Names(Index)!=0;
	}

	
	FName( enum EName N )
	: Index( N )
	{}
	FName()
	{}
	FName( const TCHAR* Name, EFindName FindType=FNAME_Add );

	
	static void StaticInit();
	static void StaticExit();
	static void DeleteEntry( int i );
	static void DisplayHash( class FOutputDevice& Ar );
	static void Hardcode( FNameEntry* AutoName );

	
	static const TCHAR* SafeString( EName Index )
	{
		return Initialized ? Names(Index)->Name : L"Uninitialized";
	}
	static UBOOL SafeSuppressed( EName Index )
	{
		return Initialized && (Names(Index)->Flags & 0x00001000);
	}
	static int GetMaxNames()
	{
		return Names.Num();
	}
	static FNameEntry* GetEntry( int i )
	{
		return Names(i);
	}
	static UBOOL GetInitialized()
	{
		return Initialized;
	}

private:
	
	NAME_INDEX Index;

	
	static TArray<FNameEntry*>	Names;			 
	static TArray<INT>          Available;       
	static FNameEntry*			NameHash[4096];  
	static UBOOL				Initialized;	 
};
inline DWORD GetTypeHash( const FName N )
{
	return N.GetIndex();
}














class UStruct;






enum {MAX_STRING_CONST_SIZE		= 256               };
enum {MAX_CONST_SIZE			= 16 *sizeof(TCHAR) };
enum {MAX_FUNC_PARMS			= 16                };















enum EStateFlags
{
	
	STATE_Editable		= 0x00000001,	
	STATE_Auto			= 0x00000002,	
	STATE_Simulated     = 0x00000004,   
};




enum EFunctionFlags
{
	
	FUNC_Final			= 0x00000001,	
	FUNC_Defined		= 0x00000002,	
	FUNC_Iterator		= 0x00000004,	
	FUNC_Latent		    = 0x00000008,	
	FUNC_PreOperator	= 0x00000010,	
	FUNC_Singular       = 0x00000020,   
	FUNC_Net            = 0x00000040,   
	FUNC_NetReliable    = 0x00000080,   
	FUNC_Simulated		= 0x00000100,	
	FUNC_Exec		    = 0x00000200,	
	FUNC_Native			= 0x00000400,	
	FUNC_Event          = 0x00000800,   
	FUNC_Operator       = 0x00001000,   
	FUNC_Static         = 0x00002000,   
	FUNC_NoExport       = 0x00004000,   
	FUNC_Const          = 0x00008000,   
	FUNC_Invariant      = 0x00010000,   

	
	FUNC_FuncInherit        = FUNC_Exec | FUNC_Event,
	FUNC_FuncOverrideMatch	= FUNC_Exec | FUNC_Final | FUNC_Latent | FUNC_PreOperator | FUNC_Iterator | FUNC_Static,
	FUNC_NetFuncFlags       = FUNC_Net | FUNC_NetReliable,
};




enum EExprToken
{
	
	EX_LocalVariable		= 0x00,	
	EX_InstanceVariable		= 0x01,	
	EX_DefaultVariable		= 0x02,	

	
	EX_Return				= 0x04,	
	EX_Switch				= 0x05,	
	EX_Jump					= 0x06,	
	EX_JumpIfNot			= 0x07,	
	EX_Stop					= 0x08,	
	EX_Assert				= 0x09,	
	EX_Case					= 0x0A,	
	EX_Nothing				= 0x0B,	
	EX_LabelTable			= 0x0C,	
	EX_GotoLabel			= 0x0D,	
	EX_EatString            = 0x0E, 
	EX_Let					= 0x0F,	
	EX_DynArrayElement      = 0x10, 
	EX_New                  = 0x11, 
	EX_ClassContext         = 0x12, 
	EX_MetaCast             = 0x13, 
	EX_LetBool				= 0x14, 
	
	EX_EndFunctionParms		= 0x16,	
	EX_Self					= 0x17,	
	EX_Skip					= 0x18,	
	EX_Context				= 0x19,	
	EX_ArrayElement			= 0x1A,	
	EX_VirtualFunction		= 0x1B,	
	EX_FinalFunction		= 0x1C,	
	EX_IntConst				= 0x1D,	
	EX_FloatConst			= 0x1E,	
	EX_StringConst			= 0x1F,	
	EX_ObjectConst		    = 0x20,	
	EX_NameConst			= 0x21,	
	EX_RotationConst		= 0x22,	
	EX_VectorConst			= 0x23,	
	EX_ByteConst			= 0x24,	
	EX_IntZero				= 0x25,	
	EX_IntOne				= 0x26,	
	EX_True					= 0x27,	
	EX_False				= 0x28,	
	EX_NativeParm           = 0x29, 
	EX_NoObject				= 0x2A,	
	EX_IntConstByte			= 0x2C,	
	EX_BoolVariable			= 0x2D,	
	EX_DynamicCast			= 0x2E,	
	EX_Iterator             = 0x2F, 
	EX_IteratorPop          = 0x30, 
	EX_IteratorNext         = 0x31, 
	EX_StructCmpEq          = 0x32,	
	EX_StructCmpNe          = 0x33,	
	EX_UnicodeStringConst   = 0x34, 
	
	EX_StructMember         = 0x36, 
	
	EX_GlobalFunction		= 0x38, 

	
	EX_MinConversion		= 0x39,	
	EX_RotatorToVector		= 0x39,
	EX_ByteToInt			= 0x3A,
	EX_ByteToBool			= 0x3B,
	EX_ByteToFloat			= 0x3C,
	EX_IntToByte			= 0x3D,
	EX_IntToBool			= 0x3E,
	EX_IntToFloat			= 0x3F,
	EX_BoolToByte			= 0x40,
	EX_BoolToInt			= 0x41,
	EX_BoolToFloat			= 0x42,
	EX_FloatToByte			= 0x43,
	EX_FloatToInt			= 0x44,
	EX_FloatToBool			= 0x45,
	
	EX_ObjectToBool			= 0x47,
	EX_NameToBool			= 0x48,
	EX_StringToByte			= 0x49,
	EX_StringToInt			= 0x4A,
	EX_StringToBool			= 0x4B,
	EX_StringToFloat		= 0x4C,
	EX_StringToVector		= 0x4D,
	EX_StringToRotator		= 0x4E,
	EX_VectorToBool			= 0x4F,
	EX_VectorToRotator		= 0x50,
	EX_RotatorToBool		= 0x51,
	EX_ByteToString			= 0x52,
	EX_IntToString			= 0x53,
	EX_BoolToString			= 0x54,
	EX_FloatToString		= 0x55,
	EX_ObjectToString		= 0x56,
	EX_NameToString			= 0x57,
	EX_VectorToString		= 0x58,
	EX_RotatorToString		= 0x59,
	EX_MaxConversion		= 0x60,	

	
	EX_ExtendedNative		= 0x60,
	EX_FirstNative			= 0x70,
	EX_Max					= 0x1000,
};




enum EPollSlowFuncs
{
	EPOLL_Sleep			      = 384,
	EPOLL_FinishAnim	      = 385,
	EPOLL_FinishInterpolation = 302,
};

// Latent action IDs for AController/AAIController poll functions.
// Values from Ghidra: stored at FStateFrame offset 0x28.
enum
{
	AI_PollMoveTo          = 501,
	AI_PollMoveToward      = 503,
	AI_PollFinishRotation  = 509,
	AI_PollWaitToSeeEnemy  = 511,
	AI_PollWaitForLanding  = 528,
};








struct __declspec(dllimport) FFrame : public FOutputDevice
{	
	
	UStruct*	Node;
	UObject*	Object;
	BYTE*		Code;
	BYTE*		Locals;

	
	FFrame( UObject* InObject );
	FFrame( UObject* InObject, UStruct* InNode, INT CodeOffset, void* InLocals );

	
	void Step( UObject* Context, void*const Result );
	void Serialize( const TCHAR* V, enum EName Event );
	INT ReadInt();
	UObject* ReadObject();
	FLOAT ReadFloat();
	INT ReadWord();
	FName ReadName();
};





struct __declspec(dllimport) FStateFrame : public FFrame
{
	
	FFrame* CurrentFrame;
	UState* StateNode;
	QWORD   ProbeMask;
	INT     LatentAction;

	
	FStateFrame( UObject* InObject );
	const TCHAR* Describe();
};








struct FIteratorList
{
	FIteratorList* Next;
	FIteratorList() {}
	FIteratorList( FIteratorList* InNext ) : Next( InNext ) {}
	FIteratorList* GetNext() { return (FIteratorList*)Next; }
};





















enum ELoadFlags
{
	LOAD_None			= 0x0000,	
	LOAD_NoFail			= 0x0001,	
	LOAD_NoWarn			= 0x0002,	
	LOAD_Throw			= 0x0008,	
	LOAD_Verify			= 0x0010,	
	LOAD_AllowDll		= 0x0020,	
	LOAD_DisallowFiles  = 0x0040,	
	LOAD_NoVerify       = 0x0080,   
	LOAD_Forgiving      = 0x1000,   
	LOAD_Quiet			= 0x2000,   
	LOAD_NoRemap        = 0x4000,   
	LOAD_Propagate      = 0,
};




enum EPackageFlags
{
	PKG_AllowDownload	= 0x0001,	
	PKG_ClientOptional  = 0x0002,	
	PKG_ServerSideOnly  = 0x0004,   
	PKG_BrokenLinks     = 0x0008,   
	PKG_Unsecure        = 0x0010,   
	PKG_Need			= 0x8000,	
};




enum ENativeConstructor    {EC_NativeConstructor};
enum EStaticConstructor    {EC_StaticConstructor};
enum EInternal             {EC_Internal};
enum ECppProperty          {EC_CppProperty};
enum EInPlaceConstructor   {EC_InPlaceConstructor};




enum EGotoState
{
	GOTOSTATE_NotFound		= 0,
	GOTOSTATE_Success		= 1,
	GOTOSTATE_Preempted		= 2,
};




enum EClassFlags
{
	
	CLASS_Abstract          = 0x00001,  
	CLASS_Compiled			= 0x00002,  
	CLASS_Config			= 0x00004,  
	CLASS_Transient			= 0x00008,	
	CLASS_Parsed            = 0x00010,	
	CLASS_Localized         = 0x00020,  
	CLASS_SafeReplace       = 0x00040,  
	CLASS_RuntimeStatic     = 0x00080,	
	CLASS_NoExport          = 0x00100,  
	CLASS_NoUserCreate      = 0x00200,  
	CLASS_PerObjectConfig   = 0x00400,  
	CLASS_NativeReplication = 0x00800,  

 	
	CLASS_EditInlineNew 	 = 0x01000,
	CLASS_CollapseCategories = 0x02000,
	CLASS_ExportStructs	 = 0x04000,

	
	CLASS_Inherit           = CLASS_Transient | CLASS_Config | CLASS_Localized | CLASS_SafeReplace | CLASS_RuntimeStatic | CLASS_PerObjectConfig,
	CLASS_RecompilerClear   = CLASS_Inherit | CLASS_Abstract | CLASS_NoExport | CLASS_NativeReplication,
};





enum EPropertyFlags
{
	
	CPF_Edit		 = 0x00000001, 
	CPF_Const		 = 0x00000002, 
	CPF_Input		 = 0x00000004, 
	CPF_ExportObject = 0x00000008, 
	CPF_OptionalParm = 0x00000010, 
	CPF_Net			 = 0x00000020, 
	CPF_ConstRef     = 0x00000040, 
	CPF_Parm		 = 0x00000080, 
	CPF_OutParm		 = 0x00000100, 
	CPF_SkipParm	 = 0x00000200, 
	CPF_ReturnParm	 = 0x00000400, 
	CPF_CoerceParm	 = 0x00000800, 
	CPF_Native       = 0x00001000, 
	CPF_Transient    = 0x00002000, 
	CPF_Config       = 0x00004000, 
	CPF_Localized    = 0x00008000, 
	CPF_Travel       = 0x00010000, 
	CPF_EditConst    = 0x00020000, 
	CPF_GlobalConfig = 0x00040000, 
	CPF_OnDemand     = 0x00100000, 
	CPF_New			= 0x00200000, 
	CPF_NeedCtorLink 	= 0x00400000, 

	
	CPF_EditorData 	 	= 0x02000000,           
	CPF_EditInline	 	= 0x04000000,
	CPF_EditInlineUse	= 0x14000000,
	CPF_Deprecated	 	= 0x20000000,

	
	CPF_ParmFlags           = CPF_OptionalParm | CPF_Parm | CPF_OutParm | CPF_SkipParm | CPF_ReturnParm | CPF_CoerceParm,
	CPF_PropagateFromStruct = CPF_Const | CPF_Native | CPF_Transient,
};




enum EObjectFlags
{
	RF_Transactional    = 0x00000001,   
	RF_Unreachable		= 0x00000002,	
	RF_Public			= 0x00000004,	
	RF_TagImp			= 0x00000008,	
	RF_TagExp			= 0x00000010,	
	RF_SourceModified   = 0x00000020,   
	RF_TagGarbage		= 0x00000040,	
	
	
	RF_NeedLoad			= 0x00000200,   
	RF_HighlightedName  = 0x00000400,	
	RF_EliminateObject  = 0x00000400,   
	RF_InSingularFunc   = 0x00000800,	
	RF_RemappedName     = 0x00000800,   
	RF_Suppress         = 0x00001000,	
	RF_StateChanged     = 0x00001000,   
	RF_InEndState       = 0x00002000,   
	RF_Transient        = 0x00004000,	
	RF_Preloading       = 0x00008000,   
	RF_LoadForClient	= 0x00010000,	
	RF_LoadForServer	= 0x00020000,	
	RF_LoadForEdit		= 0x00040000,	
	RF_Standalone       = 0x00080000,   
	RF_NotForClient		= 0x00100000,	
	RF_NotForServer		= 0x00200000,	
	RF_NotForEdit		= 0x00400000,	
	RF_Destroyed        = 0x00800000,	
	RF_NeedPostLoad		= 0x01000000,   
	RF_HasStack         = 0x02000000,	
	RF_Native			= 0x04000000,   
	RF_Marked			= 0x08000000,   
	RF_ErrorShutdown    = 0x10000000,	
	RF_DebugPostLoad    = 0x20000000,   
	RF_DebugSerialize   = 0x40000000,   
	RF_DebugDestroy     = 0x80000000,   
	RF_ContextFlags		= RF_NotForClient | RF_NotForServer | RF_NotForEdit, 
	RF_LoadContextFlags	= RF_LoadForClient | RF_LoadForServer | RF_LoadForEdit, 
	RF_Load  			= RF_ContextFlags | RF_LoadContextFlags | RF_Public | RF_Standalone | RF_Native | RF_SourceModified | RF_Transactional | RF_HasStack, 
	RF_Keep             = RF_Native | RF_Marked, 
	RF_ScriptMask		= RF_Transactional | RF_Public | RF_Transient | RF_NotForClient | RF_NotForServer | RF_NotForEdit 
};





struct __declspec(dllimport) FScriptDelegate
{
public:
   FScriptDelegate();
   struct FScriptDelegate & operator=(struct FScriptDelegate const &);
};




class __declspec(dllimport) FGuid
{
public:
	DWORD A,B,C,D;
	FGuid()
	{}
	FGuid( DWORD InA, DWORD InB, DWORD InC, DWORD InD )
	: A(InA), B(InB), C(InC), D(InD)
	{}
	friend UBOOL operator==(const FGuid& X, const FGuid& Y)
		{return X.A==Y.A && X.B==Y.B && X.C==Y.C && X.D==Y.D;}
	friend UBOOL operator!=(const FGuid& X, const FGuid& Y)
		{return X.A!=Y.A || X.B!=Y.B || X.C!=Y.C || X.D!=Y.D;}
	friend FArchive& operator<<( FArchive& Ar, FGuid& G )
	{
		{static const TCHAR __FUNC_NAME__[]=L"FGuid<<"; try{;
		return Ar << G.A << G.B << G.C << G.D;
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
	TCHAR* String() const
	{
		TCHAR* Result = appStaticString1024();
		appSprintf( Result, L"%08X%08X%08X%08X", A, B, C, D );
		return Result;
	}
};
inline INT CompareGuids( FGuid* A, FGuid* B )
{
	INT Diff;
	Diff = A->A-B->A; if( Diff ) return Diff;
	Diff = A->B-B->B; if( Diff ) return Diff;
	Diff = A->C-B->C; if( Diff ) return Diff;
	Diff = A->D-B->D; if( Diff ) return Diff;
	return 0;
}




class __declspec(dllimport) FUnknown
{
public:
	virtual DWORD __stdcall QueryInterface( const FGuid& RefIID, void** InterfacePtr ) {return 0;}
	virtual DWORD __stdcall AddRef() {return 0;}
	virtual DWORD __stdcall Release() {return 0;}
};




class __declspec(dllimport) FRegistryObjectInfo
{
public:
	FString Object;
	FString Class;
	FString MetaClass;
	FString Description;
	FString Autodetect;
	FRegistryObjectInfo()
	: Object(), Class(), MetaClass(), Description(), Autodetect()
	{}
};




class __declspec(dllimport) FPreferencesInfo
{
public:
	FString Caption;
	FString ParentCaption;
	FString Class;
	FName Category;
	UBOOL Immediate;
	FPreferencesInfo()
	: Caption(), ParentCaption(), Class(), Category(NAME_None), Immediate(0)
	{}
};































































































	











































































	
















class __declspec(dllimport) UObject : public FUnknown
{
	typedef UObject WithinClass;
	enum {GUID1=0,GUID2=0,GUID3=0,GUID4=0};
	
	friend class FObjectIterator;
	friend class ULinkerLoad;
	friend class ULinkerSave;
	friend class UPackageMap;
	friend class FArchiveTagUsed;
	friend struct FObjectImport;
	friend struct FObjectExport;

public:
	INT			Index;				
	UObject*		HashNext;			
	FStateFrame*		StateFrame;			
	ULinkerLoad*		_Linker;			
	INT			_LinkerIndex;		
	class UObject* Outer;                                                     
	INT ObjectFlags;                                                          
	FName* Name;                                                              
	class UClass* Class;                                                      
	INT DName; 

	virtual DWORD __stdcall QueryInterface(class FGuid const &, void * *);
	virtual DWORD __stdcall AddRef();
	virtual DWORD __stdcall Release();
	virtual ~UObject();
	virtual void ProcessEvent(class UFunction *, void *, void *);
	virtual void ProcessDelegate(class FName, struct FScriptDelegate *, void *, void *);
	virtual void ProcessState(FLOAT);
	virtual INT ProcessRemoteFunction(class UFunction *, void *, struct FFrame *);
	virtual void Modify();
	virtual void PostLoad();
	virtual void Destroy();
	virtual void Serialize(class FArchive &);
	virtual INT IsPendingDelete();
	virtual INT IsPendingKill();
	virtual enum EGotoState GotoState(class FName);
	virtual INT GotoLabel(class FName);
	virtual void InitExecution();
	virtual void ShutdownAfterError();
	virtual void PostEditChange();
	virtual void CallFunction(struct FFrame &, void * const, class UFunction *);
	virtual INT ScriptConsoleExec(TCHAR const *, class FOutputDevice &, class UObject *);
	virtual void Register();
	virtual void LanguageChange();
	virtual INT GetPropertiesSize();
	virtual void NetDirty(class UProperty *);

	void AddToRoot();
	static INT __cdecl AttemptDelete(class UObject * &, DWORD, INT);
	static void __cdecl BeginLoad();
	static void __cdecl BindPackage(class UPackage *);
	static void __cdecl CheckDanglingOuter(class UObject *);
	static void __cdecl CheckDanglingRefs(class UObject *);
	void ClearFlags(DWORD);
	static void __cdecl CollectGarbage(DWORD);
	INT ConditionalDestroy();
	void ConditionalPostLoad();
	void ConditionalRegister();
	void ConditionalShutdownAfterError();
	static class UPackage * __cdecl CreatePackage(class UObject *, TCHAR const *);
	static void __cdecl EndLoad();
	static void __cdecl ExitProperties(BYTE *, class UClass *);
	static void __cdecl ExportProperties(class FOutputDevice &, class UClass *, BYTE *, INT, class UClass *, BYTE *);
	INT FindArrayProperty(class FString, class FArray * *, INT *);
	INT FindBoolProperty(class FString, INT *);
	INT FindFNameProperty(class FString, class FName *);
	INT FindFloatProperty(class FString, FLOAT *);
	class UFunction * FindFunction(class FName, INT);
	class UFunction * FindFunctionChecked(class FName, INT);
	INT FindIntProperty(class FString, INT *);
	class UField * FindObjectField(class FName, INT);
	INT FindObjectProperty(class FString, class UObject * *);
	class UState * FindState(class FName);
	INT FindStructProperty(class FString, class UStruct * *);
	class UClass * GetClass() const;
	class FName const GetFName() const;
	DWORD GetFlags() const;
	TCHAR const * GetFullName( TCHAR* Str=0 ) const;
	DWORD GetIndex() const;
	static class UObject * __cdecl GetIndexedObject(INT);
	static INT __cdecl GetInitialized();
	static TCHAR const * __cdecl GetLanguage();
	class ULinkerLoad * GetLinker();
	INT GetLinkerIndex();
	static class TArray<class UObject *> __cdecl GetLoaderList();
	TCHAR const * GetName() const;
	static INT __cdecl GetObjectHash(class FName, INT);
	class UObject * GetOuter() const;
	static class ULinkerLoad * __cdecl GetPackageLinker(class UObject *, TCHAR const *, DWORD, class UPackageMap *, class FGuid *);
	TCHAR const * GetPathName(class UObject *, TCHAR *) const;
	static void __cdecl GetPreferences(class TArray<class FPreferencesInfo> &, TCHAR const *, INT);
	static void __cdecl GetRegistryObjects(class TArray<class FRegistryObjectInfo> &, class UClass *, class UClass *, INT);
	struct FStateFrame * GetStateFrame();
	static class UPackage * __cdecl GetTransientPackage();
	static void __cdecl GlobalSetProperty(TCHAR const *, class UClass *, class UProperty *, INT, INT);
	void InitClassDefaultObject(class UClass *, INT);
	static void __cdecl InitProperties(BYTE *, INT, class UClass *, BYTE *, INT, class UObject *, class UObject *);
	static void __cdecl InternalConstructor(void *);
	INT IsA(class UClass *) const;
	INT IsIn(class UObject *) const;
	INT IsInState(class FName);
	INT IsProbing(class FName);
	static INT __cdecl IsReferenced(class UObject * &, DWORD, INT);
	INT IsValid();
	void LoadConfig(INT, class UClass *, TCHAR const *);
	void LoadLocalized();
	static class UObject * __cdecl LoadPackage(class UObject *, TCHAR const *, DWORD);
	void ParseParms(TCHAR const *);
	void ProcessInternal(struct FFrame &, void * const);
	static void __cdecl ProcessRegistrants();
	void RemoveFromRoot();
	static void __cdecl ResetConfig(class UClass *);
	static void __cdecl ResetLoaders(class UObject *, INT, INT);
	void SaveConfig(DWORD, TCHAR const *);
	static INT __cdecl SavePackage(class UObject *, class UObject *, DWORD, TCHAR const *, class FOutputDevice *, class ULinkerLoad *);
	static void __cdecl SerializeRootSet(class FArchive &, DWORD, DWORD);
	void SetClass(class UClass *);
	void SetFlags(DWORD);
	static void __cdecl SetLanguage(TCHAR const *);
	
	static       UObject *       StaticAllocateObject(      UClass * Class, UObject * InOuter=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0, UObject * Template=0, FOutputDevice* Error=GError, UObject * Ptr=0 );
	static class UClass * __cdecl StaticClass();
	static TCHAR const * __cdecl StaticConfigName();
	static class UObject * __cdecl StaticConstructObject(class UClass *, class UObject *, class FName, DWORD, class UObject *, class FOutputDevice *, class UObject *);
	void StaticConstructor();
	static INT __cdecl StaticExec(TCHAR const *, class FOutputDevice &);
	static void __cdecl StaticExit();
	static class UObject * __cdecl StaticFindObject(class UClass *, class UObject *, TCHAR const *, INT);
	static class UObject * __cdecl StaticFindObjectChecked(class UClass *, class UObject *, TCHAR const *, INT);
	static void __cdecl StaticInit();
	static class UClass * __cdecl StaticLoadClass(class UClass *, class UObject *, TCHAR const *, TCHAR const *, DWORD, class UPackageMap *);
	static class UObject * __cdecl StaticLoadObject(class UClass *, class UObject *, TCHAR const *, TCHAR const *, DWORD, class UPackageMap *);
	static void __cdecl StaticShutdownAfterError();
	static void __cdecl StaticTick();
	UObject(class UObject const &);
	UObject(enum EInPlaceConstructor, class UClass *, class UObject *, class FName, DWORD);
	UObject(enum ENativeConstructor, class UClass *, TCHAR const *, TCHAR const *, DWORD);
	UObject(enum EStaticConstructor, TCHAR const *, TCHAR const *, DWORD);
	UObject();
	static void __cdecl VerifyLinker(class ULinkerLoad *);
	void eventBeginState();
	void eventEndState();
	void execAbs(struct FFrame &, void * const);
	void execAcos(struct FFrame &, void * const);
	void execAddAdd_Byte(struct FFrame &, void * const);
	void execAddAdd_Int(struct FFrame &, void * const);
	void execAddAdd_PreByte(struct FFrame &, void * const);
	void execAddAdd_PreInt(struct FFrame &, void * const);
	void execAddEqual_ByteByte(struct FFrame &, void * const);
	void execAddEqual_FloatFloat(struct FFrame &, void * const);
	void execAddEqual_IntInt(struct FFrame &, void * const);
	void execAddEqual_RotatorRotator(struct FFrame &, void * const);
	void execAddEqual_VectorVector(struct FFrame &, void * const);
	void execAdd_FloatFloat(struct FFrame &, void * const);
	void execAdd_IntInt(struct FFrame &, void * const);
	void execAdd_RotatorRotator(struct FFrame &, void * const);
	void execAdd_VectorVector(struct FFrame &, void * const);
	void execAndAnd_BoolBool(struct FFrame &, void * const);
	void execAnd_IntInt(struct FFrame &, void * const);
	void execArrayElement(struct FFrame &, void * const);
	void execAsc(struct FFrame &, void * const);
	void execAsin(struct FFrame &, void * const);
	void execAssert(struct FFrame &, void * const);
	void execAt_StringString(struct FFrame &, void * const);
	void execAtan(struct FFrame &, void * const);
	void execBoolToByte(struct FFrame &, void * const);
	void execBoolToFloat(struct FFrame &, void * const);
	void execBoolToInt(struct FFrame &, void * const);
	void execBoolToString(struct FFrame &, void * const);
	void execBoolVariable(struct FFrame &, void * const);
	void execByteConst(struct FFrame &, void * const);
	void execByteToBool(struct FFrame &, void * const);
	void execByteToFloat(struct FFrame &, void * const);
	void execByteToInt(struct FFrame &, void * const);
	void execByteToString(struct FFrame &, void * const);
	void execCalcDirection(struct FFrame &, void * const);
	void execCalcRotation(struct FFrame &, void * const);
	void execCaps(struct FFrame &, void * const);
	void execCase(struct FFrame &, void * const);
	void execCeil(struct FFrame &, void * const);
	void execChr(struct FFrame &, void * const);
	void execClamp(struct FFrame &, void * const);
	void execClassContext(struct FFrame &, void * const);
	void execClassIsChildOf(struct FFrame &, void * const);
	void execClockwiseFrom_IntInt(struct FFrame &, void * const);
	void execComplementEqual_FloatFloat(struct FFrame &, void * const);
	void execComplementEqual_StringString(struct FFrame &, void * const);
	void execComplement_PreInt(struct FFrame &, void * const);
	void execCompress(struct FFrame &, void * const);
	void execConcat_StringString(struct FFrame &, void * const);
	void execContext(struct FFrame &, void * const);
	void execCos(struct FFrame &, void * const);
	void execCross_VectorVector(struct FFrame &, void * const);
	void execDebugInfo(struct FFrame &, void * const);
	void execDefaultVariable(struct FFrame &, void * const);
	void execDelegateFunction(struct FFrame &, void * const);
	void execDelegateProperty(struct FFrame &, void * const);
	void execDisable(struct FFrame &, void * const);
	void execDivideEqual_ByteByte(struct FFrame &, void * const);
	void execDivideEqual_FloatFloat(struct FFrame &, void * const);
	void execDivideEqual_IntFloat(struct FFrame &, void * const);
	void execDivideEqual_RotatorFloat(struct FFrame &, void * const);
	void execDivideEqual_VectorFloat(struct FFrame &, void * const);
	void execDivide_FloatFloat(struct FFrame &, void * const);
	void execDivide_IntInt(struct FFrame &, void * const);
	void execDivide_RotatorFloat(struct FFrame &, void * const);
	void execDivide_VectorFloat(struct FFrame &, void * const);
	void execDot_VectorVector(struct FFrame &, void * const);
	void execDynArrayElement(struct FFrame &, void * const);
	void execDynArrayInsert(struct FFrame &, void * const);
	void execDynArrayLength(struct FFrame &, void * const);
	void execDynArrayRemove(struct FFrame &, void * const);
	void execDynamicCast(struct FFrame &, void * const);
	void execDynamicLoadObject(struct FFrame &, void * const);
	void execEatString(struct FFrame &, void * const);
	void execEnable(struct FFrame &, void * const);
	void execEndFunctionParms(struct FFrame &, void * const);
	void execEqualEqual_BoolBool(struct FFrame &, void * const);
	void execEqualEqual_FloatFloat(struct FFrame &, void * const);
	void execEqualEqual_IntInt(struct FFrame &, void * const);
	void execEqualEqual_NameName(struct FFrame &, void * const);
	void execEqualEqual_ObjectObject(struct FFrame &, void * const);
	void execEqualEqual_RotatorRotator(struct FFrame &, void * const);
	void execEqualEqual_StringString(struct FFrame &, void * const);
	void execEqualEqual_VectorVector(struct FFrame &, void * const);
	void execExp(struct FFrame &, void * const);
	void execExpand(struct FFrame &, void * const);
	void execFClamp(struct FFrame &, void * const);
	void execFClose(struct FFrame &, void * const);
	void execFLoad(struct FFrame &, void * const);
	void execFMax(struct FFrame &, void * const);
	void execFMin(struct FFrame &, void * const);
	void execFOpen(struct FFrame &, void * const);
	void execFOpenWrite(struct FFrame &, void * const);
	void execFRand(struct FFrame &, void * const);
	void execFReadLine(struct FFrame &, void * const);
	void execFUnload(struct FFrame &, void * const);
	void execFWrite(struct FFrame &, void * const);
	void execFWriteLine(struct FFrame &, void * const);
	void execFalse(struct FFrame &, void * const);
	void execFinalFunction(struct FFrame &, void * const);
	void execFindObject(struct FFrame &, void * const);
	void execFloatConst(struct FFrame &, void * const);
	void execFloatToBool(struct FFrame &, void * const);
	void execFloatToByte(struct FFrame &, void * const);
	void execFloatToInt(struct FFrame &, void * const);
	void execFloatToString(struct FFrame &, void * const);
	void execGetAxes(struct FFrame &, void * const);
	void execGetBaseDir(struct FFrame &, void * const);
	void execGetEnum(struct FFrame &, void * const);
	void execGetInputKeyString(struct FFrame &, void * const);
	void execGetLanguageFilter(struct FFrame &, void * const);
	void execGetMilesOnly(struct FFrame &, void * const);
	void execGetNoBlood(struct FFrame &, void * const);
	void execGetNoSniper(struct FFrame &, void * const);
	void execGetPlatform(struct FFrame &, void * const);
	void execGetPrivateProfileInt(struct FFrame &, void * const);
	void execGetPrivateProfileString(struct FFrame &, void * const);
	void execGetPropertyText(struct FFrame &, void * const);
	void execGetStateName(struct FFrame &, void * const);
	void execGetUnAxes(struct FFrame &, void * const);
	void execGetVersionAGPMajor(struct FFrame &, void * const);
	void execGetVersionAGPMinor(struct FFrame &, void * const);
	void execGetVersionAGPTiny(struct FFrame &, void * const);
	void execGetVersionWarfareEngine(struct FFrame &, void * const);
	void execGlobalFunction(struct FFrame &, void * const);
	void execGotoLabel(struct FFrame &, void * const);
	void execGotoState(struct FFrame &, void * const);
	void execGreaterEqual_FloatFloat(struct FFrame &, void * const);
	void execGreaterEqual_IntInt(struct FFrame &, void * const);
	void execGreaterEqual_StringString(struct FFrame &, void * const);
	void execGreaterGreaterGreater_IntInt(struct FFrame &, void * const);
	void execGreaterGreater_IntInt(struct FFrame &, void * const);
	void execGreaterGreater_VectorRotator(struct FFrame &, void * const);
	void execGreater_FloatFloat(struct FFrame &, void * const);
	void execGreater_IntInt(struct FFrame &, void * const);
	void execGreater_StringString(struct FFrame &, void * const);
	void execHighNative0(struct FFrame &, void * const);
	void execHighNative1(struct FFrame &, void * const);
	void execHighNative10(struct FFrame &, void * const);
	void execHighNative11(struct FFrame &, void * const);
	void execHighNative12(struct FFrame &, void * const);
	void execHighNative13(struct FFrame &, void * const);
	void execHighNative14(struct FFrame &, void * const);
	void execHighNative15(struct FFrame &, void * const);
	void execHighNative2(struct FFrame &, void * const);
	void execHighNative3(struct FFrame &, void * const);
	void execHighNative4(struct FFrame &, void * const);
	void execHighNative5(struct FFrame &, void * const);
	void execHighNative6(struct FFrame &, void * const);
	void execHighNative7(struct FFrame &, void * const);
	void execHighNative8(struct FFrame &, void * const);
	void execHighNative9(struct FFrame &, void * const);
	void execInStr(struct FFrame &, void * const);
	void execInitRotRand(struct FFrame &, void * const);
	void execInstanceVariable(struct FFrame &, void * const);
	void execIntConst(struct FFrame &, void * const);
	void execIntConstByte(struct FFrame &, void * const);
	void execIntOne(struct FFrame &, void * const);
	void execIntToBool(struct FFrame &, void * const);
	void execIntToByte(struct FFrame &, void * const);
	void execIntToFloat(struct FFrame &, void * const);
	void execIntToString(struct FFrame &, void * const);
	void execIntZero(struct FFrame &, void * const);
	void execInterpCurveEval(struct FFrame &, void * const);
	void execInterpCurveGetInputDomain(struct FFrame &, void * const);
	void execInterpCurveGetOutputRange(struct FFrame &, void * const);
	void execInvert(struct FFrame &, void * const);
	void execIsA(struct FFrame &, void * const);
	void execIsDebugBuild(struct FFrame &, void * const);
	void execIsInState(struct FFrame &, void * const);
	void execIterator(struct FFrame &, void * const);
	void execJump(struct FFrame &, void * const);
	void execJumpIfNot(struct FFrame &, void * const);
	void execLeft(struct FFrame &, void * const);
	void execLen(struct FFrame &, void * const);
	void execLerp(struct FFrame &, void * const);
	void execLessEqual_FloatFloat(struct FFrame &, void * const);
	void execLessEqual_IntInt(struct FFrame &, void * const);
	void execLessEqual_StringString(struct FFrame &, void * const);
	void execLessLess_IntInt(struct FFrame &, void * const);
	void execLessLess_VectorRotator(struct FFrame &, void * const);
	void execLess_FloatFloat(struct FFrame &, void * const);
	void execLess_IntInt(struct FFrame &, void * const);
	void execLess_StringString(struct FFrame &, void * const);
	void execLet(struct FFrame &, void * const);
	void execLetBool(struct FFrame &, void * const);
	void execLetDelegate(struct FFrame &, void * const);
	void execLocalVariable(struct FFrame &, void * const);
	void execLocalize(struct FFrame &, void * const);
	void execLocs(struct FFrame &, void * const);
	void execLog(struct FFrame &, void * const);
	void execLogFileClose(struct FFrame &, void * const);
	void execLogFileOpen(struct FFrame &, void * const);
	void execLogFileWrite(struct FFrame &, void * const);
	void execLoge(struct FFrame &, void * const);
	void execMax(struct FFrame &, void * const);
	void execMetaCast(struct FFrame &, void * const);
	void execMid(struct FFrame &, void * const);
	void execMin(struct FFrame &, void * const);
	void execMirrorVectorByNormal(struct FFrame &, void * const);
	void execMultiplyEqual_ByteByte(struct FFrame &, void * const);
	void execMultiplyEqual_FloatFloat(struct FFrame &, void * const);
	void execMultiplyEqual_IntFloat(struct FFrame &, void * const);
	void execMultiplyEqual_RotatorFloat(struct FFrame &, void * const);
	void execMultiplyEqual_VectorFloat(struct FFrame &, void * const);
	void execMultiplyEqual_VectorVector(struct FFrame &, void * const);
	void execMultiplyMultiply_FloatFloat(struct FFrame &, void * const);
	void execMultiply_FloatFloat(struct FFrame &, void * const);
	void execMultiply_FloatRotator(struct FFrame &, void * const);
	void execMultiply_FloatVector(struct FFrame &, void * const);
	void execMultiply_IntInt(struct FFrame &, void * const);
	void execMultiply_RotatorFloat(struct FFrame &, void * const);
	void execMultiply_VectorFloat(struct FFrame &, void * const);
	void execMultiply_VectorVector(struct FFrame &, void * const);
	void execNameConst(struct FFrame &, void * const);
	void execNameToBool(struct FFrame &, void * const);
	void execNameToString(struct FFrame &, void * const);
	void execNativeParm(struct FFrame &, void * const);
	void execNew(struct FFrame &, void * const);
	void execNoObject(struct FFrame &, void * const);
	void execNormal(struct FFrame &, void * const);
	void execNormalize(struct FFrame &, void * const);
	void execNotEqual_BoolBool(struct FFrame &, void * const);
	void execNotEqual_FloatFloat(struct FFrame &, void * const);
	void execNotEqual_IntInt(struct FFrame &, void * const);
	void execNotEqual_NameName(struct FFrame &, void * const);
	void execNotEqual_ObjectObject(struct FFrame &, void * const);
	void execNotEqual_RotatorRotator(struct FFrame &, void * const);
	void execNotEqual_StringString(struct FFrame &, void * const);
	void execNotEqual_VectorVector(struct FFrame &, void * const);
	void execNot_PreBool(struct FFrame &, void * const);
	void execNothing(struct FFrame &, void * const);
	void execObjectConst(struct FFrame &, void * const);
	void execObjectToBool(struct FFrame &, void * const);
	void execObjectToString(struct FFrame &, void * const);
	void execOrOr_BoolBool(struct FFrame &, void * const);
	void execOr_IntInt(struct FFrame &, void * const);
	void execOrthoRotation(struct FFrame &, void * const);
	void execPercent_FloatFloat(struct FFrame &, void * const);
	void execPrimitiveCast(struct FFrame &, void * const);
	void execPrivateSet(struct FFrame &, void * const);
	void execQuatFindBetween(struct FFrame &, void * const);
	void execQuatFromAxisAndAngle(struct FFrame &, void * const);
	void execQuatInvert(struct FFrame &, void * const);
	void execQuatProduct(struct FFrame &, void * const);
	void execQuatRotateVector(struct FFrame &, void * const);
	void execRand(struct FFrame &, void * const);
	void execResetConfig(struct FFrame &, void * const);
	void execRight(struct FFrame &, void * const);
	void execRotRand(struct FFrame &, void * const);
	void execRotationConst(struct FFrame &, void * const);
	void execRotatorToBool(struct FFrame &, void * const);
	void execRotatorToString(struct FFrame &, void * const);
	void execRotatorToVector(struct FFrame &, void * const);
	void execRound(struct FFrame &, void * const);
	void execSaveConfig(struct FFrame &, void * const);
	void execSavePrivateProfile(struct FFrame &, void * const);
	void execSelf(struct FFrame &, void * const);
	void execSetLanguageFilter(struct FFrame &, void * const);
	void execSetMilesOnly(struct FFrame &, void * const);
	void execSetNoBlood(struct FFrame &, void * const);
	void execSetNoSniper(struct FFrame &, void * const);
	void execSetPrivateProfileInt(struct FFrame &, void * const);
	void execSetPrivateProfileString(struct FFrame &, void * const);
	void execSetPropertyText(struct FFrame &, void * const);
	void execSin(struct FFrame &, void * const);
	void execSmerp(struct FFrame &, void * const);
	void execSqrt(struct FFrame &, void * const);
	void execSquare(struct FFrame &, void * const);
	void execStaticSaveConfig(struct FFrame &, void * const);
	void execStop(struct FFrame &, void * const);
	void execStringConst(struct FFrame &, void * const);
	void execStringToBool(struct FFrame &, void * const);
	void execStringToByte(struct FFrame &, void * const);
	void execStringToFloat(struct FFrame &, void * const);
	void execStringToInt(struct FFrame &, void * const);
	void execStringToName(struct FFrame &, void * const);
	void execStringToRotator(struct FFrame &, void * const);
	void execStringToVector(struct FFrame &, void * const);
	void execStructCmpEq(struct FFrame &, void * const);
	void execStructCmpNe(struct FFrame &, void * const);
	void execStructMember(struct FFrame &, void * const);
	void execSubtractEqual_ByteByte(struct FFrame &, void * const);
	void execSubtractEqual_FloatFloat(struct FFrame &, void * const);
	void execSubtractEqual_IntInt(struct FFrame &, void * const);
	void execSubtractEqual_RotatorRotator(struct FFrame &, void * const);
	void execSubtractEqual_VectorVector(struct FFrame &, void * const);
	void execSubtractSubtract_Byte(struct FFrame &, void * const);
	void execSubtractSubtract_Int(struct FFrame &, void * const);
	void execSubtractSubtract_PreByte(struct FFrame &, void * const);
	void execSubtractSubtract_PreInt(struct FFrame &, void * const);
	void execSubtract_FloatFloat(struct FFrame &, void * const);
	void execSubtract_IntInt(struct FFrame &, void * const);
	void execSubtract_PreFloat(struct FFrame &, void * const);
	void execSubtract_PreInt(struct FFrame &, void * const);
	void execSubtract_PreVector(struct FFrame &, void * const);
	void execSubtract_RotatorRotator(struct FFrame &, void * const);
	void execSubtract_VectorVector(struct FFrame &, void * const);
	void execSwitch(struct FFrame &, void * const);
	void execTan(struct FFrame &, void * const);
	void execTrue(struct FFrame &, void * const);
	void execUndefined(struct FFrame &, void * const);
	void execUnicodeStringConst(struct FFrame &, void * const);
	void execVRand(struct FFrame &, void * const);
	void execVSize(struct FFrame &, void * const);
	void execVSizeSquared(struct FFrame &, void * const);
	void execVectorConst(struct FFrame &, void * const);
	void execVectorToBool(struct FFrame &, void * const);
	void execVectorToRotator(struct FFrame &, void * const);
	void execVectorToString(struct FFrame &, void * const);
	void execVirtualFunction(struct FFrame &, void * const);
	void execWarn(struct FFrame &, void * const);
	void execXorXor_BoolBool(struct FFrame &, void * const);
	void execXor_IntInt(struct FFrame &, void * const);
	static void __cdecl operator delete(void *, unsigned int);
	static void * __cdecl operator new(unsigned int, class UObject *, class FName, DWORD);
	static void * __cdecl operator new(unsigned int, enum EInternal *);
	class UObject & operator=(class UObject const &);
private:
	void AddObject(INT);
	static void __cdecl CacheDrivers(INT);
	static class UObject * GAutoRegister();
	static INT GImportCount();
	static TCHAR * GLanguage();
	static class TArray<int> GObjAvailable();
	static INT GObjBeginLoadCount();
	static TCHAR * GObjCachedLanguage();
	static class TArray<class FRegistryObjectInfo> GObjDrivers();
	static class UObject * * GObjHash();
	static INT GObjInitialized();
	static class TArray<class UObject *> GObjLoaded();
	static class TArray<class UObject *> GObjLoaders();
	static INT GObjNoRegister();
	static class TArray<class UObject *> GObjObjects;
	static class TMultiMap<class FName,class FName> * GObjPackageRemap();
	static class TArray<class FPreferencesInfo> GObjPreferences();
	static INT GObjRegisterCount();
	static class TArray<class UObject *> GObjRegistrants();
	static class TArray<class UObject *> GObjRoot();
	static class UPackage * GObjTransientPkg();
	static class ULinkerLoad * __cdecl GetLoader(INT);
	void HashObject();
	static class FName __cdecl MakeUniqueObjectName(class UObject *, class UClass *);
	static class UClass PrivateStaticClass();
	static void __cdecl PurgeGarbage();
	static INT __cdecl ResolveName(class UObject * &, TCHAR const * &, INT, INT);
	static void __cdecl SafeLoadError(DWORD, TCHAR const *, TCHAR const *, ...);
	void SetLinker(class ULinkerLoad *, INT);
	void UnhashObject(INT);

	


















































































































































































































































































































































































































































































































};






inline DWORD GetTypeHash( const UObject* A )
{
	return A ? A->GetIndex() : 0;
}


template< class T > UBOOL ParseObject( const TCHAR* Stream, const TCHAR* Match, T*& Obj, UObject* Outer )
{
	return ParseObject( Stream, Match, T::StaticClass(), *(UObject **)&Obj, Outer );
}


template< class T > T* FindObject( UObject* Outer, const TCHAR* Name, UBOOL ExactClass=0 )
{
	return (T*)UObject::StaticFindObject( T::StaticClass(), Outer, Name, ExactClass );
}


template< class T > T* FindObjectChecked( UObject* Outer, const TCHAR* Name, UBOOL ExactClass=0 )
{
	return (T*)UObject::StaticFindObjectChecked( T::StaticClass(), Outer, Name, ExactClass );
}


template< class T > T* Cast( UObject* Src )
{
	return Src && Src->IsA(T::StaticClass()) ? (T*)Src : 0;
}
template< class T, class U > T* CastChecked( U* Src )
{
	if( !Src || !Src->IsA(T::StaticClass()) )
		GError->Logf( L"Cast of %s to %s failed", Src ? Src->GetFullName() : L"NULL", T::StaticClass()->GetName() );
	return (T*)Src;
}


template< class T > T* ConstructObject( UClass* Class, UObject* Outer=(UObject*)-1, FName Name=NAME_None, DWORD SetFlags=0,UObject * Template=0 ,FOutputDevice * Error=GError ,UObject * Z=0)
{
	{if(!(Class->IsChildOf(T::StaticClass()))) appFailAssert( "Class->IsChildOf(T::StaticClass())", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnObjBas.h", 1500 );};
	if( Outer==(UObject*)-1 )
		Outer = UObject::GetTransientPackage();
	return (T*)UObject::StaticConstructObject( Class, Outer, Name, SetFlags, Template, Error, Z );
}


template< class T > T* LoadObject( UObject* Outer, const TCHAR* Name, const TCHAR* Filename, DWORD LoadFlags, UPackageMap* Sandbox )
{
	return (T*)UObject::StaticLoadObject( T::StaticClass(), Outer, Name, Filename, LoadFlags, Sandbox );
}


template< class T > UClass* LoadClass( UObject* Outer, const TCHAR* Name, const TCHAR* Filename, DWORD LoadFlags, UPackageMap* Sandbox )
{
	return UObject::StaticLoadClass( T::StaticClass(), Outer, Name, Filename, LoadFlags, Sandbox );
}


template< class T > T* GetDefault()
{
	return (T*)&T::StaticClass()->Defaults(0);
}








class FObjectIterator
{
public:
	FObjectIterator( UClass* InClass=UObject::StaticClass() )
	:	Class( InClass ), Index( -1 )
	{
		{if(!(Class)) appFailAssert( "Class", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnObjBas.h", 1537 );};
		++*this;
	}
	void operator++()
	{
		while( ++Index<UObject::GObjObjects.Num() && (!UObject::GObjObjects(Index) || !UObject::GObjObjects(Index)->IsA(Class)) );
	}
	UObject* operator*()
	{
		return UObject::GObjObjects(Index);
	}
	UObject* operator->()
	{
		return UObject::GObjObjects(Index);
	}
	operator UBOOL()
	{
		return Index<UObject::GObjObjects.Num();
	}
protected:
	UClass* Class;
	INT Index;
};





template< class T > class TObjectIterator : public FObjectIterator
{
public:
	TObjectIterator()
	:	FObjectIterator( T::StaticClass() )
	{}
	T* operator* ()
	{
		return (T*)FObjectIterator::operator*();
	}
	T* operator-> ()
	{
		return (T*)FObjectIterator::operator->();
	}
};



















































class __declspec(dllimport) FFieldNetCache
{
public:
	UField* Field;
	INT FieldNetIndex;
	INT ConditionIndex;
	FFieldNetCache()
	{}
	FFieldNetCache( UField* InField, INT InFieldNetIndex, INT InConditionIndex )
	: Field(InField), FieldNetIndex(InFieldNetIndex), ConditionIndex(InConditionIndex)
	{}
	friend __declspec(dllimport) FArchive& operator<<( FArchive& Ar, FFieldNetCache& F );
};




class __declspec(dllimport) FClassNetCache
{
	friend class UPackageMap;
public:
	FClassNetCache();
	FClassNetCache( UClass* Class );
	INT GetMaxIndex()
	{
		return FieldsBase+Fields.Num();
	}
	INT FClassNetCache::GetRepConditionCount()
	{
		return RepConditionCount;
	}
	FFieldNetCache* GetFromField( UObject* Field )
	{
		{;
		FFieldNetCache* Result=0;
		for( FClassNetCache* C=this; C; C=C->Super )
			if( (Result=C->FieldMap.FindRef(Field))!=0 )
				break;
		return Result;
		};
	}
	FFieldNetCache* GetFromIndex( INT Index )
	{
		{;
		for( FClassNetCache* C=this; C; C=C->Super )
			if( Index>=C->FieldsBase && Index<C->FieldsBase+C->Fields.Num() )
				return &C->Fields(Index-C->FieldsBase);
		return 0;
		};
	}
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FClassNetCache& Cache );
	TArray<FFieldNetCache*> RepProperties;
private:
	INT FieldsBase;
	FClassNetCache* Super;
	INT RepConditionCount;
	UClass* Class;
	TArray<FFieldNetCache> Fields;
	TMap<UObject*,FFieldNetCache*> FieldMap;
};




class __declspec(dllimport) FPackageInfo
{
public:
	
	FString			URL;				
	ULinkerLoad*	Linker;				
	UObject*		Parent;				
	FGuid			Guid;				
	INT				FileSize;			
	INT				ObjectBase;			
	INT				ObjectCount;		
	INT				NameBase;			
	INT				NameCount;			
	INT				LocalGeneration;	
	INT				RemoteGeneration;	
	DWORD			PackageFlags;		

	
	FPackageInfo( ULinkerLoad* InLinker=0 );
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FPackageInfo& I );
};




class __declspec(dllimport) UPackageMap : public UObject
{
	public: enum {StaticClassFlags=CLASS_Transient}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UPackageMap ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPackageMap*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPackageMap() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPackageMap(); };

	
	void Serialize( FArchive& Ar );
	void Destroy();

	
	virtual UBOOL CanSerializeObject( UObject* Obj );
	virtual UBOOL SerializeObject( FArchive& Ar, UClass* Class, UObject*& Obj );
	virtual UBOOL SerializeName( FArchive& Ar, FName& Name );
	virtual INT ObjectToIndex( UObject* Object );
	virtual UObject* IndexToObject( INT Index, UBOOL Load );
	virtual INT AddLinker( ULinkerLoad* Linker );
	virtual void Compute();
	virtual INT GetMaxObjectIndex() {return MaxObjectIndex;}
	virtual FClassNetCache* GetClassNetCache( UClass* Class );
	virtual UBOOL SupportsPackage( UObject* InOuter );
	void Copy( UPackageMap* Other );
	void CopyLinkers( UPackageMap* Other );

	
	TArray<FPackageInfo> List;
protected:
	TMap<UObject*,INT> LinkerMap;
	TMap<UObject*,FClassNetCache*> ClassFieldIndices;
	TArray<INT> NameIndices;
	DWORD MaxObjectIndex;
	DWORD MaxNameIndex;
};
inline FArchive& operator<<( FArchive& Ar, FClassNetCache* )
{
	return Ar;
}




struct FPropertyRetirement
{
	INT			InPacketId;		
	INT			OutPacketId;	
	BYTE		Reliable;		
	FPropertyRetirement()
	:	OutPacketId	( INDEX_NONE )
	,	InPacketId	( INDEX_NONE )
	{}
};


















class __declspec(dllimport) UPackage : public UObject
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UPackage ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPackage*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPackage() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPackage(); }

	
	void* DllHandle;
	UBOOL AttemptedBind;
	DWORD PackageFlags;

	
	UPackage();

	
	void Destroy();
	void Serialize( FArchive& Ar );

	
	void* GetDllExport( const TCHAR* ExportName, UBOOL Checked );
};








class __declspec(dllimport) USubsystem : public UObject, public FExec
{
	public: enum {StaticClassFlags=CLASS_Transient | CLASS_Abstract}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef USubsystem ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, USubsystem*& Res ) { return Ar << *(UObject**)&Res; } virtual ~USubsystem() { ConditionalDestroy(); }
	protected: USubsystem() {} public:

	
	virtual void Tick( FLOAT DeltaTime )
	{}
};








struct UCommandlet_eventMain_Parms
{
	FString InParms;
	INT ReturnValue;
};
class __declspec(dllimport) UCommandlet : public UObject
{
public:
	class FString HelpCmd;                                                    
	class FString HelpOneLiner;                                               
	class FString HelpUsage;                                                  
	class FString HelpWebLink;                                                
	class FString HelpParm[16];                                               
	class FString HelpDesc[16];                                               
	BITFIELD LogToStdout : 1;                                                 
	BITFIELD IsServer : 1;                                                    
	BITFIELD IsClient : 1;                                                    
	BITFIELD IsEditor : 1;                                                    
	BITFIELD LazyLoad : 1;                                                    
	BITFIELD ShowErrorCount : 1;                                              
	BITFIELD ShowBanner : 1;                                                  
	virtual ~UCommandlet();
	virtual INT Main(TCHAR const *);
	static void __cdecl InternalConstructor(void *);
	static class UClass * __cdecl StaticClass();
	UCommandlet(class UCommandlet const &);
	UCommandlet();
	INT eventMain(class FString const &);
	void execMain(struct FFrame &, void * const);
	static void * __cdecl operator new(unsigned int, class UObject *, class FName, DWORD);
	static void * __cdecl operator new(unsigned int, enum EInternal *);
	class UCommandlet & operator=(class UCommandlet const &);
private:
	static class UClass PrivateStaticClass();






















};








class __declspec(dllimport) ULanguage : public UObject
{
	public: enum {StaticClassFlags=CLASS_Transient | CLASS_Abstract}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef ULanguage ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ULanguage*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ULanguage() { ConditionalDestroy(); }
	protected: ULanguage() {} public:
	ULanguage* SuperLanguage;
};









class __declspec(dllimport) UTextBuffer : public UObject, public FOutputDevice
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UTextBuffer ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTextBuffer*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTextBuffer() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTextBuffer(); }

	
	INT Pos, Top;
	FString Text;

	
	UTextBuffer( const TCHAR* Str=L"" );

	
	void Serialize( FArchive& Ar );

	
	void Serialize( const TCHAR* Data, EName Event );
};





class __declspec(dllimport) USystem : public USubsystem
{
	public: enum {StaticClassFlags=CLASS_Config}; private: static UClass PrivateStaticClass; public: typedef USubsystem Super; typedef USystem ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, USystem*& Res ) { return Ar << *(UObject**)&Res; } virtual ~USystem() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )USystem(); }

	

	
	
	
	
	
	
	INT LicenseeMode; 

	INT PurgeCacheDays;
	FString SavePath;
	FString CachePath;
	FString CacheExt;
	TArray<FString> Paths;
	TArray<FName> Suppress;

	
	void StaticConstructor();
	USystem();

	
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar=*GLog );
};



















enum {PROPERTY_ALIGNMENT=4 };








struct FRepRecord
{
	UProperty* Property;
	INT Index;
	FRepRecord(UProperty* InProperty,INT InIndex)
	: Property(InProperty), Index(InIndex)
	{}
};








class __declspec(dllimport) FDependency
{
public:
	
	UClass*		Class;
	UBOOL		Deep;
	DWORD		ScriptTextCRC;

	
	FDependency();
	FDependency( UClass* InClass, UBOOL InDeep );
	UBOOL IsUpToDate();
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FDependency& Dep );
};








class FRepLink
{
public:
	UProperty*	Property;		
	FRepLink*	Next;			
	FRepLink( UProperty* InProperty, FRepLink* InNext )
	:	Property	(InProperty)
	,	Next		(InNext)
	{}
};








struct __declspec(dllimport) FLabelEntry
{
	
	FName	Name;
	INT		iCode;

	
	FLabelEntry( FName InName, INT iInCode );
	__declspec(dllimport) friend FArchive& operator<<( FArchive& Ar, FLabelEntry &Label );
};








class __declspec(dllimport) UField : public UObject
{
	public: enum {StaticClassFlags=0 | CLASS_Abstract}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UField ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UField*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UField() { ConditionalDestroy(); }
	protected: UField() {} public:

	
	enum {HASH_COUNT = 256};

	
	UField*			SuperField;

	UField*			Next;
	UField*			HashNext;



	
	UField( ENativeConstructor, UClass* InClass, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UField* InSuperField );
	UField( EStaticConstructor, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags );
	UField( UField* InSuperField );

	
	void Serialize( FArchive& Ar );
	void PostLoad();
	void Register();

	
	virtual void AddCppProperty( UProperty* Property );
	virtual UBOOL MergeBools();
	virtual void Bind();
	virtual UClass* GetOwnerClass();
	virtual INT GetPropertiesSize();
};








template <class T> class TFieldIterator
{
public:
	TFieldIterator( UStruct* InStruct )
	: Struct( InStruct )
	, Field( InStruct ? InStruct->Children : 0 )
	{
		IterateToNext();
	}
	operator UBOOL()
	{
		return Field != 0;
	}
	void operator++()
	{
		;
		Field = Field->Next;
		IterateToNext();
	}
	T* operator*()
	{
		;
		return (T*)Field;
	}
	T* operator->()
	{
		;
		return (T*)Field;
	}
	UStruct* GetStruct()
	{
		return Struct;
	}
protected:
	void IterateToNext()
	{
		while( Struct )
		{
			while( Field )
			{
				if( Field->IsA(T::StaticClass()) )
					return;
				Field = Field->Next;
			}
			Struct = Struct->GetInheritanceSuper();
			if( Struct )
				Field = Struct->Children;
		}
	}
	UStruct* Struct;
	UField* Field;
};








class __declspec(dllimport) UStruct : public UField
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UField Super; typedef UStruct ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UStruct*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UStruct() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UStruct(); }
	protected: UStruct() {} public:

	
	UTextBuffer*		ScriptText;

	UTextBuffer*		CppText;
	UField*			Children;
	INT			PropertiesSize;
	FName			FriendlyName;
	TArray<BYTE>		Script;

	
	INT			TextPos;
	INT			Line;

	DWORD			StructFlags;

	
	UProperty*			RefLink;
	UProperty*			PropertyLink;
	UProperty*			ConfigLink;
	UProperty*			ConstructorLink;







	
	UStruct( ENativeConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UStruct* InSuperStruct );
	UStruct( EStaticConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags );
	UStruct( UStruct* InSuperStruct );

	
	void Serialize( FArchive& Ar );
	void PostLoad();
	void Destroy();
	void Register();

	
	void AddCppProperty( UProperty* Property );

	
	virtual UStruct* GetInheritanceSuper() {return GetSuperStruct();}
	virtual void Link( FArchive& Ar, UBOOL Props );
	virtual void SerializeBin( FArchive& Ar, BYTE* Data );
	virtual void SerializeTaggedProperties( FArchive& Ar, BYTE* Data, UClass* DefaultsClass );
	virtual void CleanupDestroyed( BYTE* Data );
	virtual EExprToken SerializeExpr( INT& iCode, FArchive& Ar );
	INT GetPropertiesSize()
	{
		return PropertiesSize;
	}
	DWORD GetScriptTextCRC()
	{
		return ScriptText ? appStrCrc(*ScriptText->Text) : 0;
	}
	void SetPropertiesSize( INT NewSize )
	{
		PropertiesSize = NewSize;
	}
	UBOOL IsChildOf( const UStruct* SomeBase ) const
	{
		{;
		for( const UStruct* Struct=this; Struct; Struct=Struct->GetSuperStruct() )
			if( Struct==SomeBase ) 
				return 1;
		return 0;
		};
	}
	virtual TCHAR* GetNameCPP()
	{
		TCHAR* Result = appStaticString1024();
		appSprintf( Result, L"F%s", GetName() );
		return Result;
	}
	UStruct* GetSuperStruct() const
	{
		{;
		;
		return (UStruct*)SuperField;
		};
	}
	UBOOL StructCompare( const void* A, const void* B );

































};








class __declspec(dllimport) UFunction : public UStruct
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UStruct Super; typedef UFunction ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UFunction*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UFunction() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UFunction(); }
	typedef UState WithinClass; UState* GetOuterUState() const { return (UState*)GetOuter(); }
	protected: UFunction() {} public:

	
	DWORD FunctionFlags;
	_WORD iNative;
	_WORD RepOffset;
	BYTE  OperPrecedence;

	
	BYTE  NumParms;
	_WORD ParmsSize;
	_WORD ReturnValueOffset;
	void (UObject::*Func)( FFrame& TheStack, void*const Result );




	
	UFunction( UFunction* InSuperFunction );

	
	void Serialize( FArchive& Ar );
	void PostLoad();

	
	void Bind();

	
	UBOOL MergeBools() {return 0;}
	UStruct* GetInheritanceSuper() {return 0;}
	void Link( FArchive& Ar, UBOOL Props );

	
	UFunction* GetSuperFunction() const
	{
		{;
		;
		return (UFunction*)SuperField;
		};
	}
	UProperty* GetReturnProperty();























};








class __declspec(dllimport) UState : public UStruct
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UStruct Super; typedef UState ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UState*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UState() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UState(); }
	protected: UState() {} public:

	
	QWORD ProbeMask;
	QWORD IgnoreMask;
	DWORD StateFlags;
	_WORD LabelTableOffset;
	UField* VfHash[HASH_COUNT];

	
	UState( ENativeConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags, UState* InSuperState );
	UState( EStaticConstructor, INT InSize, const TCHAR* InName, const TCHAR* InPackageName, DWORD InFlags );
	UState( UState* InSuperState );

	
	void Serialize( FArchive& Ar );
	void Destroy();

	
	UBOOL MergeBools() {return 1;}
	UStruct* GetInheritanceSuper() {return GetSuperState();}
	void Link( FArchive& Ar, UBOOL Props );

	
	UState* GetSuperState() const
	{
		{;
		;
		return (UState*)SuperField;
		};
	}
























};








class __declspec(dllimport) UEnum : public UField
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UField Super; typedef UEnum ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UEnum*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UEnum() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UEnum(); }
	typedef UStruct WithinClass; UStruct* GetOuterUStruct() const { return (UStruct*)GetOuter(); }
	protected: UEnum() {} public:

	
	TArray<FName> Names;

	
	UEnum( UEnum* InSuperEnum );

	
	void Serialize( FArchive& Ar );

	
	UEnum* GetSuperEnum() const
	{
		{;
		;
		return (UEnum*)SuperField;
		};
	}
};








class __declspec(dllimport) UClass : public UState
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UState Super; typedef UClass ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UClass*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UClass() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UClass(); }
	typedef UPackage WithinClass; UPackage* GetOuterUPackage() const { return (UPackage*)GetOuter(); }

	
	DWORD				ClassFlags;
	INT				ClassUnique;
	FGuid				ClassGuid;
	UClass*				ClassWithin;
	FName				ClassConfigName;
	TArray<FRepRecord>	ClassReps;
	TArray<UField*>		NetFields;
	TArray<FDependency> Dependencies;
	TArray<FName>		PackageImports;
	TArray<BYTE>		Defaults;
	void(*ClassConstructor)(void*);
	void(UObject::*ClassStaticConstructor)();

	
	

	
	UClass();
	UClass( UClass* InSuperClass );
	UClass( ENativeConstructor, DWORD InSize, DWORD InClassFlags, UClass* InBaseClass, UClass* InWithinClass, FGuid InGuid, const TCHAR* InNameStr, const TCHAR* InPackageName, const TCHAR* InClassConfigName, DWORD InFlags, void(*InClassConstructor)(void*), void(UObject::*InClassStaticConstructor)() );
	UClass( EStaticConstructor, DWORD InSize, DWORD InClassFlags, FGuid InGuid, const TCHAR* InNameStr, const TCHAR* InPackageName, const TCHAR* InClassConfigName, DWORD InFlags, void(*InClassConstructor)(void*), void(UObject::*InClassStaticConstructor)() );

	
	void Serialize( FArchive& Ar );
	void PostLoad();
	void Destroy();
	void Register();

	
	void Bind();

	
	UBOOL MergeBools() {return 1;}
	UStruct* GetInheritanceSuper() {return GetSuperClass();}
	TCHAR* GetNameCPP()
	{
		TCHAR* Result = appStaticString1024();
		UClass* C;
		for( C=this; C; C=C->GetSuperClass() )
			if( appStricmp(C->GetName(),L"Actor")==0 )
				break;
		appSprintf( Result, L"%s%s", C ? L"A" : L"U", GetName() );
		return Result;
	}
	void Link( FArchive& Ar, UBOOL Props );

	
	void AddDependency( UClass* InClass, UBOOL InDeep )
	{
		{static const TCHAR __FUNC_NAME__[]=L"UClass::AddDependency"; try{;
		INT i;
		for( i=0; i<Dependencies.Num(); i++ )
			if( Dependencies(i).Class==InClass )
				Dependencies(i).Deep |= InDeep;
		if( i==Dependencies.Num() )
			new(Dependencies)FDependency( InClass, InDeep );
		}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
	}
	UClass* GetSuperClass() const
	{
		{;
		return (UClass *)SuperField;
		};
	}
	UObject* GetDefaultObject()
	{
		{;
		{if(!(Defaults.Num()==GetPropertiesSize())) appFailAssert( "Defaults.Num()==GetPropertiesSize()", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnClass.h", 577 );};
		return (UObject*)&Defaults(0);
		};
	}
	class AActor* GetDefaultActor()
	{
		{;
		{if(!(Defaults.Num())) appFailAssert( "Defaults.Num()", "sdk\\Raven_Shield_C_SDK\\432Core\\Inc\\UnClass.h", 584 );};
		return (AActor*)&Defaults(0);
		};
	}

private:
	
	
	UBOOL IsA( UClass* Parent ) const {return UObject::IsA(Parent);}
};








class __declspec(dllimport) UConst : public UField
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UField Super; typedef UConst ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UConst*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UConst() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UConst(); }
	typedef UStruct WithinClass; UStruct* GetOuterUStruct() const { return (UStruct*)GetOuter(); }
	protected: UConst() {} public:

	
	FString Value;

	
	UConst( UConst* InSuperConst, const TCHAR* InValue );

	
	void Serialize( FArchive& Ar );

	
	UConst* GetSuperConst() const
	{
		{;
		;
		return (UConst*)SuperField;
		};
	}
};
















enum EPropertyPortFlags
{
	PPF_Localized = 1,
	PPF_Delimited = 2,
};




class __declspec(dllimport) UProperty : public UField
{
	public: enum {StaticClassFlags=0 | CLASS_Abstract}; private: static UClass PrivateStaticClass; public: typedef UField Super; typedef UProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UProperty() { ConditionalDestroy(); }
	typedef UField WithinClass; UField* GetOuterUField() const { return (UField*)GetOuter(); }

	
	INT			ArrayDim;
	INT			ElementSize;
	DWORD		PropertyFlags;
	FName		Category;
	_WORD		RepOffset;
	_WORD		RepIndex;

	
	INT			Offset;
	UProperty*	PropertyLinkNext;
	UProperty*	ConfigLinkNext;
	UProperty*	ConstructorLinkNext;
	UProperty*	RepOwner;


	DWORD Unknown1;
	DWORD Unknown2;
	DWORD Unknown3;
	DWORD Unknown4;

	
	UProperty();
	UProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags );

	
	void Serialize( FArchive& Ar );

	
	virtual void Link( FArchive& Ar, UProperty* Prev );
	virtual UBOOL Identical( const void* A, const void* B ) const=0;
	virtual void ExportCpp( FOutputDevice& Out, UBOOL IsLocal, UBOOL IsParm ) const;
	
	
	virtual UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	virtual void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const=0;
	virtual const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const=0;
	virtual UBOOL ExportText( INT ArrayElement, TCHAR* ValueStr, BYTE* Data, BYTE* Delta, INT PortFlags ) const;
	virtual void CopySingleValue( void* Dest, void* Src ) const;
	virtual void CopyCompleteValue( void* Dest, void* Src ) const;
	virtual void DestroyValue( void* Dest ) const;
	virtual UBOOL Port() const;
	virtual BYTE GetID() const;

	
	UBOOL Matches( const void* A, const void* B, INT ArrayIndex ) const
	{
		{;
		INT Ofs = Offset + ArrayIndex * ElementSize;
		return Identical( (BYTE*)A + Ofs, B ? (BYTE*)B + Ofs : 0 );
		};
	}
	INT GetSize() const
	{
		{;
		return ArrayDim * ElementSize;
		};
	}
	UBOOL ShouldSerializeValue( FArchive& Ar ) const
	{
		{;
		UBOOL Skip
		=	((PropertyFlags & CPF_Native   )                      )
		||	((PropertyFlags & CPF_Transient) && Ar.IsPersistent() );
		return !Skip;
		};
	}
};








class __declspec(dllimport) UByteProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UByteProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UByteProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UByteProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UByteProperty(); }

	
	UEnum* Enum;

	
	UByteProperty()
	{}
	UByteProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags, UEnum* InEnum=0 )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	,	Enum( InEnum )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void CopyCompleteValue( void* Dest, void* Src ) const;
};








class __declspec(dllimport) UIntProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UIntProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UIntProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UIntProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UIntProperty(); }

	
	UIntProperty()
	{}
	UIntProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	{}

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void CopyCompleteValue( void* Dest, void* Src ) const;
};








class __declspec(dllimport) UBoolProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UBoolProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UBoolProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UBoolProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UBoolProperty(); }

	
	BITFIELD BitMask;

	
	UBoolProperty()
	{}
	UBoolProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	,	BitMask( 1 )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
};








class __declspec(dllimport) UFloatProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UFloatProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UFloatProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UFloatProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UFloatProperty(); }

	
	UFloatProperty()
	{}
	UFloatProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	{}

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void CopyCompleteValue( void* Dest, void* Src ) const;
};








class __declspec(dllimport) UObjectProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UObjectProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UObjectProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UObjectProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UObjectProperty(); }

	
	class UClass*  PropertyClass;
	UObjectProperty* NextReference;

	
	UObjectProperty()
	{}
	UObjectProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags, UClass* InClass )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	,	PropertyClass( InClass )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void CopyCompleteValue( void* Dest, void* Src ) const;
};








class __declspec(dllimport) UClassProperty : public UObjectProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObjectProperty Super; typedef UClassProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UClassProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UClassProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UClassProperty(); }

	
	class UClass* MetaClass;

	
	UClassProperty()
	{}
	UClassProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags, UClass* InMetaClass )
	:	UObjectProperty( EC_CppProperty, InOffset, InCategory, InFlags, UClass::StaticClass() )
	,	MetaClass( InMetaClass )
	{}

	
	void Serialize( FArchive& Ar );

	
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	BYTE GetID() const
	{
		return NAME_ObjectProperty;
	}
};








class __declspec(dllimport) UNameProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UNameProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UNameProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UNameProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UNameProperty(); }

	
	UNameProperty()
	{}
	UNameProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	{}

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void CopyCompleteValue( void* Dest, void* Src ) const;
};








class __declspec(dllimport) UStrProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UStrProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UStrProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UStrProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UStrProperty(); }

	
	UStrProperty()
	{}
	UStrProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void DestroyValue( void* Dest ) const;
};








class __declspec(dllimport) UFixedArrayProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UFixedArrayProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UFixedArrayProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UFixedArrayProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UFixedArrayProperty(); }

	
	UProperty* Inner;
	INT Count;

	
	UFixedArrayProperty()
	{}
	UFixedArrayProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void DestroyValue( void* Dest ) const;

	
	void AddCppProperty( UProperty* Property, INT Count );
};








class __declspec(dllimport) UArrayProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UArrayProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UArrayProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UArrayProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UArrayProperty(); }

	
	UProperty* Inner;

	
	UArrayProperty()
	{}
	UArrayProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void DestroyValue( void* Dest ) const;

	
	void AddCppProperty( UProperty* Property );
};








class __declspec(dllimport) UMapProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UMapProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UMapProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UMapProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UMapProperty(); }

	
	UProperty* Key;
	UProperty* Value;

	
	UMapProperty()
	{}
	UMapProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void DestroyValue( void* Dest ) const;
};









class __declspec(dllimport) UStructProperty : public UProperty
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UProperty Super; typedef UStructProperty ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UStructProperty*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UStructProperty() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UStructProperty(); }

	
	class UStruct* Struct;
	UStructProperty* NextStruct;

	
	UStructProperty()
	{}
	UStructProperty( ECppProperty, INT InOffset, const TCHAR* InCategory, DWORD InFlags, UStruct* InStruct )
	:	UProperty( EC_CppProperty, InOffset, InCategory, InFlags )
	,	Struct( InStruct )
	{}

	
	void Serialize( FArchive& Ar );

	
	void Link( FArchive& Ar, UProperty* Prev );
	UBOOL Identical( const void* A, const void* B ) const;
	void SerializeItem( FArchive& Ar, void* Value ) const;
	UBOOL NetSerializeItem( FArchive& Ar, UPackageMap* Map, void* Data ) const;
	void ExportCppItem( FOutputDevice& Out ) const;
	void ExportTextItem( TCHAR* ValueStr, BYTE* PropertyValue, BYTE* DefaultValue, INT PortFlags ) const;
	const TCHAR* ImportText( const TCHAR* Buffer, BYTE* Data, INT PortFlags ) const;
	void CopySingleValue( void* Dest, void* Src ) const;
	void DestroyValue( void* Dest ) const;
};








template <class T> T* FindField( UStruct* Owner, const TCHAR* FieldName )
{
	{static const TCHAR __FUNC_NAME__[]=L"FindField"; try{;
	for( TFieldIterator<T>It( Owner ); It; ++It )
		if( appStricmp( It->GetName(), FieldName )==0 )
			return *It;
	return 0;
	}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
}








inline UBOOL UObject::IsA( class UClass* SomeBase ) const
{
	{;
	for( UClass* TempClass=Class; TempClass; TempClass=(UClass*)TempClass->SuperField )
		if( TempClass==SomeBase )
			return 1;
	return SomeBase==0;
	};
}




inline UBOOL UObject::IsIn( class UObject* SomeOuter ) const
{
	{;
	for( UObject* It=GetOuter(); It; It=It->GetOuter() )
		if( It==SomeOuter )
			return 1;
	return SomeOuter==0;
	};
}








inline UBOOL UStruct::StructCompare( const void* A, const void* B )
{
	{;
	for( TFieldIterator<UProperty> It(this); It; ++It )
		for( INT i=0; i<It->ArrayDim; i++ )
			if( !It->Matches(A,B,i) )
				return 0;
	};
	return 1;
}




























typedef void (UObject::*Native)( FFrame& TheStack, void*const Result );
extern __declspec(dllimport) Native GNatives[];
BYTE __declspec(dllimport) GRegisterNative( INT iNative, const Native& Func );





	














































































inline FFrame::FFrame( UObject* InObject )
:	Node		(InObject ? InObject->GetClass() : 0)
,	Object		(InObject)
,	Code		(0)
,	Locals		(0)
{}
inline FFrame::FFrame( UObject* InObject, UStruct* InNode, INT CodeOffset, void* InLocals )
:	Node		(InNode)
,	Object		(InObject)
,	Code		(&InNode->Script(CodeOffset))
,	Locals		((BYTE*)InLocals)
{}
inline void FFrame::Step( UObject* Context, void*const Result )
{
	{;
	INT B = *Code++;
	(Context->*GNatives[B])( *this, Result );
	};
}
inline INT FFrame::ReadInt()
{
	INT Result;
	


	Result = *(INT*)Code;
	
	Code += sizeof(INT);
	return Result;
}
inline UObject* FFrame::ReadObject()
{
	UObject* Result;
	


	Result = *(UObject**)Code;
	
	Code += sizeof(INT);
	return Result;
}
inline FLOAT FFrame::ReadFloat()
{
	FLOAT Result;
	


	Result = *(FLOAT*)Code;
	
	Code += sizeof(FLOAT);
	return Result;
}
inline INT FFrame::ReadWord()
{
	INT Result;
	




	Result = *(_WORD*)Code;
	
	Code += sizeof(_WORD);
	return Result;
}
inline FName FFrame::ReadName()
{
	FName Result;
	


	Result = *(FName*)Code;
	
	Code += sizeof(FName);
	return Result;
}
__declspec(dllimport) void GInitRunaway();





inline FStateFrame::FStateFrame( UObject* InObject )
:	FFrame		( InObject )
,	CurrentFrame( 0 )
,	StateNode	( InObject->GetClass() )
,	ProbeMask	( ~(QWORD)0 )
{}
inline const TCHAR* FStateFrame::Describe()
{
	return Node ? Node->GetFullName() : L"None";
}





















class __declspec(dllimport) UFactory : public UObject
{
	public: enum {StaticClassFlags=0 | CLASS_Abstract}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UFactory ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UFactory*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UFactory() { ConditionalDestroy(); }

	
	UClass*         SupportedClass;
	UClass*			ContextClass;
	FString			Description;
	FString			InContextCommand;
	FString			OutOfContextCommand;
	TArray<FString> Formats;
	BITFIELD        bCreateNew         : 1;
	BITFIELD		bShowPropertySheet : 1;
	BITFIELD		bShowCategories    : 1;
	BITFIELD		bText              : 1;
	BITFIELD		bMulti			   : 1;
	INT				AutoPriority;

	
	UFactory();
	void StaticConstructor();

	
	void Serialize( FArchive& Ar );

	
	virtual UObject* FactoryCreateText( UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, const TCHAR* Type, const TCHAR*& Buffer, const TCHAR* BufferEnd, FFeedbackContext* Warn ) {return 0;}
	virtual UObject* FactoryCreateBinary( UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, const TCHAR* Type, const BYTE*& Buffer, const BYTE* BufferEnd, FFeedbackContext* Warn ) {return 0;}
	virtual UObject* FactoryCreateNew( UClass* Class, UObject* InParent, FName Name, DWORD Flags, UObject* Context, FFeedbackContext* Warn ) {return 0;}

	
	static UObject* StaticImportObject( UClass* Class, UObject* InOuter, FName Name, DWORD Flags, const TCHAR* Filename=L"", UObject* Context=0, UFactory* Factory=0, const TCHAR* Parms=0, FFeedbackContext* Warn=GWarn );
};


template< class T > T* ImportObject( UObject* Outer, FName Name, DWORD Flags, const TCHAR* Filename=L"", UObject* Context=0, UFactory* Factory=0, const TCHAR* Parms=0, FFeedbackContext* Warn=GWarn )
{
	return (T*)UFactory::StaticImportObject( T::StaticClass(), Outer, Name, Flags, Filename, Context, Factory, Parms, Warn );
}





















class __declspec(dllimport) UExporter : public UObject
{
	public: enum {StaticClassFlags=0 | CLASS_Abstract}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UExporter ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UExporter*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UExporter() { ConditionalDestroy(); }

	
	UClass*         SupportedClass;
	TArray<FString> Formats;
	INT				TextIndent;
	BITFIELD		bText  : 1;
	BITFIELD        bMulti : 1;

	
	UExporter();

	
	void Serialize( FArchive& Ar );
	void StaticConstructor();

	
	virtual UBOOL ExportText( UObject* Object, const TCHAR* Type, FOutputDevice& Ar, FFeedbackContext* Warn ) {return 0;}
	virtual UBOOL ExportBinary( UObject* Object, const TCHAR* Type, FArchive& Ar, FFeedbackContext* Warn ) {return 0;}
	static UExporter* FindExporter( UObject* Object, const TCHAR* Filetype );
	static INT ExportToFile( UObject* Object, UExporter* Exporter, const TCHAR* Filename, UBOOL NoReplaceIdentical=0, UBOOL Prompt=0 );
	static void ExportToArchive( UObject* Object, UExporter* Exporter, FArchive& Ar, const TCHAR* FileType );
	static void ExportToOutputDevice( UObject* Object, UExporter* Exporter, FOutputDevice& Out, const TCHAR* FileType, INT Indent );
};





















class __declspec(dllimport) FMemCache
{
public:
	
	enum {COST_INFINITE=0x1000000};
	class __declspec(dllimport) FCacheItem
	{
	public:
		friend class FMemCache;
		void Unlock()
		{






			Cost -= COST_INFINITE;
		}
		QWORD GetId()
		{
			return Id;
		}
		BYTE* GetData()
		{
			return Data;
		}
		INT GetSize()
		{
			return LinearNext->Data - Data;
		}
		BYTE GetExtra()
		{
			return Extra;
		}
		void SetExtra( BYTE B )
		{
			Extra = B;
		}
		typedef _WORD TCacheTime;
		INT GetCost()
		{
			return Cost;
		}
		TCacheTime GetTime()
		{
			return Time;
		}

		
	private:
		QWORD		Id;				
		BYTE*		Data;			
		TCacheTime	Time;			
		BYTE		Segment;		
		BYTE		Extra;			
		INT			Cost;			
		FCacheItem*	LinearNext;		
		FCacheItem*	LinearPrev;		
		FCacheItem*	HashNext;		
	};

	
	FMemCache() {Initialized=0;}
    void Init( INT BytesToAllocate, INT MaxItems, void* Start=0, INT SegSize=0 );
	void Exit( INT FreeMemory );
	void Flush( QWORD Id=0, DWORD Mask=~0, UBOOL IgnoreLocked=0 );
	BYTE* Create( QWORD Id, FCacheItem *&Item, INT CreateSize, INT Alignment=DEFAULT_ALIGNMENT, INT SafetyPad=0 );
	void Tick();
	void CheckState();
	UBOOL Exec( const TCHAR* Cmd, FOutputDevice& Ar=*GLog );
	void Status( TCHAR* Msg );
	INT GetTime() {return Time;}

	
	FCacheItem* First()
	{
		return CacheItems;
	}
	FCacheItem* Last()
	{
		return LastItem;
	}
	FCacheItem* Next( FCacheItem* Item )
	{
		return Item->LinearNext;
	}
	DWORD GHash( QWORD Val )
	{
		DWORD D=(DWORD)Val;
		return (D ^ (D>>12) ^ (D>>24)) & (HASH_COUNT-1);
	}
	BYTE* Get( QWORD Id, FCacheItem*& Item, INT Alignment=DEFAULT_ALIGNMENT )
	{	
		{;
		;



		if( Id==MruId )
		{
			Item = MruItem;
			MruItem->Cost += COST_INFINITE;
			return Align( MruItem->Data, Alignment );
		}
		for( FCacheItem* HashItem=HashItems[GHash(Id)]; HashItem; HashItem=HashItem->HashNext )
		{
			if( HashItem->Id == Id )
			{
				
				MruId			= Id;
				MruItem			= HashItem;
				Item            = HashItem;
				HashItem->Time  = Time;
				HashItem->Cost += COST_INFINITE;
				;
				return Align( HashItem->Data, Alignment );
			}
		}
		;
		return 0;
		};
	}

private:
	
	enum {HASH_COUNT=16384};
	enum {IGNORE_SIZE=256};

	
	UBOOL		Initialized;
	INT			Time;
	QWORD		MruId;
	FCacheItem* MruItem;
	FCacheItem* ItemMemory;
	FCacheItem* CacheItems;
	FCacheItem* LastItem;
	FCacheItem* UnusedItems;
	FCacheItem* HashItems[HASH_COUNT];
	BYTE*       CacheMemory;

	
	INT			NumGets, NumCreates, CreateCycles, GetCycles, TickCycles;
	INT			ItemsFresh, ItemsStale, ItemsTotal, ItemGaps;
	INT			MemFresh, MemStale, MemTotal;

	
	void CreateNewFreeSpace( BYTE* Start, BYTE* End, FCacheItem* Prev, FCacheItem* Next, INT Segment );
	void Unhash( QWORD Id )
	{
		for( FCacheItem** PrevLink=&HashItems[GHash(Id)]; *PrevLink; PrevLink=&(*PrevLink)->HashNext )
		{
			if( (*PrevLink)->Id == Id )
			{
				*PrevLink = (*PrevLink)->HashNext;
				return;
			}
		}
		GError->Logf( L"Unhashed item" );
	}
	FCacheItem* MergeWithNext( FCacheItem* First );
	FCacheItem* FlushItem( FCacheItem* Item, UBOOL IgnoreLocked=0 );
	void ConditionalCheckState()
	{



	}

	
	friend class FCacheItem;
};


typedef FMemCache::FCacheItem FCacheItem;



















enum EMemZeroed {MEM_Zeroed=1};
enum EMemOned   {MEM_Oned  =1};










class __declspec(dllimport) FMemStack
{
public:
	
	BYTE* PushBytes( INT AllocSize, INT Align )
	{
		
		{;

		



		;
		;
		;

		
		BYTE* Result = (BYTE *)(((INT)Top+(Align-1))&~(Align-1));
		Top = Result + AllocSize;

		
		if( Top > End )
		{
			
			AllocateNewChunk( AllocSize + Align );
			Result = (BYTE *)(((INT)Top+(Align-1))&~(Align-1));
			Top    = Result + AllocSize;
		}
		return Result;
		};
	}

	
	void Init( INT DefaultChunkSize );
	void Exit();
	void Tick();
	INT GetByteCount();

	
	friend class FMemMark;
	friend void* operator new( size_t Size, FMemStack& Mem, INT Count=1, INT Align=DEFAULT_ALIGNMENT );
	friend void* operator new( size_t Size, FMemStack& Mem, EMemZeroed Tag, INT Count=1, INT Align=DEFAULT_ALIGNMENT );
	friend void* operator new( size_t Size, FMemStack& Mem, EMemOned Tag, INT Count=1, INT Align=DEFAULT_ALIGNMENT );

	
	struct FTaggedMemory
	{
		FTaggedMemory* Next;
		INT DataSize;
		BYTE Data[1];
	};

private:
	
	enum {MAX_CHUNKS=1024};

	
	BYTE*			Top;				
	BYTE*			End;				
	INT				DefaultChunkSize;	
	FTaggedMemory*	TopChunk;			

	
	static FTaggedMemory* UnusedChunks;

	
	BYTE* AllocateNewChunk( INT MinSize );
	void FreeChunks( FTaggedMemory* NewTopChunk );
};






template <class T> inline T* New( FMemStack& Mem, INT Count=1, INT Align=DEFAULT_ALIGNMENT )
{
	{;
	return (T*)Mem.PushBytes( Count*sizeof(T), Align );
	};
}
template <class T> inline T* NewZeroed( FMemStack& Mem, INT Count=1, INT Align=DEFAULT_ALIGNMENT )
{
	{;
	BYTE* Result = Mem.PushBytes( Count*sizeof(T), Align );
	appMemzero( Result, Count*sizeof(T) );
	return (T*)Result;
	};
}
template <class T> inline T* NewOned( FMemStack& Mem, INT Count=1, INT Align=DEFAULT_ALIGNMENT )
{
	{;
	return (T*)Mem.PushBytes( Count*sizeof(T), Align );
	appMemset( Result, 0xff, Count*sizeof(T) );
	return (T*)Result;
	};
}






inline void* operator new( size_t Size, FMemStack& Mem, INT Count, INT Align )
{
	
	{;
	return Mem.PushBytes( Size*Count, Align );
	};
}
inline void* operator new( size_t Size, FMemStack& Mem, EMemZeroed Tag, INT Count, INT Align )
{
	
	{;
	BYTE* Result = Mem.PushBytes( Size*Count, Align );
	appMemzero( Result, Size*Count );
	return Result;
	};
}
inline void* operator new( size_t Size, FMemStack& Mem, EMemOned Tag, INT Count, INT Align )
{
	
	{;
	BYTE* Result = Mem.PushBytes( Size*Count, Align );
	appMemset( Result, 0xff, Size*Count );
	return Result;
	};
}











class __declspec(dllimport) FMemMark
{
public:
	
	FMemMark()
	{}
	FMemMark( FMemStack& InMem )
	{
		{;
		Mem          = &InMem;
		Top          = Mem->Top;
		SavedChunk   = Mem->TopChunk;
		};
	}

	
	void Pop()
	{
		
		{;

		
		if( SavedChunk != Mem->TopChunk )
			Mem->FreeChunks( SavedChunk );

		
		Mem->Top = Top;
		};
	}

private:
	
	FMemStack* Mem;
	BYTE* Top;
	FMemStack::FTaggedMemory* SavedChunk;
};





















enum ECacheIDBase
{
	CID_ShadowMap			= 0x15,
	CID_IlluminationMap		= 0x16,
	CID_LightPalette		= 0x17,
	CID_StaticMap			= 0x18,
	CID_DepthLineTable		= 0x1C,
	CID_TweenAnim			= 0x1D,
	CID_TriPalette			= 0x1E,
	CID_InputMap			= 0x1F,
	CID_VolumetricScaler	= 0x20,
	CID_RenderPalette		= 0x25,
	CID_RenderFogMap		= 0x26,
	CID_CoronaCache			= 0x27,
	CID_PolyPalette         = 0x28,
	CID_PolyMMXPalette      = 0x29,
	CID_SurfPalette         = 0x2A,
	CID_SurfMMXPalette      = 0x2B,
	CID_LitTilePal          = 0x2C,
	CID_LitTileTrans        = 0x2D,
	CID_LitTileMMX          = 0x2E,
	CID_LitTileMod          = 0x2F,
	CID_ActorLightCache     = 0x30,
	CID_DynamicMap          = 0x31,
	CID_GlidePal            = 0x32,
	CID_BumpNormals         = 0x33,
	CID_SkeletalData        = 0x34,
	CID_RenderTexture		= 0xE0,
	CID_MAX					= 0xff,
};





inline QWORD MakeCacheID( ECacheIDBase Base, UObject* Frame )
{
	return (Base) + ((Frame?(QWORD)Frame->GetIndex():(QWORD)0) << 8);
}

inline QWORD MakeCacheID( ECacheIDBase Base, UObject* Obj, UObject* Frame )
{
	return (Base) + ((Obj?Obj->GetIndex():0) << 8) + ((Frame?(QWORD)Frame->GetIndex():(QWORD)0) << 32);
}

inline QWORD MakeCacheID( ECacheIDBase Base, DWORD Word, DWORD Byte, UObject* Frame )
{
	return (Base) + (Byte<<8) + (Word<<16) + ((Frame?(QWORD)Frame->GetIndex():(QWORD)0) << 32);
}

inline QWORD MakeCacheID( ECacheIDBase Base, DWORD ByteA, DWORD ByteB, DWORD ByteC, UObject* Frame )
{
	return (Base) + (ByteA<<8) + (ByteB<<16) + (ByteC<<24) + ((Frame?(QWORD)Frame->GetIndex():(QWORD)0) << 32);
}

inline QWORD MakeCacheID( ECacheIDBase Base, QWORD Q )
{
	return Base + (Q & ~(QWORD)CID_MAX);
}





















struct __declspec(dllimport) FBitWriter : public FArchive
{
	friend struct FBitWriterMark;
public:
	FBitWriter( INT InMaxBits );
	void SerializeBits( void* Src, INT LengthBits );
	void SerializeInt( DWORD& Value, DWORD Max );
	void WriteInt( DWORD Result, DWORD Max );
	void WriteBit( BYTE In );
	void Serialize( void* Src, INT LengthBytes );
	BYTE* GetData();
	INT GetNumBytes();
	INT GetNumBits();
	void SetOverflowed();
private:
	TArray<BYTE> Buffer;
	INT   Num;
	INT   Max;
};




struct __declspec(dllimport) FBitWriterMark
{
public:
	FBitWriterMark()
	:	Num         ( 0 )
	{}
	FBitWriterMark( FBitWriter& Writer )
	:	Overflowed	( Writer.ArIsError )
	,	Num			( Writer.Num )
	{}
	INT GetNumBits()
	{
		return Num;
	}
	void Pop( FBitWriter& Writer );
private:
	UBOOL			Overflowed;
	INT				Num;
};








struct __declspec(dllimport) FBitReader : public FArchive
{
public:
	FBitReader( BYTE* Src=0, INT CountBits=0 );
	void SetData( FBitReader& Src, INT CountBits );
	void SerializeBits( void* Dest, INT LengthBits );
	void SerializeInt( DWORD& Value, DWORD Max );
	DWORD ReadInt( DWORD Max );
	BYTE ReadBit();
	void Serialize( void* Dest, INT LengthBytes );
	BYTE* GetData();
	UBOOL AtEnd();
	void SetOverflowed();
	INT GetNumBytes();
	INT GetNumBits();
	INT GetPosBits();
private:
	TArray<BYTE> Buffer;
	INT   Num;
	INT   Pos;
};



















class  FVector;
class  FPlane;
class  FCoords;
class  FRotator;
class  FScale;
class  FGlobalMath;
class  FMatrix;
class  FQuat;


inline	INT Fix		(INT A)			{return A<<16;};
inline	INT Fix		(FLOAT A)		{return appRound(A*65536.f);};
inline	INT Unfix	(INT A)			{return A>>16;};


















inline FLOAT FSnap( FLOAT Location, FLOAT Grid )
{
	if( Grid==0.f )	return Location;
	else			return appFloor((Location + 0.5f*Grid)/Grid)*Grid;
}




inline FLOAT FSheerSnap (FLOAT Sheer)
{
	if		(Sheer < -0.65f) return Sheer + 0.15f;
	else if (Sheer > +0.65f) return Sheer - 0.15f;
	else if (Sheer < -0.55f) return -0.50f;
	else if (Sheer > +0.55f) return 0.50f;
	else if (Sheer < -0.05f) return Sheer + 0.05f;
	else if (Sheer > +0.05f) return Sheer - 0.05f;
	else					 return 0.f;
}




inline DWORD FNextPowerOfTwo( DWORD N )
{
	if (N<=0L		) return 0L;
	if (N<=1L		) return 1L;
	if (N<=2L		) return 2L;
	if (N<=4L		) return 4L;
	if (N<=8L		) return 8L;
	if (N<=16L	    ) return 16L;
	if (N<=32L	    ) return 32L;
	if (N<=64L 	    ) return 64L;
	if (N<=128L     ) return 128L;
	if (N<=256L     ) return 256L;
	if (N<=512L     ) return 512L;
	if (N<=1024L    ) return 1024L;
	if (N<=2048L    ) return 2048L;
	if (N<=4096L    ) return 4096L;
	if (N<=8192L    ) return 8192L;
	if (N<=16384L   ) return 16384L;
	if (N<=32768L   ) return 32768L;
	if (N<=65536L   ) return 65536L;
	else			  return 0;
}






inline _WORD FAddAngleConfined( INT Angle, INT Delta, INT MinThresh, INT MaxThresh )
{
	if( Delta < 0 )
	{
		if( Delta<=-0x10000L || Delta<=-(INT)((_WORD)(Angle-MinThresh)))
			return (_WORD)MinThresh;
	}
	else if( Delta > 0 )
	{
		if( Delta>=0x10000L || Delta>=(INT)((_WORD)(MaxThresh-Angle)))
			return (_WORD)MaxThresh;
	}
	return (_WORD)(Angle+Delta);
}




INT ReduceAngle( INT Angle );






inline UBOOL IsSmallerPositiveFloat(float F1,float F2)
{
	return ( (*(DWORD*)&F1) < (*(DWORD*)&F2));
}

inline FLOAT MinPositiveFloat(float F1, float F2)
{
	if ( (*(DWORD*)&F1) < (*(DWORD*)&F2)) return F1; else return F2;
}





inline UBOOL EqualPositiveFloat(float F1, float F2)
{
	return ( *(DWORD*)&F1 == *(DWORD*)&F2 );
}

inline UBOOL IsNegativeFloat(float F1)
{
	return ( (*(DWORD*)&F1) >= (DWORD)0x80000000 ); 
}

inline FLOAT MaxPositiveFloat(float F1, float F2)
{
	if ( (*(DWORD*)&F1) < (*(DWORD*)&F2)) return F2; else return F1;
}


inline FLOAT ClampPositiveFloat(float F0, float F1, float F2)
{
	if      ( (*(DWORD*)&F0) < (*(DWORD*)&F1)) return F1;
	else if ( (*(DWORD*)&F0) > (*(DWORD*)&F2)) return F2;
	else return F0;
}














enum EVectorFlags
{
	FVF_OutXMin		= 0x04,	
	FVF_OutXMax		= 0x08,	
	FVF_OutYMin		= 0x10,	
	FVF_OutYMax		= 0x20,	
	FVF_OutNear     = 0x40, 
	FVF_OutFar      = 0x80, 
	FVF_OutReject   = (FVF_OutXMin | FVF_OutXMax | FVF_OutYMin | FVF_OutYMax), 
	FVF_OutSkip		= (FVF_OutXMin | FVF_OutXMax | FVF_OutYMin | FVF_OutYMax), 
};





































































































































































































































































































































































class __declspec(dllimport) FVector 
{
public:
	
	FLOAT X,Y,Z;

	
	FVector()
	{}

	FVector( FLOAT InX, FLOAT InY, FLOAT InZ )
	:	X(InX), Y(InY), Z(InZ)
	{}

	
	FVector operator^( const FVector& V ) const
	{
		return FVector
		(
			Y * V.Z - Z * V.Y,
			Z * V.X - X * V.Z,
			X * V.Y - Y * V.X
		);
	}
	FLOAT operator|( const FVector& V ) const
	{
		return X*V.X + Y*V.Y + Z*V.Z;
	}
	friend FVector operator*( FLOAT Scale, const FVector& V )
	{
		return FVector( V.X * Scale, V.Y * Scale, V.Z * Scale );
	}
	FVector operator+( const FVector& V ) const
	{
		return FVector( X + V.X, Y + V.Y, Z + V.Z );
	}
	FVector operator-( const FVector& V ) const
	{
		return FVector( X - V.X, Y - V.Y, Z - V.Z );
	}
	FVector operator*( FLOAT Scale ) const
	{
		return FVector( X * Scale, Y * Scale, Z * Scale );
	}
	FVector operator/( FLOAT Scale ) const
	{
		FLOAT RScale = 1.f/Scale;
		return FVector( X * RScale, Y * RScale, Z * RScale );
	}
	FVector operator*( const FVector& V ) const
	{
		return FVector( X * V.X, Y * V.Y, Z * V.Z );
	}

	
	UBOOL operator==( const FVector& V ) const
	{
		return X==V.X && Y==V.Y && Z==V.Z;
	}
	UBOOL operator!=( const FVector& V ) const
	{
		return X!=V.X || Y!=V.Y || Z!=V.Z;
	}

	
	FVector operator-() const
	{
		return FVector( -X, -Y, -Z );
	}

	
	FVector operator+=( const FVector& V )
	{
		X += V.X; Y += V.Y; Z += V.Z;
		return *this;
	}
	FVector operator-=( const FVector& V )
	{
		X -= V.X; Y -= V.Y; Z -= V.Z;
		return *this;
	}
	FVector operator*=( FLOAT Scale )
	{
		X *= Scale; Y *= Scale; Z *= Scale;
		return *this;
	}
	FVector operator/=( FLOAT V )
	{
		FLOAT RV = 1.f/V;
		X *= RV; Y *= RV; Z *= RV;
		return *this;
	}
	FVector operator*=( const FVector& V )
	{
		X *= V.X; Y *= V.Y; Z *= V.Z;
		return *this;
	}
	FVector operator/=( const FVector& V )
	{
		X /= V.X; Y /= V.Y; Z /= V.Z;
		return *this;
	}

	
	FLOAT Size() const;
	




	FLOAT SizeSquared() const
	{
		return X*X + Y*Y + Z*Z;
	}
	FLOAT Size2D() const;
	




	FLOAT SizeSquared2D() const 
	{
		return X*X + Y*Y;
	}
	int IsNearlyZero() const
	{
		return
				Abs(X)<(1.e-4f)
			&&	Abs(Y)<(1.e-4f)
			&&	Abs(Z)<(1.e-4f);
	}
	UBOOL IsZero() const
	{
		return X==0.f && Y==0.f && Z==0.f;
	}
	UBOOL Normalize();
	











	FVector Projection() const
	{
		FLOAT RZ = 1.f/Z;
		return FVector( X*RZ, Y*RZ, 1 );
	}
	FVector UnsafeNormal() const;
	





	FVector GridSnap( const FVector& Grid )
	{
		return FVector( FSnap(X, Grid.X),FSnap(Y, Grid.Y),FSnap(Z, Grid.Z) );
	}
	FVector BoundToCube( FLOAT Radius )
	{
		return FVector
		(
			Clamp(X,-Radius,Radius),
			Clamp(Y,-Radius,Radius),
			Clamp(Z,-Radius,Radius)
		);
	}
	void AddBounded( const FVector& V, FLOAT Radius=MAXSWORD )
	{
		*this = (*this + V).BoundToCube(Radius);
	}
	FLOAT& Component( INT Index )
	{
		return (&X)[Index];
	}

	
	
	
	UBOOL Booleanize()
	{
		return
			X >  0.f ? 1 :
			X <  0.f ? 0 :
			Y >  0.f ? 1 :
			Y <  0.f ? 0 :
			Z >= 0.f ? 1 : 0;
	}

	
	FVector TransformVectorBy( const FCoords& Coords ) const;
	FVector TransformPointBy( const FCoords& Coords ) const;
	FVector MirrorByVector( const FVector& MirrorNormal ) const;
	FVector MirrorByPlane( const FPlane& MirrorPlane ) const;
	FVector PivotTransform(const FCoords& Coords) const;

	
	FRotator Rotation();
	void FindBestAxisVectors( FVector& Axis1, FVector& Axis2 );
	FVector SafeNormal() const; 

	
	friend FLOAT FDist( const FVector& V1, const FVector& V2 );
	friend FLOAT FDistSquared( const FVector& V1, const FVector& V2 );
	friend UBOOL FPointsAreSame( const FVector& P, const FVector& Q );
	friend UBOOL FPointsAreNear( const FVector& Point1, const FVector& Point2, FLOAT Dist);
	friend FLOAT FPointPlaneDist( const FVector& Point, const FVector& PlaneBase, const FVector& PlaneNormal );
	friend FVector FLinePlaneIntersection( const FVector& Point1, const FVector& Point2, const FVector& PlaneOrigin, const FVector& PlaneNormal );
	friend FVector FLinePlaneIntersection( const FVector& Point1, const FVector& Point2, const FPlane& Plane );
	friend UBOOL FParallel( const FVector& Normal1, const FVector& Normal2 );
	friend UBOOL FCoplanar( const FVector& Base1, const FVector& Normal1, const FVector& Base2, const FVector& Normal2 );

	
	friend FArchive& operator<<( FArchive& Ar, FVector& V )
	{
		return Ar << V.X << V.Y << V.Z;
	}

	static const FVector FVector0;
};



class ABrush;
class __declspec(dllimport) FVertexHit
{
public:
	
	ABrush* pBrush;
	INT PolyIndex;
	INT VertexIndex;

	
	FVertexHit()
	{
		pBrush = 0;
		PolyIndex = VertexIndex = 0;
	}
	FVertexHit( ABrush* _pBrush, INT _PolyIndex, INT _VertexIndex )
	{
		pBrush = _pBrush;
		PolyIndex = _PolyIndex;
		VertexIndex = _VertexIndex;
	}

	
	UBOOL operator==( const FVertexHit& V ) const
	{
		return pBrush==V.pBrush && PolyIndex==V.PolyIndex && VertexIndex==V.VertexIndex;
	}
	UBOOL operator!=( const FVertexHit& V ) const
	{
		return pBrush!=V.pBrush || PolyIndex!=V.PolyIndex || VertexIndex!=V.VertexIndex;
	}
};

class FPoly;
class __declspec(dllimport) FFaceDragHit
{
public:
	FFaceDragHit( ABrush* InBrush, FPoly* InPoly )
	{
		Brush = InBrush;
		Poly = InPoly;
	}

	ABrush* Brush;
	FPoly* Poly;
};





class __declspec(dllimport) FPlane : public FVector
{
public:
	
	FLOAT W;

	
	FPlane()
	{}
	FPlane( const FPlane& P )
	:	FVector(P)
	,	W(P.W)
	{}
	FPlane( const FVector& V )
	:	FVector(V)
	,	W(0)
	{}
	FPlane( FLOAT InX, FLOAT InY, FLOAT InZ, FLOAT InW )
	:	FVector(InX,InY,InZ)
	,	W(InW)
	{}
	FPlane( FVector InNormal, FLOAT InW )
	:	FVector(InNormal), W(InW)
	{}
	FPlane( FVector InBase, const FVector &InNormal )
	:	FVector(InNormal)
	,	W(InBase | InNormal)
	{}
	FPlane( FVector A, FVector B, FVector C )
	:	FVector( ((B-A)^(C-A)).SafeNormal() )
	,	W( A | ((B-A)^(C-A)).SafeNormal() )
	{}

	
	FLOAT PlaneDot( const FVector &P ) const
	{
		return X*P.X + Y*P.Y + Z*P.Z - W;
	}
	FPlane Flip() const
	{
		return FPlane(-X,-Y,-Z,-W);
	}
	FPlane TransformPlaneByOrtho( const FCoords &Coords ) const;
	UBOOL operator==( const FPlane& V ) const
	{
		return X==V.X && Y==V.Y && Z==V.Z && W==V.W;
	}
	UBOOL operator!=( const FPlane& V ) const
	{
		return X!=V.X || Y!=V.Y || Z!=V.Z || W!=V.W;
	}

	
	friend FArchive& operator<<( FArchive& Ar, FPlane &P )
	{
		return Ar << (FVector&)P << P.W;
	}
};





class __declspec(dllimport) FSphere : public FPlane
{
public:
	
	FSphere()
	{}
	FSphere( INT )
	:	FPlane(0,0,0,0)
	{}
	FSphere( FVector V, FLOAT W )
	:	FPlane( V, W )
	{}
	FSphere( const FVector* Pts, INT Count );
	friend FArchive& operator<<( FArchive& Ar, FSphere& S )
	{
		{;
		if( Ar.Ver()<=61 )
			Ar << (FVector&)S;
		else
			Ar << (FPlane&)S;
		return Ar;
		}
	}
};






enum ESheerAxis
{
	SHEER_None = 0,
	SHEER_XY   = 1,
	SHEER_XZ   = 2,
	SHEER_YX   = 3,
	SHEER_YZ   = 4,
	SHEER_ZX   = 5,
	SHEER_ZY   = 6,
};






class __declspec(dllimport) FScale 
{
public:
	
	FVector		Scale;
	FLOAT		SheerRate;
	BYTE		SheerAxis; 

	
	friend FArchive& operator<<( FArchive& Ar, FScale &S )
	{
		return Ar << S.Scale << S.SheerRate << S.SheerAxis;
	}

	
	FScale() {}
	FScale( const FVector &InScale, FLOAT InSheerRate, ESheerAxis InSheerAxis )
	:	Scale(InScale), SheerRate(InSheerRate), SheerAxis(InSheerAxis) {}

	
	UBOOL operator==( const FScale &S ) const
	{
		return Scale==S.Scale && SheerRate==S.SheerRate && SheerAxis==S.SheerAxis;
	}

	
	FLOAT Orientation()
	{
		return Sgn(Scale.X * Scale.Y * Scale.Z);
	}
};








class __declspec(dllimport) FCoords
{
public:
	FVector	Origin;
	FVector	XAxis;
	FVector YAxis;
	FVector ZAxis;

	
	FCoords() {}
	FCoords( const FVector &InOrigin )
	:	Origin(InOrigin), XAxis(1,0,0), YAxis(0,1,0), ZAxis(0,0,1) {}
	FCoords( const FVector &InOrigin, const FVector &InX, const FVector &InY, const FVector &InZ )
	:	Origin(InOrigin), XAxis(InX), YAxis(InY), ZAxis(InZ) {}

	
	FCoords MirrorByVector( const FVector& MirrorNormal ) const;
	FCoords MirrorByPlane( const FPlane& MirrorPlane ) const;
	FCoords	Transpose() const;
	FCoords Inverse() const;
	FCoords PivotInverse() const;
	FCoords ApplyPivot(const FCoords& CoordsB) const;
	FRotator OrthoRotation() const;

	
	FCoords& operator*=	(const FCoords   &TransformCoords);
	FCoords	 operator*	(const FCoords   &TransformCoords) const;
	FCoords& operator*=	(const FVector   &Point);
	FCoords  operator*	(const FVector   &Point) const;
	FCoords& operator*=	(const FRotator  &Rot);
	FCoords  operator*	(const FRotator  &Rot) const;
	FCoords& operator*=	(const FScale    &Scale);
	FCoords  operator*	(const FScale    &Scale) const;
	FCoords& operator/=	(const FVector   &Point);
	FCoords  operator/	(const FVector   &Point) const;
	FCoords& operator/=	(const FRotator  &Rot);
	FCoords  operator/	(const FRotator  &Rot) const;
	FCoords& operator/=	(const FScale    &Scale);
	FCoords  operator/	(const FScale    &Scale) const;

	
	friend FArchive& operator<<( FArchive& Ar, FCoords& F )
	{
		return Ar << F.Origin << F.XAxis << F.YAxis << F.ZAxis;
	}
};









class __declspec(dllimport) FModelCoords
{
public:
	
	FCoords PointXform;		
	FCoords VectorXform;	

	
	FModelCoords()
	{}
	FModelCoords( const FCoords& InCovariant, const FCoords& InContravariant )
	:	PointXform(InCovariant), VectorXform(InContravariant)
	{}

	
	FModelCoords Inverse()
	{
		return FModelCoords( VectorXform.Transpose(), PointXform.Transpose() );
	}
};








class __declspec(dllimport) FRotator
{
public:
	
	INT Pitch; 
	INT Yaw;   
	INT Roll;  

	
	friend FArchive& operator<<( FArchive& Ar, FRotator& R )
	{
		return Ar << R.Pitch << R.Yaw << R.Roll;
	}

	
	FRotator() {}
	FRotator( INT InPitch, INT InYaw, INT InRoll )
	:	Pitch(InPitch), Yaw(InYaw), Roll(InRoll) {}

	
	FRotator operator+( const FRotator &R ) const
	{
		return FRotator( Pitch+R.Pitch, Yaw+R.Yaw, Roll+R.Roll );
	}
	FRotator operator-( const FRotator &R ) const
	{
		return FRotator( Pitch-R.Pitch, Yaw-R.Yaw, Roll-R.Roll );
	}
	FRotator operator*( FLOAT Scale ) const
	{
		return FRotator( appRound(Pitch*Scale), appRound(Yaw*Scale), appRound(Roll*Scale) );
	}
	friend FRotator operator*( FLOAT Scale, const FRotator &R )
	{
		return FRotator( appRound(R.Pitch*Scale), appRound(R.Yaw*Scale), appRound(R.Roll*Scale) );
	}
	FRotator operator*= (FLOAT Scale)
	{
		Pitch = appRound(Pitch*Scale); Yaw = appRound(Yaw*Scale); Roll = appRound(Roll*Scale);
		return *this;
	}
	
	UBOOL operator==( const FRotator &R ) const
	{
		return Pitch==R.Pitch && Yaw==R.Yaw && Roll==R.Roll;
	}
	UBOOL operator!=( const FRotator &V ) const
	{
		return Pitch!=V.Pitch || Yaw!=V.Yaw || Roll!=V.Roll;
	}
	
	FRotator operator+=( const FRotator &R )
	{
		Pitch += R.Pitch; Yaw += R.Yaw; Roll += R.Roll;
		return *this;
	}
	FRotator operator-=( const FRotator &R )
	{
		Pitch -= R.Pitch; Yaw -= R.Yaw; Roll -= R.Roll;
		return *this;
	}
	
	FRotator Reduce() const
	{
		return FRotator( ReduceAngle(Pitch), ReduceAngle(Yaw), ReduceAngle(Roll) );
	}
	int IsZero() const
	{
		return ((Pitch&65535)==0) && ((Yaw&65535)==0) && ((Roll&65535)==0);
	}
	FRotator Add( INT DeltaPitch, INT DeltaYaw, INT DeltaRoll )
	{
		Yaw   += DeltaYaw;
		Pitch += DeltaPitch;
		Roll  += DeltaRoll;
		return *this;
	}
	FRotator AddBounded( INT DeltaPitch, INT DeltaYaw, INT DeltaRoll )
	{
		Yaw  += DeltaYaw;
		Pitch = FAddAngleConfined(Pitch,DeltaPitch,192*0x100,64*0x100);
		Roll  = FAddAngleConfined(Roll, DeltaRoll, 192*0x100,64*0x100);
		return *this;
	}
	FRotator GridSnap( const FRotator &RotGrid )
	{
		return FRotator
		(
			appRound(FSnap(Pitch,RotGrid.Pitch)),
			appRound(FSnap(Yaw,  RotGrid.Yaw)),
			appRound(FSnap(Roll, RotGrid.Roll))
		);
	}
	FVector Vector();
};








class __declspec(dllimport) FBox
{
public:
	
	FVector Min;
	FVector Max;
	BYTE IsValid;

	
	FBox() {}
	FBox(INT) : Min(0,0,0), Max(0,0,0), IsValid(0) {}
	FBox( const FVector& InMin, const FVector& InMax ) : Min(InMin), Max(InMax), IsValid(1) {}
	FBox( const FVector* Points, INT Count );

	
	FVector& GetExtrema( int i )
	{
		return (&Min)[i];
	}
	const FVector& GetExtrema( int i ) const
	{
		return (&Min)[i];
	}

	
	FBox& operator+=( const FVector &Other )
	{
		if( IsValid )
		{
			Min.X = ::Min( Min.X, Other.X );
			Min.Y = ::Min( Min.Y, Other.Y );
			Min.Z = ::Min( Min.Z, Other.Z );

			Max.X = ::Max( Max.X, Other.X );
			Max.Y = ::Max( Max.Y, Other.Y );
			Max.Z = ::Max( Max.Z, Other.Z );
		}
		else
		{
			Min = Max = Other;
			IsValid = 1;
		}
		return *this;
	}
	FBox operator+( const FVector& Other ) const
	{
		return FBox(*this) += Other;
	}
	FBox& operator+=( const FBox& Other )
	{
		if( IsValid && Other.IsValid )
		{
			Min.X = ::Min( Min.X, Other.Min.X );
			Min.Y = ::Min( Min.Y, Other.Min.Y );
			Min.Z = ::Min( Min.Z, Other.Min.Z );

			Max.X = ::Max( Max.X, Other.Max.X );
			Max.Y = ::Max( Max.Y, Other.Max.Y );
			Max.Z = ::Max( Max.Z, Other.Max.Z );
		}
		else *this = Other;
		return *this;
	}
	FBox operator+( const FBox& Other ) const
	{
		return FBox(*this) += Other;
	}
	FBox TransformBy( const FCoords& Coords ) const
	{
		FBox NewBox(0);
		for( int i=0; i<2; i++ )
			for( int j=0; j<2; j++ )
				for( int k=0; k<2; k++ )
					NewBox += FVector( GetExtrema(i).X, GetExtrema(j).Y, GetExtrema(k).Z ).TransformPointBy( Coords );
		return NewBox;
	}
	FBox ExpandBy( FLOAT W ) const
	{
		return FBox( Min - FVector(W,W,W), Max + FVector(W,W,W) );
	}

	
	friend FArchive& operator<<( FArchive& Ar, FBox& Bound )
	{
		return Ar << Bound.Min << Bound.Max << Bound.IsValid;
	}
};








class __declspec(dllimport) FGlobalMath
{
public:
	
	enum {ANGLE_SHIFT 	= 2};		
	enum {ANGLE_BITS	= 14};		
	enum {NUM_ANGLES 	= 16384}; 	
	enum {NUM_SQRTS		= 16384};	
	enum {ANGLE_MASK    =  (((1<<ANGLE_BITS)-1)<<(16-ANGLE_BITS))};

	
	const FVector  	WorldMin;
	const FVector  	WorldMax;
	const FCoords  	UnitCoords;
	const FScale   	UnitScale;
	const FCoords	ViewCoords;

	
	FLOAT Sqrt( int i )
	{
		return SqrtFLOAT[i]; 
	}
	FLOAT SinTab( int i )
	{
		return TrigFLOAT[((i>>ANGLE_SHIFT)&(NUM_ANGLES-1))];
	}
	FLOAT CosTab( int i )
	{
		return TrigFLOAT[(((i+16384)>>ANGLE_SHIFT)&(NUM_ANGLES-1))];
	}
	FLOAT SinFloat( FLOAT F )
	{
		return SinTab(appRound((F*65536.f)/(2.f*(3.1415926535897932f))));
	}
	FLOAT CosFloat( FLOAT F )
	{
		return CosTab(appRound((F*65536.f)/(2.f*(3.1415926535897932f))));
	}

	
	FGlobalMath();

private:
	
	FLOAT  TrigFLOAT		[NUM_ANGLES];
	FLOAT  SqrtFLOAT		[NUM_SQRTS];
	FLOAT  LightSqrtFLOAT	[NUM_SQRTS];
};

inline INT ReduceAngle( INT Angle )
{
	return Angle & FGlobalMath::ANGLE_MASK;
};



















													

													
















inline void ASMTransformPoint(const FCoords &Coords, const FVector &InVector, FVector &OutVector)
{
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	__asm
	{
		mov     esi,[InVector]
		mov     edx,[Coords]     
		mov     edi,[OutVector]

		
		fld     dword ptr [esi+0]
		fld     dword ptr [esi+4]
		fld     dword ptr [esi+8] 
		fxch    st(2)     

		
		fsub    dword ptr [edx + 0]  
		fxch    st(1)  
		fsub	dword ptr [edx + 4]  
		fxch    st(2)
		fsub	dword ptr [edx + 8]  
		fxch    st(1)        

		
		fld     st(0)	
        fmul    dword ptr [edx+12]     
        fld     st(1)   
        fmul    dword ptr [edx+24]   
		fxch    st(2)    
		fmul    dword ptr [edx+36]  
		fxch    st(4)     

		fld     st(0)			
		fmul    dword ptr [edx+16]     
		fld     st(1) 			
        fmul    dword ptr [edx+28]    
		fxch    st(2)			
		fmul    dword ptr [edx+40]	 
		fxch    st(1)			

        faddp   st(3),st(0)	  
        faddp   st(5),st(0)   
        faddp   st(2),st(0)   
		fxch    st(2)         

		fld     st(0)         
		fmul    dword ptr [edx+20]     
		fld     st(1)         
        fmul    dword ptr [edx+32]      
		fxch    st(2)         
		fmul    dword ptr [edx+44]	  
		fxch    st(1)         

		faddp   st(4),st(0)   
		faddp   st(4),st(0)	  
		faddp   st(1),st(0)   
		fxch    st(1)		  

		fstp    dword ptr [edi+0]       
        fstp    dword ptr [edi+4]                               
        fstp    dword ptr [edi+8]     
	}
}



































































inline void ASMTransformVector(const FCoords &Coords, const FVector &InVector, FVector &OutVector)
{
	__asm
	{
		mov     esi,[InVector]
		mov     edx,[Coords]     
		mov     edi,[OutVector]

		
		fld     dword ptr [esi+0]
		fld     dword ptr [esi+4]
		fxch    st(1)
		fld     dword ptr [esi+8] 
		fxch    st(1)             

		
		fld     st(0)	
        fmul    dword ptr [edx+12]     
        fld     st(1)   
        fmul    dword ptr [edx+24]   
		fxch    st(2)    
		fmul    dword ptr [edx+36]  
		fxch    st(4)     

		fld     st(0)			
		fmul    dword ptr [edx+16]     
		fld     st(1) 			
        fmul    dword ptr [edx+28]    
		fxch    st(2)			
		fmul    dword ptr [edx+40]	 
		fxch    st(1)			

        faddp   st(3),st(0)	  
        faddp   st(5),st(0)   
        faddp   st(2),st(0)   
		fxch    st(2)         

		fld     st(0)         
		fmul    dword ptr [edx+20]     
		fld     st(1)         
        fmul    dword ptr [edx+32]      
		fxch    st(2)         
		fmul    dword ptr [edx+44]	  
		fxch    st(1)         

		faddp   st(4),st(0)   
		faddp   st(4),st(0)	  
		faddp   st(1),st(0)   
		fxch    st(1)		  

		fstp    dword ptr [edi+0]       
        fstp    dword ptr [edi+4]                               
        fstp    dword ptr [edi+8]     
	}
}

































































inline FVector FVector::TransformPointBy( const FCoords &Coords ) const
{

	FVector Temp;
	ASMTransformPoint( Coords, *this, Temp);
	return Temp;































































}





inline FVector FVector::TransformVectorBy( const FCoords &Coords ) const
{

	FVector Temp;
	ASMTransformVector( Coords, *this, Temp);
	return Temp;
























































}




inline FVector FVector::PivotTransform(const FCoords& Coords) const
{
	return Coords.Origin + FVector( *this | Coords.XAxis, *this | Coords.YAxis, *this | Coords.ZAxis );
}




inline FVector FVector::MirrorByVector( const FVector& MirrorNormal ) const
{
	return *this - MirrorNormal * (2.f * (*this | MirrorNormal));
}




inline FVector FVector::MirrorByPlane( const FPlane& Plane ) const
{
	return *this - Plane * (2.f * Plane.PlaneDot(*this) );
}









inline int FPointsAreSame( const FVector &P, const FVector &Q )
{
	FLOAT Temp;
	Temp=P.X-Q.X;
	if( (Temp > -(0.002f)) && (Temp < (0.002f)) )
	{
		Temp=P.Y-Q.Y;
		if( (Temp > -(0.002f)) && (Temp < (0.002f)) )
		{
			Temp=P.Z-Q.Z;
			if( (Temp > -(0.002f)) && (Temp < (0.002f)) )
			{
				return 1;
			}
		}
	}
	return 0;
}





inline int FPointsAreNear( const FVector &Point1, const FVector &Point2, FLOAT Dist )
{
	FLOAT Temp;
	Temp=(Point1.X - Point2.X); if (Abs(Temp)>=Dist) return 0;
	Temp=(Point1.Y - Point2.Y); if (Abs(Temp)>=Dist) return 0;
	Temp=(Point1.Z - Point2.Z); if (Abs(Temp)>=Dist) return 0;
	return 1;
}





inline FLOAT FPointPlaneDist
(
	const FVector &Point,
	const FVector &PlaneBase,
	const FVector &PlaneNormal
)
{
	return (Point - PlaneBase) | PlaneNormal;
}













inline FLOAT FDistSquared( const FVector &V1, const FVector &V2 )
{
	return Square(V2.X-V1.X) + Square(V2.Y-V1.Y) + Square(V2.Z-V1.Z);
}




inline int FParallel( const FVector &Normal1, const FVector &Normal2 )
{
	FLOAT NormalDot = Normal1 | Normal2;
	return (Abs (NormalDot - 1.f) <= (0.02f));
}




inline int FCoplanar( const FVector &Base1, const FVector &Normal1, const FVector &Base2, const FVector &Normal2 )
{
	if      (!FParallel(Normal1,Normal2)) return 0;
	else if (FPointPlaneDist (Base2,Base1,Normal1) > (0.10f)) return 0;
	else    return 1;
}




inline FLOAT FTriple( const FVector& X, const FVector& Y, const FVector& Z )
{
	return
	(	(X.X * (Y.Y * Z.Z - Y.Z * Z.Y))
	+	(X.Y * (Y.Z * Z.X - Y.X * Z.Z))
	+	(X.Z * (Y.X * Z.Y - Y.Y * Z.X)) );
}









inline FPlane FPlane::TransformPlaneByOrtho( const FCoords &Coords ) const
{
	FVector Normal( *this | Coords.XAxis, *this | Coords.YAxis, *this | Coords.ZAxis );
	return FPlane( Normal, W - (Coords.Origin.TransformVectorBy(Coords) | Normal) );
}









inline FCoords FCoords::Transpose() const
{
	return FCoords
	(
		-Origin.TransformVectorBy(*this),
		FVector( XAxis.X, YAxis.X, ZAxis.X ),
		FVector( XAxis.Y, YAxis.Y, ZAxis.Y ),
		FVector( XAxis.Z, YAxis.Z, ZAxis.Z )
	);
}




inline FCoords FCoords::MirrorByVector( const FVector& MirrorNormal ) const
{
	return FCoords
	(
		Origin.MirrorByVector( MirrorNormal ),
		XAxis .MirrorByVector( MirrorNormal ),
		YAxis .MirrorByVector( MirrorNormal ),
		ZAxis .MirrorByVector( MirrorNormal )
	);
}




inline FCoords FCoords::MirrorByPlane( const FPlane& Plane ) const
{
	return FCoords
	(
		Origin.MirrorByPlane ( Plane ),
		XAxis .MirrorByVector( Plane ),
		YAxis .MirrorByVector( Plane ),
		ZAxis .MirrorByVector( Plane )
	);
}








inline FCoords& FCoords::operator*=( const FCoords& TransformCoords )
{
	
	
	
	Origin = Origin.TransformPointBy ( TransformCoords );
	XAxis  = XAxis .TransformVectorBy( TransformCoords );
	YAxis  = YAxis .TransformVectorBy( TransformCoords );
	ZAxis  = ZAxis .TransformVectorBy( TransformCoords );
	return *this;
}
inline FCoords FCoords::operator*( const FCoords &TransformCoords ) const
{
	return FCoords(*this) *= TransformCoords;
}




inline FCoords& FCoords::operator*=( const FRotator &Rot )
{
	
	*this *= FCoords
	(	
		FVector( 0.f, 0.f, 0.f ),
		FVector( +GMath.CosTab(Rot.Yaw), +GMath.SinTab(Rot.Yaw), +0.f ),
		FVector( -GMath.SinTab(Rot.Yaw), +GMath.CosTab(Rot.Yaw), +0.f ),
		FVector( +0.f, +0.f, +1.f )
	);

	
	*this *= FCoords
	(	
		FVector( 0.f, 0.f, 0.f ),
		FVector( +GMath.CosTab(Rot.Pitch), +0.f, +GMath.SinTab(Rot.Pitch) ),
		FVector( +0.f, +1.f, +0.f ),
		FVector( -GMath.SinTab(Rot.Pitch), +0.f, +GMath.CosTab(Rot.Pitch) )
	);

	
	*this *= FCoords
	(	
		FVector( 0.f, 0.f, 0.f ),
		FVector( +1.f, +0.f, +0.f ),
		FVector( +0.f, +GMath.CosTab(Rot.Roll), -GMath.SinTab(Rot.Roll) ),
		FVector( +0.f, +GMath.SinTab(Rot.Roll), +GMath.CosTab(Rot.Roll) )
	);
	return *this;
}
inline FCoords FCoords::operator*( const FRotator &Rot ) const
{
	return FCoords(*this) *= Rot;
}

inline FCoords& FCoords::operator*=( const FVector &Point )
{
	Origin -= Point;
	return *this;
}
inline FCoords FCoords::operator*( const FVector &Point ) const
{
	return FCoords(*this) *= Point;
}




inline FCoords& FCoords::operator/=( const FRotator &Rot )
{
	
	*this *= FCoords
	(
		FVector( 0.f, 0.f, 0.f ),
		FVector( +1.f, -0.f, +0.f ),
		FVector( -0.f, +GMath.CosTab(Rot.Roll), +GMath.SinTab(Rot.Roll) ),
		FVector( +0.f, -GMath.SinTab(Rot.Roll), +GMath.CosTab(Rot.Roll) )
	);

	
	*this *= FCoords
	(
		FVector( 0.f, 0.f, 0.f ),
		FVector( +GMath.CosTab(Rot.Pitch), +0.f, -GMath.SinTab(Rot.Pitch) ),
		FVector( +0.f, +1.f, -0.f ),
		FVector( +GMath.SinTab(Rot.Pitch), +0.f, +GMath.CosTab(Rot.Pitch) )
	);

	
	*this *= FCoords
	(
		FVector( 0.f, 0.f, 0.f ),
		FVector( +GMath.CosTab(Rot.Yaw), -GMath.SinTab(Rot.Yaw), -0.f ),
		FVector( +GMath.SinTab(Rot.Yaw), +GMath.CosTab(Rot.Yaw), +0.f ),
		FVector( -0.f, +0.f, +1.f )
	);
	return *this;
}
inline FCoords FCoords::operator/( const FRotator &Rot ) const
{
	return FCoords(*this) /= Rot;
}

inline FCoords& FCoords::operator/=( const FVector &Point )
{
	Origin += Point;
	return *this;
}
inline FCoords FCoords::operator/( const FVector &Point ) const
{
	return FCoords(*this) /= Point;
}






inline FCoords& FCoords::operator*=( const FScale &Scale )
{
	
	FLOAT   Sheer      = FSheerSnap( Scale.SheerRate );
	FCoords TempCoords = GMath.UnitCoords;
	switch( Scale.SheerAxis )
	{
		case SHEER_XY:
			TempCoords.XAxis.Y = Sheer;
			break;
		case SHEER_XZ:
			TempCoords.XAxis.Z = Sheer;
			break;
		case SHEER_YX:
			TempCoords.YAxis.X = Sheer;
			break;
		case SHEER_YZ:
			TempCoords.YAxis.Z = Sheer;
			break;
		case SHEER_ZX:
			TempCoords.ZAxis.X = Sheer;
			break;
		case SHEER_ZY:
			TempCoords.ZAxis.Y = Sheer;
			break;
		default:
			break;
	}
	*this *= TempCoords;

	
	XAxis    *= Scale.Scale;
	YAxis    *= Scale.Scale;
	ZAxis    *= Scale.Scale;
	Origin.X /= Scale.Scale.X;
	Origin.Y /= Scale.Scale.Y;
	Origin.Z /= Scale.Scale.Z;

	return *this;
}
inline FCoords FCoords::operator*( const FScale &Scale ) const
{
	return FCoords(*this) *= Scale;
}




inline FCoords& FCoords::operator/=( const FScale &Scale )
{
	
	XAxis    /= Scale.Scale;
	YAxis    /= Scale.Scale;
	ZAxis    /= Scale.Scale;
	Origin.X *= Scale.Scale.X;
	Origin.Y *= Scale.Scale.Y;
	Origin.Z *= Scale.Scale.Z;

	
	FCoords TempCoords(GMath.UnitCoords);
	FLOAT Sheer = FSheerSnap( Scale.SheerRate );
	switch( Scale.SheerAxis )
	{
		case SHEER_XY:
			TempCoords.XAxis.Y = -Sheer;
			break;
		case SHEER_XZ:
			TempCoords.XAxis.Z = -Sheer;
			break;
		case SHEER_YX:
			TempCoords.YAxis.X = -Sheer;
			break;
		case SHEER_YZ:
			TempCoords.YAxis.Z = -Sheer;
			break;
		case SHEER_ZX:
			TempCoords.ZAxis.X = -Sheer;
			break;
		case SHEER_ZY:
			TempCoords.ZAxis.Y = -Sheer;
			break;
		default: 
			break;
	}
	*this *= TempCoords;

	return *this;
}
inline FCoords FCoords::operator/( const FScale &Scale ) const
{
	return FCoords(*this) /= Scale;
}








inline FLOAT FBoxPushOut( FVector Normal, FVector Size )
{
	return Abs(Normal.X*Size.X) + Abs(Normal.Y*Size.Y) + Abs(Normal.Z*Size.Z);
}




inline FVector VRand()
{
	FVector Result;
	do
	{
		
		Result.X = appFrand()*2 - 1;
		Result.Y = appFrand()*2 - 1;
		Result.Z = appFrand()*2 - 1;
	} while( Result.SizeSquared() > 1.f );
	return Result.UnsafeNormal();
}



































inline FVector RandomSpreadVector(FLOAT spread_degrees)
{
    FLOAT max_pitch = Clamp(spread_degrees * ((3.1415926535897932f) / 180.0f / 2.0f),0.0f,180.0f);
    FLOAT K = 1.0f - appCos(max_pitch);
    FLOAT pitch = appAcos(1.0f - appFrand()*K);  
    FLOAT rand_roll = appFrand() * (2.0f * (3.1415926535897932f));
    FLOAT radius = appSin(pitch);
    return FVector(appCos(pitch),radius*appSin(rand_roll),radius*appCos(rand_roll));
}











inline FVector FLinePlaneIntersection
(
	const FVector &Point1,
	const FVector &Point2,
	const FVector &PlaneOrigin,
	const FVector &PlaneNormal
)
{
	return
		Point1
	+	(Point2-Point1)
	*	(((PlaneOrigin - Point1)|PlaneNormal) / ((Point2 - Point1)|PlaneNormal));
}
inline FVector FLinePlaneIntersection
(
	const FVector &Point1,
	const FVector &Point2,
	const FPlane  &Plane
)
{
	return
		Point1
	+	(Point2-Point1)
	*	((Plane.W - (Point1|Plane))/((Point2 - Point1)|Plane));
}









inline UBOOL FIntersectPlanes3( FVector& I, const FPlane& P1, const FPlane& P2, const FPlane& P3 )
{
	{static const TCHAR __FUNC_NAME__[]=L"FIntersectPlanes3"; try{;

	
	FLOAT Det = (P1 ^ P2) | P3;
	if( Square(Det) < Square(0.001f) )
	{
		
		I = FVector(0,0,0);
		return 0;
	}
	else
	{
		
		I = (P1.W*(P2^P3) + P2.W*(P3^P1) + P3.W*(P1^P2)) / Det;
	}
	return 1;
	}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
}





inline UBOOL FIntersectPlanes2( FVector& I, FVector& D, const FPlane& P1, const FPlane& P2 )
{
	{static const TCHAR __FUNC_NAME__[]=L"FIntersectPlanes2"; try{;

	
	D = P1 ^ P2;
	FLOAT DD = D.SizeSquared();
	if( DD < Square(0.001f) )
	{
		
		D = I = FVector(0,0,0);
		return 0;
	}
	else
	{
		
		I = (P1.W*(P2^D) + P2.W*(D^P1)) / DD;
		D.Normalize();
		return 1;
	}
	}catch(TCHAR*Err){throw Err;}catch(...){appUnwindf(L"%s",__FUNC_NAME__); throw;}};
}








inline FVector FRotator::Vector()
{
	return (GMath.UnitCoords / *this).XAxis;
}






class __declspec(dllimport) FMatrix
{
public:

	
	FPlane XPlane; 
	FPlane YPlane;
	FPlane ZPlane;
	FPlane WPlane;

	FLOAT& M(INT i,INT j) {return ((FLOAT*)&XPlane)[i*4+j];}
	const FLOAT& M(INT i,INT j) const {return ((FLOAT*)&XPlane)[i*4+j];}

	
	FMatrix()
	{}
	FMatrix( FPlane InX, FPlane InY, FPlane InZ )
	:	XPlane(InX), YPlane(InY), ZPlane(InZ), WPlane(0,0,0,0)
	{}
	FMatrix( FPlane InX, FPlane InY, FPlane InZ, FPlane InW )
	:	XPlane(InX), YPlane(InY), ZPlane(InZ), WPlane(InW)
	{}


	
	FVector TransformFVector(const FVector &V) const
	{
		FVector FV;

		FV.X = V.X * M(0,0) + V.Y * M(0,1) + V.Z * M(0,2) + M(0,3);
		FV.Y = V.X * M(1,0) + V.Y * M(1,1) + V.Z * M(1,2) + M(1,3);
		FV.Z = V.X * M(2,0) + V.Y * M(2,1) + V.Z * M(2,2) + M(2,3);

		return FV;
	}

	
	FPlane TransformFPlane(const FPlane &P) const
	{
		FPlane FP;

		FP.X = P.X * M(0,0) + P.Y * M(0,1) + P.Z * M(0,2) + M(0,3);
		FP.Y = P.X * M(1,0) + P.Y * M(1,1) + P.Z * M(1,2) + M(1,3);
		FP.Z = P.X * M(2,0) + P.Y * M(2,1) + P.Z * M(2,2) + M(2,3);
		FP.W = P.X * M(3,0) + P.Y * M(3,1) + P.Z * M(3,2) + M(3,3);

		return FP;
	}

	FQuat FMatrixToFQuat();

	
	friend FMatrix CombineTransforms(const FMatrix& M, const FMatrix& N);
	friend FMatrix FMatrixFromFCoords(const FCoords& FC);
	friend FCoords FCoordsFromFMatrix(const FMatrix& FM);

};

FMatrix CombineTransforms(const FMatrix& M, const FMatrix& N);



inline FMatrix FMatrixFromFCoords(const FCoords& FC) 
{
	FMatrix M;
	M.XPlane = FPlane( FC.XAxis.X, FC.XAxis.Y, FC.XAxis.Z, FC.Origin.X );
	M.YPlane = FPlane( FC.YAxis.X, FC.YAxis.Y, FC.YAxis.Z, FC.Origin.Y );
	M.ZPlane = FPlane( FC.ZAxis.X, FC.ZAxis.Y, FC.ZAxis.Z, FC.Origin.Z );
	M.WPlane = FPlane( 0.f,        0.f,        0.f,        1.f         );
	return M;
}

inline FCoords FCoordsFromFMatrix(const FMatrix& FM)
{
	FCoords C;
	C.Origin = FVector( FM.XPlane.W, FM.YPlane.W, FM.ZPlane.W );
	C.XAxis  = FVector( FM.XPlane.X, FM.XPlane.Y, FM.XPlane.Z );
	C.YAxis  = FVector( FM.YPlane.X, FM.YPlane.Y, FM.YPlane.Z );
	C.ZAxis  = FVector( FM.ZPlane.X, FM.ZPlane.Y, FM.ZPlane.Z );
	return C;
}








class __declspec(dllimport) FQuat 
{
public:
	
	FLOAT X,Y,Z,W;
	

	
	FQuat()
	{}

	FQuat( FLOAT InX, FLOAT InY, FLOAT InZ, FLOAT InA )
	:	X(InX), Y(InY), Z(InZ), W(InA)
	{}

	
	FQuat operator+( const FQuat& Q ) const
	{
		return FQuat( X + Q.X, Y + Q.Y, Z + Q.Z, W + Q.W );
	}

	FQuat operator-( const FQuat& Q ) const
	{
		return FQuat( X - Q.X, Y - Q.Y, Z - Q.Z, W - Q.W );
	}

	FQuat operator*( const FQuat& Q ) const
	{
		return FQuat( 
			X*Q.X - Y*Q.Y - Z*Q.Z - W*Q.W, 
			X*Q.Y + Y*Q.X + Z*Q.W - W*Q.Z, 
			X*Q.Z - Y*Q.W + Z*Q.X + W*Q.Y, 
			X*Q.W + Y*Q.Z - Z*Q.Y + W*Q.X
			);
	}

	FQuat operator*( const FLOAT& Scale ) const
	{
		return FQuat( Scale*X, Scale*Y, Scale*Z, Scale*W);			
	}
	
	
	FQuat operator-() const
	{
		return FQuat( X, Y, Z, -W );
	}

    
	UBOOL operator!=( const FQuat& Q ) const
	{
		return X!=Q.X || Y!=Q.Y || Z!=Q.Z || W!=Q.W;
	}
	
	UBOOL Normalize();
	






















	
	friend FArchive& operator<<( FArchive& Ar, FQuat& F )
	{
		return Ar << F.X << F.Y << F.Z << F.W;
	}

	FMatrix FQuatToFMatrix();

	
	FQuat FQuatToAngAxis()
	{
		FLOAT scale = (FLOAT)appSin(W);
		FQuat A;

		if (scale >= (0.00001f))
		{
			A.X = Z / scale;
			A.Y = Y / scale;
			A.Z = Z / scale;
			A.W = (2.0f * appAcos (W)); 
			
		}
		else 
		{
			A.X = 0.0f;
			A.Y = 0.0f;
			A.Z = 1.0f;
			A.W = 0.0f; 
		}

		return A;
	};

	
	
	
	FQuat AngAxisToFQuat();
	






















};



inline FLOAT FQuatDot(const FQuat& Q1,const FQuat& Q2)
{
	return( Q1.X*Q2.X + Q1.Y*Q2.Y + Q1.Z*Q2.Z );
};


inline FLOAT FQuatError(FQuat& Q1,FQuat& Q2)
{
	
	
	FLOAT cosom = Q1.X*Q2.X + Q1.Y*Q2.Y + Q1.Z*Q2.Z + Q1.W*Q2.W;
	return (Abs(cosom) < 0.9999999f) ? appAcos(cosom)*(1.f/(3.1415926535897932f)) : 0.0f;
}


inline void AlignFQuatWith(FQuat &quat1, const FQuat &quat2)
{
	FLOAT Minus  = Square(quat1.X-quat2.X) + Square(quat1.Y-quat2.Y) + Square(quat1.Z-quat2.Z) + Square(quat1.W-quat2.W);
	FLOAT Plus   = Square(quat1.X+quat2.X) + Square(quat1.Y+quat2.Y) + Square(quat1.Z+quat2.Z) + Square(quat1.W+quat2.W);

	if (Minus > Plus)
	{
		quat1.X = - quat1.X;
		quat1.Y = - quat1.Y;
		quat1.Z = - quat1.Z;
		quat1.W = - quat1.W;
	}
}


inline FQuat SlerpQuat(const FQuat &quat1,const FQuat &quat2, float slerp)
{
	FQuat result;
	float omega,cosom,sininv,scale0,scale1;

	
	cosom = quat1.X * quat2.X +
			quat1.Y * quat2.Y +
			quat1.Z * quat2.Z +
			quat1.W * quat2.W;

	if( cosom < 0.99999999f )
	{	
		omega = appAcos(cosom);
		sininv = 1.f/appSin(omega);
		scale0 = appSin((1.f - slerp) * omega) * sininv;
		scale1 = appSin(slerp * omega) * sininv;
		
		result.X = scale0 * quat1.X + scale1 * quat2.X;
		result.Y = scale0 * quat1.Y + scale1 * quat2.Y;
		result.Z = scale0 * quat1.Z + scale1 * quat2.Z;
		result.W = scale0 * quat1.W + scale1 * quat2.W;
		return result;
	}
	else
	{
		return quat1;
	}
	
}
























__declspec(dllexport) extern class FMemStack	GEngineMem;
__declspec(dllexport) extern class FMemCache	GCache;

























enum ETraceActorFlags
{
	TRACE_Pawns              = 0x0001,
	TRACE_Movers             = 0x0002,
	TRACE_Level              = 0x0004,
	TRACE_Volumes            = 0x0008,
	TRACE_Others             = 0x0010,
	TRACE_OnlyProjActor      = 0x0020,
	TRACE_Blocking           = 0x0040,
	TRACE_LevelGeometry      = 0x0080,
	TRACE_ShadowCast         = 0x0100,
	TRACE_StopAtFirstHit     = 0x0200,
	TRACE_SingleResult       = 0x0400,
	TRACE_Debug              = 0x0800,
	TRACE_Material           = 0x1000,
	TRACE_VisibleNonColliding= 0x2000,
	TRACE_Usable             = 0x4000,

	TRACE_Actors             = TRACE_Others | TRACE_LevelGeometry | TRACE_Pawns | TRACE_Movers,
	TRACE_AllBlocking        = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_Blocking | TRACE_LevelGeometry,
	TRACE_AllColliding       = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_LevelGeometry,
	TRACE_Hash               = TRACE_Pawns | TRACE_Movers | TRACE_Volumes | TRACE_Others | TRACE_LevelGeometry,
	TRACE_ProjTargets        = TRACE_Pawns | TRACE_Movers | TRACE_Level | TRACE_Volumes | TRACE_Others | TRACE_OnlyProjActor | TRACE_LevelGeometry,
	TRACE_World              = TRACE_Movers | TRACE_Level | TRACE_LevelGeometry,
};





struct FIteratorActorList : public FIteratorList
{
	AActor* Actor;
	FIteratorActorList() {}
	FIteratorActorList( FIteratorActorList* InNext, AActor* InActor )
	:	FIteratorList(InNext), Actor(InActor) {}
	FIteratorActorList* GetNext()
	{ return (FIteratorActorList*) Next; }
};

struct FCheckResult : public FIteratorActorList
{
	FVector		Location;
	FVector		Normal;
	class UPrimitive*	Primitive;
	FLOAT		Time;
	INT			Item;
	class UMaterial*	Material;   

	FCheckResult() {}
	FCheckResult( FLOAT InTime, FCheckResult* InNext=0 )
	:	FIteratorActorList( InNext, 0 )
	,	Location(0,0,0), Normal(0,0,0), Primitive(0)
	,	Time(InTime), Item(INDEX_NONE), Material(0) {}
	FCheckResult*& GetNext()
		{ return *(FCheckResult**)&Next; }
	friend QSORT_RETURN __cdecl CompareHits( const FCheckResult* A, const FCheckResult* B )
		{ return A->Time<B->Time ? -1 : A->Time>B->Time ? 1 : 0; }
};





class __declspec(dllexport) UPrimitive : public UObject
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UPrimitive ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPrimitive*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPrimitive() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPrimitive(); }

	FBox BoundingBox;
	FSphere BoundingSphere;

	UPrimitive()
	: BoundingBox(0), BoundingSphere(0) {}

	
	void Serialize( FArchive& Ar );

	
	virtual INT PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags );
	virtual INT LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, DWORD ExtraFlags );
	virtual FBox GetRenderBoundingBox( const AActor* Owner );
	virtual FSphere GetRenderBoundingSphere( const AActor* Owner );
	virtual FBox GetCollisionBoundingBox( const AActor* Owner ) const;
	virtual INT UseCylinderCollision( const AActor* Owner );
	virtual void Illuminate( AActor* Owner, INT bDynamic );
	virtual FVector GetEncroachExtent( AActor* Owner );
	virtual FVector GetEncroachCenter( AActor* Owner );
};













#pragma pack (push,4)















extern __declspec(dllexport) FName ENGINE_AIHearSound;
extern __declspec(dllexport) FName ENGINE_Accept;
extern __declspec(dllexport) FName ENGINE_AcceptInventory;
extern __declspec(dllexport) FName ENGINE_ActionStart;
extern __declspec(dllexport) FName ENGINE_ActorEntered;
extern __declspec(dllexport) FName ENGINE_ActorEnteredVolume;
extern __declspec(dllexport) FName ENGINE_ActorLeaving;
extern __declspec(dllexport) FName ENGINE_ActorLeavingVolume;
extern __declspec(dllexport) FName ENGINE_AddCameraEffect;
extern __declspec(dllexport) FName ENGINE_AddInteraction;
extern __declspec(dllexport) FName ENGINE_AnimEnd;
extern __declspec(dllexport) FName ENGINE_Attach;
extern __declspec(dllexport) FName ENGINE_BaseChange;
extern __declspec(dllexport) FName ENGINE_BeginEvent;
extern __declspec(dllexport) FName ENGINE_BeginPlay;
extern __declspec(dllexport) FName ENGINE_BreathTimer;
extern __declspec(dllexport) FName ENGINE_Broadcast;
extern __declspec(dllexport) FName ENGINE_BroadcastLocalized;
extern __declspec(dllexport) FName ENGINE_BroadcastLocalizedMessage;
extern __declspec(dllexport) FName ENGINE_Bump;
extern __declspec(dllexport) FName ENGINE_CanPlayIntroVideo;
extern __declspec(dllexport) FName ENGINE_CanPlayOutroVideo;
extern __declspec(dllexport) FName ENGINE_ChangeAnimation;
extern __declspec(dllexport) FName ENGINE_ClientHearSound;
extern __declspec(dllexport) FName ENGINE_ClientMessage;
extern __declspec(dllexport) FName ENGINE_ClientPBKickedOutMessage;
extern __declspec(dllexport) FName ENGINE_ClientSetNewViewTarget;
extern __declspec(dllexport) FName ENGINE_ClientTravel;
extern __declspec(dllexport) FName ENGINE_ConnectionFailed;
extern __declspec(dllexport) FName ENGINE_ConvertKeyToLocalisation;
extern __declspec(dllexport) FName ENGINE_DemoPlaySound;
extern __declspec(dllexport) FName ENGINE_DeployWeaponBipod;
extern __declspec(dllexport) FName ENGINE_Destroyed;
extern __declspec(dllexport) FName ENGINE_Detach;
extern __declspec(dllexport) FName ENGINE_DetailChange;
extern __declspec(dllexport) FName ENGINE_EncroachedBy;
extern __declspec(dllexport) FName ENGINE_EncroachingOn;
extern __declspec(dllexport) FName ENGINE_EndClimbLadder;
extern __declspec(dllexport) FName ENGINE_EndCrouch;
extern __declspec(dllexport) FName ENGINE_EndEvent;
extern __declspec(dllexport) FName ENGINE_EndedRotation;
extern __declspec(dllexport) FName ENGINE_EnemyNotVisible;
extern __declspec(dllexport) FName ENGINE_EyePosition;
extern __declspec(dllexport) FName ENGINE_Falling;
extern __declspec(dllexport) FName ENGINE_FellOutOfWorld;
extern __declspec(dllexport) FName ENGINE_FinishedInterpolation;
extern __declspec(dllexport) FName ENGINE_ForceGenerate;
extern __declspec(dllexport) FName ENGINE_GMProcessMsg;
extern __declspec(dllexport) FName ENGINE_GainedChild;
extern __declspec(dllexport) FName ENGINE_GameEnding;
extern __declspec(dllexport) FName ENGINE_GameTypeUseNbOfTerroristToSpawn;
extern __declspec(dllexport) FName ENGINE_Generate;
extern __declspec(dllexport) FName ENGINE_GetBackgroundsRoot;
extern __declspec(dllexport) FName ENGINE_GetBeaconText;
extern __declspec(dllexport) FName ENGINE_GetCampaignDir;
extern __declspec(dllexport) FName ENGINE_GetDefaultCampaignDir;
extern __declspec(dllexport) FName ENGINE_GetGameTypeIndex;
extern __declspec(dllexport) FName ENGINE_GetGameTypeName;
extern __declspec(dllexport) FName ENGINE_GetIniFilesDir;
extern __declspec(dllexport) FName ENGINE_GetLocalLogFileName;
extern __declspec(dllexport) FName ENGINE_GetLocalPlayerIp;
extern __declspec(dllexport) FName ENGINE_GetMapsDir;
extern __declspec(dllexport) FName ENGINE_GetModKeyword;
extern __declspec(dllexport) FName ENGINE_GetModName;
extern __declspec(dllexport) FName ENGINE_GetNbMods;
extern __declspec(dllexport) FName ENGINE_GetReticuleInfo;
extern __declspec(dllexport) FName ENGINE_GetServerIni;
extern __declspec(dllexport) FName ENGINE_GetSkins;
extern __declspec(dllexport) FName ENGINE_GetStoreGamePwd;
extern __declspec(dllexport) FName ENGINE_GetVideosRoot;
extern __declspec(dllexport) FName ENGINE_GetViewRotation;
extern __declspec(dllexport) FName ENGINE_HandleServerMsg;
extern __declspec(dllexport) FName ENGINE_HeadVolumeChange;
extern __declspec(dllexport) FName ENGINE_HearNoise;
extern __declspec(dllexport) FName ENGINE_HitWall;
extern __declspec(dllexport) FName ENGINE_Init;
extern __declspec(dllexport) FName ENGINE_InitGame;
extern __declspec(dllexport) FName ENGINE_InitInputSystem;
extern __declspec(dllexport) FName ENGINE_InitModMgr;
extern __declspec(dllexport) FName ENGINE_InitMultiPlayerOptions;
extern __declspec(dllexport) FName ENGINE_Initialize;
extern __declspec(dllexport) FName ENGINE_Initialized;
extern __declspec(dllexport) FName ENGINE_IsGameTypePlayWithNonRainbowNPCs;
extern __declspec(dllexport) FName ENGINE_IsGoggles;
extern __declspec(dllexport) FName ENGINE_IsMissionPack;
extern __declspec(dllexport) FName ENGINE_IsPlayerPassiveSpectator;
extern __declspec(dllexport) FName ENGINE_IsRavenShield;
extern __declspec(dllexport) FName ENGINE_KApplyForce;
extern __declspec(dllexport) FName ENGINE_KForceExceed;
extern __declspec(dllexport) FName ENGINE_KImpact;
extern __declspec(dllexport) FName ENGINE_KSkelConvulse;
extern __declspec(dllexport) FName ENGINE_KVelDropBelow;
extern __declspec(dllexport) FName ENGINE_KeyFrameReached;
extern __declspec(dllexport) FName ENGINE_KilledBy;
extern __declspec(dllexport) FName ENGINE_Landed;
extern __declspec(dllexport) FName ENGINE_LaunchR6MainMenu;
extern __declspec(dllexport) FName ENGINE_LightUpdateDirect;
extern __declspec(dllexport) FName ENGINE_LogGameSpecial;
extern __declspec(dllexport) FName ENGINE_LogGameSpecial2;
extern __declspec(dllexport) FName ENGINE_LogThis;
extern __declspec(dllexport) FName ENGINE_Login;
extern __declspec(dllexport) FName ENGINE_LongFall;
extern __declspec(dllexport) FName ENGINE_LostChild;
extern __declspec(dllexport) FName ENGINE_MayFall;
extern __declspec(dllexport) FName ENGINE_MenuLoadProfile;
extern __declspec(dllexport) FName ENGINE_MonitoredPawnAlert;
extern __declspec(dllexport) FName ENGINE_NewServerState;
extern __declspec(dllexport) FName ENGINE_Notify;
extern __declspec(dllexport) FName ENGINE_NotifyAfterLevelChange;
extern __declspec(dllexport) FName ENGINE_NotifyBump;
extern __declspec(dllexport) FName ENGINE_NotifyHeadVolumeChange;
extern __declspec(dllexport) FName ENGINE_NotifyHitMover;
extern __declspec(dllexport) FName ENGINE_NotifyHitWall;
extern __declspec(dllexport) FName ENGINE_NotifyLanded;
extern __declspec(dllexport) FName ENGINE_NotifyLevelChange;
extern __declspec(dllexport) FName ENGINE_NotifyPhysicsVolumeChange;
extern __declspec(dllexport) FName ENGINE_PawnEnteredVolume;
extern __declspec(dllexport) FName ENGINE_PawnIsMoving;
extern __declspec(dllexport) FName ENGINE_PawnLeavingVolume;
extern __declspec(dllexport) FName ENGINE_PawnStoppedMoving;
extern __declspec(dllexport) FName ENGINE_PhysicsChangedFor;
extern __declspec(dllexport) FName ENGINE_PhysicsVolumeChange;
extern __declspec(dllexport) FName ENGINE_PlayDying;
extern __declspec(dllexport) FName ENGINE_PlayFalling;
extern __declspec(dllexport) FName ENGINE_PlayJump;
extern __declspec(dllexport) FName ENGINE_PlayLandingAnimation;
extern __declspec(dllexport) FName ENGINE_PlayWeaponAnimation;
extern __declspec(dllexport) FName ENGINE_PlayerCalcView;
extern __declspec(dllexport) FName ENGINE_PlayerInput;
extern __declspec(dllexport) FName ENGINE_PlayerSeesMe;
extern __declspec(dllexport) FName ENGINE_PlayerTick;
extern __declspec(dllexport) FName ENGINE_PostBeginPlay;
extern __declspec(dllexport) FName ENGINE_PostFadeRender;
extern __declspec(dllexport) FName ENGINE_PostLogin;
extern __declspec(dllexport) FName ENGINE_PostNetBeginPlay;
extern __declspec(dllexport) FName ENGINE_PostRender;
extern __declspec(dllexport) FName ENGINE_PostTeleport;
extern __declspec(dllexport) FName ENGINE_PostTouch;
extern __declspec(dllexport) FName ENGINE_PreBeginPlay;
extern __declspec(dllexport) FName ENGINE_PreClientTravel;
extern __declspec(dllexport) FName ENGINE_PreLogOut;
extern __declspec(dllexport) FName ENGINE_PreLogin;
extern __declspec(dllexport) FName ENGINE_PreTeleport;
extern __declspec(dllexport) FName ENGINE_PrepareForMove;
extern __declspec(dllexport) FName ENGINE_ProcessHeart;
extern __declspec(dllexport) FName ENGINE_Process_KeyEvent;
extern __declspec(dllexport) FName ENGINE_Process_KeyType;
extern __declspec(dllexport) FName ENGINE_Process_Message;
extern __declspec(dllexport) FName ENGINE_Process_PostRender;
extern __declspec(dllexport) FName ENGINE_Process_PreRender;
extern __declspec(dllexport) FName ENGINE_Process_Tick;
extern __declspec(dllexport) FName ENGINE_R6ConnectionFailed;
extern __declspec(dllexport) FName ENGINE_R6ConnectionInProgress;
extern __declspec(dllexport) FName ENGINE_R6ConnectionInterrupted;
extern __declspec(dllexport) FName ENGINE_R6ConnectionSuccess;
extern __declspec(dllexport) FName ENGINE_R6DeadEndedMoving;
extern __declspec(dllexport) FName ENGINE_R6MakeNoise;
extern __declspec(dllexport) FName ENGINE_R6ProgressMsg;
extern __declspec(dllexport) FName ENGINE_R6QueryCircumstantialAction;
extern __declspec(dllexport) FName ENGINE_ReceiveLocalizedMessage;
extern __declspec(dllexport) FName ENGINE_ReceivedEngineWeapon;
extern __declspec(dllexport) FName ENGINE_ReceivedWeapons;
extern __declspec(dllexport) FName ENGINE_RemoveCameraEffect;
extern __declspec(dllexport) FName ENGINE_RemoveInteraction;
extern __declspec(dllexport) FName ENGINE_RenderFirstPersonGun;
extern __declspec(dllexport) FName ENGINE_Reset;
extern __declspec(dllexport) FName ENGINE_RestartServer;
extern __declspec(dllexport) FName ENGINE_RunAll;
extern __declspec(dllexport) FName ENGINE_SaveAndResetData;
extern __declspec(dllexport) FName ENGINE_SaveRemoteServerSettings;
extern __declspec(dllexport) FName ENGINE_SceneEnded;
extern __declspec(dllexport) FName ENGINE_SceneStarted;
extern __declspec(dllexport) FName ENGINE_SeeMonster;
extern __declspec(dllexport) FName ENGINE_SeePlayer;
extern __declspec(dllexport) FName ENGINE_ServerDisconnected;
extern __declspec(dllexport) FName ENGINE_ServerTravel;
extern __declspec(dllexport) FName ENGINE_SetAnimAction;
extern __declspec(dllexport) FName ENGINE_SetCurrentMod;
extern __declspec(dllexport) FName ENGINE_SetFocusTo;
extern __declspec(dllexport) FName ENGINE_SetIdentifyTarget;
extern __declspec(dllexport) FName ENGINE_SetInitialState;
extern __declspec(dllexport) FName ENGINE_SetMatchResult;
extern __declspec(dllexport) FName ENGINE_SetProgressTime;
extern __declspec(dllexport) FName ENGINE_SetWalking;
extern __declspec(dllexport) FName ENGINE_ShowUpgradeMenu;
extern __declspec(dllexport) FName ENGINE_ShowWeaponParticules;
extern __declspec(dllexport) FName ENGINE_SpecialCost;
extern __declspec(dllexport) FName ENGINE_SpecialHandling;
extern __declspec(dllexport) FName ENGINE_Spawned;
extern __declspec(dllexport) FName ENGINE_StartCrouch;
extern __declspec(dllexport) FName ENGINE_StopAnimForRG;
extern __declspec(dllexport) FName ENGINE_StopPlayFiring;
extern __declspec(dllexport) FName ENGINE_SuggestMovePreparation;
extern __declspec(dllexport) FName ENGINE_TeamMessage;
extern __declspec(dllexport) FName ENGINE_Tick;
extern __declspec(dllexport) FName ENGINE_Timer;
extern __declspec(dllexport) FName ENGINE_ToggleRadar;
extern __declspec(dllexport) FName ENGINE_TornOff;
extern __declspec(dllexport) FName ENGINE_Touch;
extern __declspec(dllexport) FName ENGINE_TravelPostAccept;
extern __declspec(dllexport) FName ENGINE_TravelPreAccept;
extern __declspec(dllexport) FName ENGINE_Trigger;
extern __declspec(dllexport) FName ENGINE_TriggerEvent;
extern __declspec(dllexport) FName ENGINE_UnTouch;
extern __declspec(dllexport) FName ENGINE_UnTrigger;
extern __declspec(dllexport) FName ENGINE_UpdateServer;
extern __declspec(dllexport) FName ENGINE_UpdateShadow;
extern __declspec(dllexport) FName ENGINE_UpdateWeaponAttachment;
extern __declspec(dllexport) FName ENGINE_UsedBy;
extern __declspec(dllexport) FName ENGINE_UserDisconnected;
extern __declspec(dllexport) FName ENGINE_WorldSpaceOverlays;
extern __declspec(dllexport) FName ENGINE_ZoneChange;







class AActor;
class APawn;
class AController;
class APlayerController;
class ABrush;
class AVolume;
class AInfo;
class AZoneInfo;
class ALevelInfo;
class AGameInfo;
class AHUD;
class UCanvas;
class ULevel;
class ULevelBase;
class UModel;
class UPolys;
class UMesh;
class ULodMesh;
class USkeletalMesh;
class USkeletalMeshInstance;
class UStaticMesh;
class UStaticMeshInstance;
class UMeshInstance;
class URenderResource;
class UMaterial;
class UTexture;
class USound;
class UMusic;
class UAudioSubsystem;
class URenderDevice;
class UNetDriver;
class UNetConnection;
class UChannel;
class UPlayer;
class AEmitter;
class AProjector;






class __declspec(dllexport) FEngineStats  { public: BYTE Pad[256]; FEngineStats() { appMemzero(this, sizeof(*this)); } };
class __declspec(dllexport) FStats        { public: BYTE Pad[256]; FStats()       { appMemzero(this, sizeof(*this)); } };
class __declspec(dllexport) FRebuildTools { public: BYTE Pad[64];  FRebuildTools(){ appMemzero(this, sizeof(*this)); } };
class __declspec(dllexport) FMatineeTools { public: BYTE Pad[64];  FMatineeTools(){ appMemzero(this, sizeof(*this)); } };
class __declspec(dllexport) FTerrainTools { public: BYTE Pad[64];  FTerrainTools(){ appMemzero(this, sizeof(*this)); } };


class FStatGraph;
class FTempLineBatcher;
struct STDbgLine;






class __declspec(dllexport) UMeshInstance : public UPrimitive
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UPrimitive Super; typedef UMeshInstance ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UMeshInstance*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UMeshInstance() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UMeshInstance(); }
	protected: UMeshInstance() {} public:
};


class __declspec(dllexport) URenderResource : public UObject
{
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef URenderResource ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, URenderResource*& Res ) { return Ar << *(UObject**)&Res; } virtual ~URenderResource() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )URenderResource(); }
	protected: URenderResource() {} public:
};





class __declspec(dllexport) AActor : public UObject
{
public:
	public: enum {StaticClassFlags=0|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef AActor ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AActor*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AActor() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AActor(); }
	
	DECLARE_FUNCTION(execError)
	DECLARE_FUNCTION(execSleep)
	DECLARE_FUNCTION(execPlayAnim)
	DECLARE_FUNCTION(execLoopAnim)
	DECLARE_FUNCTION(execFinishAnim)
	DECLARE_FUNCTION(execSetCollision)
	DECLARE_FUNCTION(execHasAnim)
	DECLARE_FUNCTION(execPlaySound)
	DECLARE_FUNCTION(execMove)
	DECLARE_FUNCTION(execSetLocation)
	DECLARE_FUNCTION(execSetOwner)
	DECLARE_FUNCTION(execTrace)
	DECLARE_FUNCTION(execSpawn)
	DECLARE_FUNCTION(execDestroy)
	DECLARE_FUNCTION(execSetTimer)
	DECLARE_FUNCTION(execIsAnimating)
	DECLARE_FUNCTION(execSetCollisionSize)
	DECLARE_FUNCTION(execGetAnimGroup)
	DECLARE_FUNCTION(execTweenAnim)
	DECLARE_FUNCTION(execSetBase)
	DECLARE_FUNCTION(execSetRotation)
	DECLARE_FUNCTION(execFinishInterpolation)
	DECLARE_FUNCTION(execAllActors)
	DECLARE_FUNCTION(execChildActors)
	DECLARE_FUNCTION(execBasedActors)
	DECLARE_FUNCTION(execTouchingActors)
	DECLARE_FUNCTION(execTraceActors)
	DECLARE_FUNCTION(execRadiusActors)
	DECLARE_FUNCTION(execVisibleActors)
	DECLARE_FUNCTION(execVisibleCollidingActors)
	DECLARE_FUNCTION(execMakeNoise)
	DECLARE_FUNCTION(execPlayerCanSeeMe)
	DECLARE_FUNCTION(execGetMapName)
	DECLARE_FUNCTION(execGetNextSkin)
	DECLARE_FUNCTION(execGetURLMap)
	DECLARE_FUNCTION(execFastTrace)
	DECLARE_FUNCTION(execMoveSmooth)
	DECLARE_FUNCTION(execSetPhysics)
	DECLARE_FUNCTION(execAutonomousPhysics)
	
	DECLARE_FUNCTION(execPollSleep)
	DECLARE_FUNCTION(execPollFinishAnim)
	DECLARE_FUNCTION(execPollFinishInterpolation)
	DECLARE_FUNCTION(execGetCacheEntry)
	DECLARE_FUNCTION(execMoveCacheEntry)
	DECLARE_FUNCTION(execGetNextIntDesc)
	DECLARE_FUNCTION(execSetCollisionDrawScale)
	DECLARE_FUNCTION(execSetDrawType)
	DECLARE_FUNCTION(execSetDrawScale)
	DECLARE_FUNCTION(execSetDrawScale3D)
	DECLARE_FUNCTION(execSetStaticMesh)
	DECLARE_FUNCTION(execUpdateRenderData)
	DECLARE_FUNCTION(execGetRenderBoundingSphere)
	DECLARE_FUNCTION(execDrawDebugLine)
	DECLARE_FUNCTION(execDynamicActors)
	DECLARE_FUNCTION(execCollidingActors)
	DECLARE_FUNCTION(execConnectedDoors)
	DECLARE_FUNCTION(execSubtract_ColorColor)
	DECLARE_FUNCTION(execMultiply_FloatColor)
	DECLARE_FUNCTION(execAdd_ColorColor)
	DECLARE_FUNCTION(execMultiply_ColorFloat)
	DECLARE_FUNCTION(execSetFPlayerMenuInfo)
	DECLARE_FUNCTION(execGetViewRotation)
	DECLARE_FUNCTION(execDemoPlaySound)
	DECLARE_FUNCTION(execAntiPortalActors)
	DECLARE_FUNCTION(execGetMapRevision)
	DECLARE_FUNCTION(execIsValidActor)
	DECLARE_FUNCTION(execGetDiffuseColor)
	DECLARE_FUNCTION(execSetR6Collision)
	DECLARE_FUNCTION(execSetSoundParamsExt)
	DECLARE_FUNCTION(execR6MakeNoise)
	DECLARE_FUNCTION(execSetReverbPreset)
	DECLARE_FUNCTION(execClientHearSound)
	DECLARE_FUNCTION(execSetSweptCollision)
	DECLARE_FUNCTION(execRenderOverlays)
	
	void Serialize( FArchive& Ar );
	void PostLoad();
	void Destroy();
	void ProcessEvent( UFunction* Function, void* Parms, void* Result=0 );
	void ProcessState( FLOAT DeltaSeconds );
	UBOOL ProcessRemoteFunction( UFunction* Function, void* Parms, FFrame* Stack );
	void ProcessDemoRecFunction( UFunction* Function, void* Parms, FFrame* Stack );
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, INT NumReps );
	void Tick( FLOAT DeltaTime );
	void PostEditChange();
	void InitExecution();
	UBOOL IsNetRelevantFor( APlayerController* RealViewer, AActor* Viewer, FVector SrcLocation );
	FLOAT GetNetPriority( FVector& ViewPos, FVector& ViewDir, AActor* Sent, FLOAT Time, FLOAT Lag );
	UPrimitive* GetPrimitive();
};

class __declspec(dllexport) AInfo : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AInfo(); }
};

class __declspec(dllexport) ABrush : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef ABrush ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ABrush*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ABrush() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ABrush(); }
};

class __declspec(dllexport) AVolume : public ABrush
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef ABrush Super; typedef AVolume ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AVolume*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AVolume() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AVolume(); }
};

class __declspec(dllexport) AKeypoint : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AKeypoint ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AKeypoint*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AKeypoint() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AKeypoint(); }
};

class __declspec(dllexport) ATriggers : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef ATriggers ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ATriggers*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ATriggers() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ATriggers(); }
};

class __declspec(dllexport) ATrigger : public ATriggers
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef ATriggers Super; typedef ATrigger ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ATrigger*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ATrigger() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ATrigger(); }
};

class __declspec(dllexport) ALight : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef ALight ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ALight*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ALight() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ALight(); }
};

class __declspec(dllexport) ANavigationPoint : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef ANavigationPoint ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ANavigationPoint*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ANavigationPoint() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ANavigationPoint(); }
};

class __declspec(dllexport) ASmallNavigationPoint : public ANavigationPoint
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef ANavigationPoint Super; typedef ASmallNavigationPoint ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ASmallNavigationPoint*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ASmallNavigationPoint() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ASmallNavigationPoint(); }
};

class __declspec(dllexport) APhysicsVolume : public AVolume
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AVolume Super; typedef APhysicsVolume ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, APhysicsVolume*& Res ) { return Ar << *(UObject**)&Res; } virtual ~APhysicsVolume() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )APhysicsVolume(); }
};

class __declspec(dllexport) ADefaultPhysicsVolume : public APhysicsVolume
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef APhysicsVolume Super; typedef ADefaultPhysicsVolume ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ADefaultPhysicsVolume*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ADefaultPhysicsVolume() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ADefaultPhysicsVolume(); }
};

class __declspec(dllexport) ABlockingVolume : public AVolume
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AVolume Super; typedef ABlockingVolume ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ABlockingVolume*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ABlockingVolume() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ABlockingVolume(); }
};

class __declspec(dllexport) AAntiPortalActor : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AAntiPortalActor ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AAntiPortalActor*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AAntiPortalActor() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AAntiPortalActor(); }
};

class __declspec(dllexport) ANote : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef ANote ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ANote*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ANote() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ANote(); }
};

class __declspec(dllexport) APolyMarker : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef APolyMarker ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, APolyMarker*& Res ) { return Ar << *(UObject**)&Res; } virtual ~APolyMarker() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )APolyMarker(); }
};

class __declspec(dllexport) AClipMarker : public AKeypoint
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AKeypoint Super; typedef AClipMarker ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AClipMarker*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AClipMarker() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AClipMarker(); }
};

class __declspec(dllexport) AStaticMeshActor : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AStaticMeshActor ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AStaticMeshActor*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AStaticMeshActor() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AStaticMeshActor(); }
};

class __declspec(dllexport) AEffects : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AEffects ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AEffects*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AEffects() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AEffects(); }
};

class __declspec(dllexport) AAmbientSound : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AAmbientSound ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AAmbientSound*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AAmbientSound() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AAmbientSound(); }
};

class __declspec(dllexport) ADecoVolumeObject : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef ADecoVolumeObject ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ADecoVolumeObject*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ADecoVolumeObject() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ADecoVolumeObject(); }
};

class __declspec(dllexport) ADecorationList : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef ADecorationList ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ADecorationList*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ADecorationList() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ADecorationList(); }
};

class __declspec(dllexport) AKActor : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AKActor ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AKActor*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AKActor() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AKActor(); }
};

class __declspec(dllexport) AMover : public ABrush
{
public:
	public: enum {StaticClassFlags=0|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef ABrush Super; typedef AMover ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AMover*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AMover() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AMover(); }
};

class __declspec(dllexport) AProjector : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AProjector ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AProjector*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AProjector() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AProjector(); }
	DECLARE_FUNCTION(execAbandonProjector)
	DECLARE_FUNCTION(execAttachActor)
	DECLARE_FUNCTION(execAttachProjector)
	DECLARE_FUNCTION(execDetachActor)
	DECLARE_FUNCTION(execDetachProjector)
};

class __declspec(dllexport) AShadowProjector : public AProjector
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AProjector Super; typedef AShadowProjector ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AShadowProjector*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AShadowProjector() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AShadowProjector(); }
};

class __declspec(dllexport) AR6MorphMeshActor : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AR6MorphMeshActor ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AR6MorphMeshActor*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AR6MorphMeshActor() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AR6MorphMeshActor(); }
};

class __declspec(dllexport) AR6ActorSound : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AR6ActorSound ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AR6ActorSound*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AR6ActorSound() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AR6ActorSound(); }
};

class __declspec(dllexport) AR6Alarm : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AR6Alarm ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AR6Alarm*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AR6Alarm() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AR6Alarm(); }
};





class __declspec(dllexport) APawn : public AActor
{
public:
	public: enum {StaticClassFlags=0|CLASS_Config|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef APawn ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, APawn*& Res ) { return Ar << *(UObject**)&Res; } virtual ~APawn() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )APawn(); }
	
	DECLARE_FUNCTION(execReachedDestination)
	DECLARE_FUNCTION(execIsFriend)
	DECLARE_FUNCTION(execIsEnemy)
	DECLARE_FUNCTION(execIsNeutral)
	DECLARE_FUNCTION(execIsAlive)
};

class __declspec(dllexport) AController : public AActor
{
public:
	public: enum {StaticClassFlags=0|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AController ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AController*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AController() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AController(); }
	
	DECLARE_FUNCTION(execMoveTo)
	DECLARE_FUNCTION(execMoveToward)
	DECLARE_FUNCTION(execStrafeTo)
	DECLARE_FUNCTION(execStrafeFacing)
	DECLARE_FUNCTION(execTurnTo)
	DECLARE_FUNCTION(execTurnToward)
	DECLARE_FUNCTION(execLineOfSightTo)
	DECLARE_FUNCTION(execFindPathToward)
	DECLARE_FUNCTION(execFindPathTo)
	DECLARE_FUNCTION(execactorReachable)
	DECLARE_FUNCTION(execpointReachable)
	DECLARE_FUNCTION(execClearPaths)
	DECLARE_FUNCTION(execEAdjustJump)
	DECLARE_FUNCTION(execFindRandomDest)
	DECLARE_FUNCTION(execPickWallAdjust)
	DECLARE_FUNCTION(execWaitForLanding)
	DECLARE_FUNCTION(execAddController)
	DECLARE_FUNCTION(execRemoveController)
	DECLARE_FUNCTION(execPickTarget)
	DECLARE_FUNCTION(execCanSee)
	DECLARE_FUNCTION(execPickAnyTarget)
	DECLARE_FUNCTION(execFindBestInventoryPath)
	DECLARE_FUNCTION(execFinishRotation)
	
	DECLARE_FUNCTION(execStopWaiting)
	DECLARE_FUNCTION(execInLatentExecution)
	DECLARE_FUNCTION(execEndClimbLadder)
	DECLARE_FUNCTION(execPollMoveTo)
	DECLARE_FUNCTION(execPollMoveToward)
	DECLARE_FUNCTION(execPollWaitForLanding)
	DECLARE_FUNCTION(execPollFinishRotation)
};

class __declspec(dllexport) APlayerController : public AController
{
public:
	public: enum {StaticClassFlags=0|CLASS_Config|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AController Super; typedef APlayerController ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, APlayerController*& Res ) { return Ar << *(UObject**)&Res; } virtual ~APlayerController() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )APlayerController(); }
	
	DECLARE_FUNCTION(execFindStairRotation)
	DECLARE_FUNCTION(execResetKeyboard)
	DECLARE_FUNCTION(execUpdateURL)
	DECLARE_FUNCTION(execPB_CanPlayerSpawn)
	DECLARE_FUNCTION(execGetKey)
	DECLARE_FUNCTION(execGetActionKey)
	DECLARE_FUNCTION(execGetEnumName)
	DECLARE_FUNCTION(execChangeInputSet)
	DECLARE_FUNCTION(execSetKey)
	DECLARE_FUNCTION(execSetSoundOptions)
	DECLARE_FUNCTION(execChangeVolumeTypeLinear)
	
	DECLARE_FUNCTION(execConsoleCommand)
	DECLARE_FUNCTION(execGetValueFromMenu)
	DECLARE_FUNCTION(execGetDefaultURL)
	DECLARE_FUNCTION(execGetEntryLevel)
	DECLARE_FUNCTION(execSetViewTarget)
	DECLARE_FUNCTION(execSpecialDestroy)
	DECLARE_FUNCTION(execClientTravel)
	DECLARE_FUNCTION(execGetPlayerNetworkAddress)
	DECLARE_FUNCTION(execCopyToClipboard)
	DECLARE_FUNCTION(execPasteFromClipboard)
	DECLARE_FUNCTION(execIsPBEnabled)
	DECLARE_FUNCTION(execGetPBConnectStatus)
};

class __declspec(dllexport) AAIController : public AController
{
public:
	public: enum {StaticClassFlags=0|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AController Super; typedef AAIController ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AAIController*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AAIController() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AAIController(); }
	DECLARE_FUNCTION(execWaitToSeeEnemy)
	DECLARE_FUNCTION(execPollWaitToSeeEnemy)
};





class __declspec(dllexport) ULevelBase : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef ULevelBase ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ULevelBase*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ULevelBase() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ULevelBase(); }
	protected: ULevelBase() {} public:
	void Serialize( FArchive& Ar );
	void Destroy();
};

class __declspec(dllexport) ULevel : public ULevelBase
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef ULevelBase Super; typedef ULevel ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ULevel*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ULevel() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ULevel(); }
	protected: ULevel() {} public:
	void Serialize( FArchive& Ar );
	void Destroy();
};

class __declspec(dllexport) AZoneInfo : public AInfo
{
public:
	public: enum {StaticClassFlags=0|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AInfo Super; typedef AZoneInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AZoneInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AZoneInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AZoneInfo(); }
};

class __declspec(dllexport) ALevelInfo : public AZoneInfo
{
public:
	public: enum {StaticClassFlags=0|CLASS_Config|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AZoneInfo Super; typedef ALevelInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ALevelInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ALevelInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ALevelInfo(); }
	DECLARE_FUNCTION(execGetAddressURL)
	DECLARE_FUNCTION(execGetLocalURL)
	DECLARE_FUNCTION(execGetMapNameLocalisation)
	DECLARE_FUNCTION(execFinalizeLoading)
	DECLARE_FUNCTION(execResetLevelInNative)
	DECLARE_FUNCTION(execSetBankSound)
	DECLARE_FUNCTION(execNotifyMatchStart)
	DECLARE_FUNCTION(execPBNotifyServerTravel)
	DECLARE_FUNCTION(execCallLogThisActor)
	DECLARE_FUNCTION(execAddWritableMapPoint)
	DECLARE_FUNCTION(execAddWritableMapIcon)
	DECLARE_FUNCTION(execAddEncodedWritableMapStrip)
};

class __declspec(dllexport) AGameInfo : public AInfo
{
public:
	public: enum {StaticClassFlags=0|CLASS_Config}; private: static UClass PrivateStaticClass; public: typedef AInfo Super; typedef AGameInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AGameInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AGameInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AGameInfo(); }
	DECLARE_FUNCTION(execGetNetworkNumber)
	DECLARE_FUNCTION(execGetCurrentMapNum)
	DECLARE_FUNCTION(execSetCurrentMapNum)
	DECLARE_FUNCTION(execParseKillMessage)
	DECLARE_FUNCTION(execProcessR6Availabilty)
	DECLARE_FUNCTION(execAbortScoreSubmission)
};

class __declspec(dllexport) AReplicationInfo : public AInfo
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AInfo Super; typedef AReplicationInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AReplicationInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AReplicationInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AReplicationInfo(); }
};

class __declspec(dllexport) APlayerReplicationInfo : public AReplicationInfo
{
public:
	public: enum {StaticClassFlags=0|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AReplicationInfo Super; typedef APlayerReplicationInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, APlayerReplicationInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~APlayerReplicationInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )APlayerReplicationInfo(); }
};

class __declspec(dllexport) AGameReplicationInfo : public AReplicationInfo
{
public:
	public: enum {StaticClassFlags=0|CLASS_Config|CLASS_NativeReplication}; private: static UClass PrivateStaticClass; public: typedef AReplicationInfo Super; typedef AGameReplicationInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AGameReplicationInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AGameReplicationInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AGameReplicationInfo(); }
};

class __declspec(dllexport) AR6PawnReplicationInfo : public APlayerReplicationInfo
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef APlayerReplicationInfo Super; typedef AR6PawnReplicationInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AR6PawnReplicationInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AR6PawnReplicationInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AR6PawnReplicationInfo(); }
};





class __declspec(dllexport) URenderDevice : public USubsystem
{
public:
	public: enum {StaticClassFlags=CLASS_Config}; private: static UClass PrivateStaticClass; public: typedef USubsystem Super; typedef URenderDevice ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, URenderDevice*& Res ) { return Ar << *(UObject**)&Res; } virtual ~URenderDevice() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )URenderDevice(); }
};

class __declspec(dllexport) UCanvas : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UCanvas ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UCanvas*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UCanvas() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UCanvas(); }

	
	class UFont* Font;
	FLOAT SpaceX;
	FLOAT SpaceY;
	FLOAT OrgX;
	FLOAT OrgY;
	FLOAT ClipX;
	FLOAT ClipY;
	FLOAT HalfClipX;
	FLOAT HalfClipY;
	FLOAT CurX;
	FLOAT CurY;
	FLOAT Z;
	BYTE Style;
	FLOAT CurYL;
	FColor DrawColor;
	BITFIELD bCenter : 1;
	BITFIELD bNoSmooth : 1;
	INT SizeX;
	INT SizeY;
	class UFont* SmallFont;
	class UFont* MedFont;
	class UViewport* Viewport;
	INT m_hBink;
	BITFIELD m_bPlaying : 1;
	INT m_iPosX;
	INT m_iPosY;
	BITFIELD m_bForceMul2x : 1;
	FLOAT m_fStretchX;
	FLOAT m_fStretchY;
	FLOAT m_fVirtualResX;
	FLOAT m_fVirtualResY;
	FLOAT m_fNormalClipX;
	FLOAT m_fNormalClipY;
	BITFIELD m_bDisplayGameOutroVideo : 1;
	BITFIELD m_bChangeResRequested : 1;
	INT m_iNewResolutionX;
	INT m_iNewResolutionY;
	BITFIELD m_bFading : 1;
	BITFIELD m_bFadeAutoStop : 1;
	FColor m_FadeStartColor;
	FColor m_FadeEndColor;
	FLOAT m_fFadeTotalTime;
	FLOAT m_fFadeCurrentTime;
	class UMaterial* m_pWritableMapIconsTexture;

	
	virtual void Init( class UViewport* InViewport );
	virtual void Update();
	virtual void DrawTile( class UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane, FLOAT );
	virtual void DrawIcon( class UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane );
	virtual void DrawPattern( class UMaterial*, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FLOAT, FPlane, FPlane );
	virtual INT _DrawString( class UFont*, INT, INT, const TCHAR*, FPlane, INT, INT, INT );
	virtual void WrappedDrawString( enum ERenderStyle, INT&, INT&, class UFont*, INT, const TCHAR* );
	virtual void __cdecl WrappedStrLenf( class UFont*, INT&, INT&, const TCHAR*, ... );
	virtual void __cdecl WrappedPrintf( class UFont*, INT, const TCHAR*, ... );
	virtual void SetClip( INT, INT, INT, INT );

	
	DECLARE_FUNCTION(execSetPos)
	DECLARE_FUNCTION(execSetOrigin)
	DECLARE_FUNCTION(execSetClip)
	DECLARE_FUNCTION(execSetDrawColor)
	DECLARE_FUNCTION(execDrawText)
	DECLARE_FUNCTION(execDrawTextClipped)
	DECLARE_FUNCTION(execClipTextNative)
	DECLARE_FUNCTION(execDrawTile)
	DECLARE_FUNCTION(execDrawTileClipped)
	DECLARE_FUNCTION(execDrawStretchedTextureSegmentNative)
	DECLARE_FUNCTION(execDrawActor)
	DECLARE_FUNCTION(execDrawPortal)
	DECLARE_FUNCTION(execDraw3DLine)
	DECLARE_FUNCTION(execStrLen)
	DECLARE_FUNCTION(execTextSize)
	DECLARE_FUNCTION(execGetScreenCoordinate)
	DECLARE_FUNCTION(execSetVirtualSize)
	DECLARE_FUNCTION(execUseVirtualSize)
	DECLARE_FUNCTION(execSetMotionBlurIntensity)
	DECLARE_FUNCTION(execDrawWritableMap)
	DECLARE_FUNCTION(execVideoOpen)
	DECLARE_FUNCTION(execVideoPlay)
	DECLARE_FUNCTION(execVideoStop)
	DECLARE_FUNCTION(execVideoClose)
};

class __declspec(dllexport) AHUD : public AActor
{
public:
	public: enum {StaticClassFlags=0|CLASS_Config}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AHUD ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AHUD*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AHUD() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AHUD(); }
	DECLARE_FUNCTION(execDraw3DLine)
};





class __declspec(dllexport) UPlayer : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UPlayer ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPlayer*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPlayer() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPlayer(); }
};

class __declspec(dllexport) UNetDriver : public USubsystem
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef USubsystem Super; typedef UNetDriver ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UNetDriver*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UNetDriver() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UNetDriver(); }
	void Serialize( FArchive& Ar );
	void Destroy();
};

class __declspec(dllexport) UNetConnection : public UPlayer
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UPlayer Super; typedef UNetConnection ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UNetConnection*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UNetConnection() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UNetConnection(); }
	void Serialize( FArchive& Ar );
	void Destroy();
};

class __declspec(dllexport) UChannel : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UChannel ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UChannel*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UChannel() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UChannel(); }
	void Serialize( FArchive& Ar );
};

class __declspec(dllexport) UActorChannel : public UChannel
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UChannel Super; typedef UActorChannel ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UActorChannel*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UActorChannel() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UActorChannel(); }
	void Serialize( FArchive& Ar );
	void Destroy();
};

class __declspec(dllexport) UControlChannel : public UChannel
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UChannel Super; typedef UControlChannel ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UControlChannel*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UControlChannel() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UControlChannel(); }
};

class __declspec(dllexport) UFileChannel : public UChannel
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UChannel Super; typedef UFileChannel ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UFileChannel*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UFileChannel() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UFileChannel(); }
	void Destroy();
};

class __declspec(dllexport) UPackageMapLevel : public UPackageMap
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UPackageMap Super; typedef UPackageMapLevel ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPackageMapLevel*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPackageMapLevel() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPackageMapLevel(); }
	void Serialize( FArchive& Ar );
};





class __declspec(dllexport) UMaterial : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UMaterial ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UMaterial*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UMaterial() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UMaterial(); }
	void Serialize( FArchive& Ar );
	void PostLoad();
	void Destroy();
};

class __declspec(dllexport) URenderedMaterial : public UMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMaterial Super; typedef URenderedMaterial ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, URenderedMaterial*& Res ) { return Ar << *(UObject**)&Res; } virtual ~URenderedMaterial() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )URenderedMaterial(); }
};

class __declspec(dllexport) UBitmapMaterial : public URenderedMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef URenderedMaterial Super; typedef UBitmapMaterial ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UBitmapMaterial*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UBitmapMaterial() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UBitmapMaterial(); }
};

class __declspec(dllexport) UTexture : public UBitmapMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UBitmapMaterial Super; typedef UTexture ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexture*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexture() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexture(); }
	void Serialize( FArchive& Ar );
	void PostLoad();
	void Destroy();
};

class __declspec(dllexport) UShader : public UMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMaterial Super; typedef UShader ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UShader*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UShader() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UShader(); }
};

class __declspec(dllexport) UModifier : public UMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMaterial Super; typedef UModifier ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UModifier*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UModifier() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UModifier(); }
};

class __declspec(dllexport) UCombiner : public UModifier
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UModifier Super; typedef UCombiner ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UCombiner*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UCombiner() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UCombiner(); }
};

class __declspec(dllexport) UFinalBlend : public UModifier
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UModifier Super; typedef UFinalBlend ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UFinalBlend*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UFinalBlend() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UFinalBlend(); }
};

class __declspec(dllexport) UConstantMaterial : public UMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMaterial Super; typedef UConstantMaterial ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UConstantMaterial*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UConstantMaterial() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UConstantMaterial(); }
};

class __declspec(dllexport) UConstantColor : public UConstantMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UConstantMaterial Super; typedef UConstantColor ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UConstantColor*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UConstantColor() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UConstantColor(); }
};

class __declspec(dllexport) UPalette : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UPalette ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPalette*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPalette() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPalette(); }
};

class __declspec(dllexport) UTexCoordMaterial : public UModifier
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UModifier Super; typedef UTexCoordMaterial ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexCoordMaterial*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexCoordMaterial() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexCoordMaterial(); }
};

class __declspec(dllexport) UTexMatrix : public UTexCoordMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexCoordMaterial Super; typedef UTexMatrix ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexMatrix*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexMatrix() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexMatrix(); }
};

class __declspec(dllexport) UTexOscillator : public UTexCoordMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexCoordMaterial Super; typedef UTexOscillator ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexOscillator*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexOscillator() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexOscillator(); }
};

class __declspec(dllexport) UTexPanner : public UTexCoordMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexCoordMaterial Super; typedef UTexPanner ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexPanner*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexPanner() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexPanner(); }
};

class __declspec(dllexport) UTexRotator : public UTexCoordMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexCoordMaterial Super; typedef UTexRotator ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexRotator*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexRotator() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexRotator(); }
};

class __declspec(dllexport) UTexScaler : public UTexCoordMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexCoordMaterial Super; typedef UTexScaler ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexScaler*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexScaler() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexScaler(); }
};

class __declspec(dllexport) UTexEnvMap : public UTexCoordMaterial
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexCoordMaterial Super; typedef UTexEnvMap ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UTexEnvMap*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UTexEnvMap() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UTexEnvMap(); }
};

class __declspec(dllexport) UColorModifier : public UModifier
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UModifier Super; typedef UColorModifier ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UColorModifier*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UColorModifier() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UColorModifier(); }
};

class __declspec(dllexport) UOpacityModifier : public UModifier
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UModifier Super; typedef UOpacityModifier ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UOpacityModifier*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UOpacityModifier() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UOpacityModifier(); }
};

class __declspec(dllexport) UVertexColor : public UModifier
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UModifier Super; typedef UVertexColor ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UVertexColor*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UVertexColor() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UVertexColor(); }
};

class __declspec(dllexport) UProceduralTexture : public URenderResource
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef URenderResource Super; typedef UProceduralTexture ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UProceduralTexture*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UProceduralTexture() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UProceduralTexture(); }
};

class __declspec(dllexport) UScriptedTexture : public UTexture
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexture Super; typedef UScriptedTexture ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UScriptedTexture*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UScriptedTexture() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UScriptedTexture(); }
};

class __declspec(dllexport) UCubemap : public UTexture
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexture Super; typedef UCubemap ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UCubemap*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UCubemap() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UCubemap(); }
};

class __declspec(dllexport) UPlayerLight : public UTexture
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UTexture Super; typedef UPlayerLight ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPlayerLight*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPlayerLight() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPlayerLight(); }
};





class __declspec(dllexport) UAudioSubsystem : public USubsystem
{
public:
	public: enum {StaticClassFlags=CLASS_Config}; private: static UClass PrivateStaticClass; public: typedef USubsystem Super; typedef UAudioSubsystem ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UAudioSubsystem*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UAudioSubsystem() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UAudioSubsystem(); }
};

class __declspec(dllexport) USound : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef USound ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, USound*& Res ) { return Ar << *(UObject**)&Res; } virtual ~USound() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )USound(); }
	void PostLoad();
	void Destroy();
	void Serialize( FArchive& Ar );
};

class __declspec(dllexport) UMusic : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UMusic ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UMusic*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UMusic() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UMusic(); }
};





class __declspec(dllexport) UMesh : public UPrimitive
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UPrimitive Super; typedef UMesh ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UMesh*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UMesh() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UMesh(); }
	void Serialize( FArchive& Ar );
};

class __declspec(dllexport) ULodMesh : public UMesh
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMesh Super; typedef ULodMesh ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, ULodMesh*& Res ) { return Ar << *(UObject**)&Res; } virtual ~ULodMesh() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )ULodMesh(); }
	void Serialize( FArchive& Ar );
};

class __declspec(dllexport) USkeletalMesh : public UMesh
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMesh Super; typedef USkeletalMesh ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, USkeletalMesh*& Res ) { return Ar << *(UObject**)&Res; } virtual ~USkeletalMesh() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )USkeletalMesh(); }
	void Serialize( FArchive& Ar );
};

class __declspec(dllexport) USkeletalMeshInstance : public UMeshInstance
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMeshInstance Super; typedef USkeletalMeshInstance ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, USkeletalMeshInstance*& Res ) { return Ar << *(UObject**)&Res; } virtual ~USkeletalMeshInstance() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )USkeletalMeshInstance(); }
};

class __declspec(dllexport) UStaticMesh : public UMesh
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMesh Super; typedef UStaticMesh ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UStaticMesh*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UStaticMesh() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UStaticMesh(); }
	void Serialize( FArchive& Ar );
};

class __declspec(dllexport) UStaticMeshInstance : public UMeshInstance
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UMeshInstance Super; typedef UStaticMeshInstance ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UStaticMeshInstance*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UStaticMeshInstance() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UStaticMeshInstance(); }
};





class __declspec(dllexport) UModel : public UPrimitive
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UPrimitive Super; typedef UModel ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UModel*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UModel() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UModel(); }
	void Serialize( FArchive& Ar );
	void PostLoad();
	void Destroy();
	INT PointCheck( FCheckResult& Result, AActor* Owner, FVector Location, FVector Extent, DWORD ExtraNodeFlags );
	INT LineCheck( FCheckResult& Result, AActor* Owner, FVector End, FVector Start, FVector Extent, DWORD ExtraNodeFlags, DWORD ExtraFlags );
	FBox GetRenderBoundingBox( const AActor* Owner );
	FBox GetCollisionBoundingBox( const AActor* Owner ) const;
	void Illuminate( AActor* Owner, INT bDynamic );
	FVector GetEncroachExtent( AActor* Owner );
	FVector GetEncroachCenter( AActor* Owner );
	INT UseCylinderCollision( const AActor* Owner );
};

class __declspec(dllexport) UPolys : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UPolys ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UPolys*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UPolys() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UPolys(); }
	void Serialize( FArchive& Ar );
};





class __declspec(dllexport) AEmitter : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AEmitter ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AEmitter*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AEmitter() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AEmitter(); }
	DECLARE_FUNCTION(execKill)
};

class __declspec(dllexport) UParticleEmitter : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UParticleEmitter ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UParticleEmitter*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UParticleEmitter() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UParticleEmitter(); }
	DECLARE_FUNCTION(execSpawnParticle)
};





class __declspec(dllexport) UR6AbstractGameManager : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UR6AbstractGameManager ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UR6AbstractGameManager*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UR6AbstractGameManager() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UR6AbstractGameManager(); }
};

class __declspec(dllexport) UR6MissionDescription : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UR6MissionDescription ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UR6MissionDescription*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UR6MissionDescription() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UR6MissionDescription(); }
};

class __declspec(dllexport) UR6ModMgr : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UR6ModMgr ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UR6ModMgr*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UR6ModMgr() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UR6ModMgr(); }
};

class __declspec(dllexport) UR6ServerInfo : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UR6ServerInfo ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UR6ServerInfo*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UR6ServerInfo() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UR6ServerInfo(); }
};

class __declspec(dllexport) UR6GameOptions : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UR6GameOptions ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UR6GameOptions*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UR6GameOptions() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UR6GameOptions(); }
};

class __declspec(dllexport) UGlobalTempObjects : public UObject
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef UObject Super; typedef UGlobalTempObjects ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, UGlobalTempObjects*& Res ) { return Ar << *(UObject**)&Res; } virtual ~UGlobalTempObjects() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )UGlobalTempObjects(); }
};

class __declspec(dllexport) AR6eviLTesting : public AActor
{
public:
	public: enum {StaticClassFlags=0}; private: static UClass PrivateStaticClass; public: typedef AActor Super; typedef AR6eviLTesting ThisClass; static UClass* StaticClass() { return &PrivateStaticClass; } void* operator new( size_t Size, UObject* Outer=(UObject*)GetTransientPackage(), FName Name=NAME_None, DWORD SetFlags=0 ) { return StaticAllocateObject( StaticClass(), Outer, Name, SetFlags); } void* operator new( size_t Size, EInternal* Mem ) { return (void*)Mem; } friend FArchive &operator<<( FArchive& Ar, AR6eviLTesting*& Res ) { return Ar << *(UObject**)&Res; } virtual ~AR6eviLTesting() { ConditionalDestroy(); } static void InternalConstructor( void* X ) { new( (EInternal*)X )AR6eviLTesting(); }
};







#pragma pack (pop)
































class UViewport;
class FSceneNode;

#pragma pack(pop)








extern "C" __declspec(dllexport) TCHAR GPackage[]; __declspec(dllexport) TCHAR GPackage[] = L"Engine"; extern "C" {void* hInstance;} INT __declspec(dllexport) __stdcall DllMain( void* hInInstance, DWORD Reason, void* Reserved ) { hInstance = hInInstance; return 1; };






__declspec(dllexport) FMemStack		GEngineMem;
__declspec(dllexport) FMemCache		GCache;


__declspec(dllexport) FEngineStats		GEngineStats;
__declspec(dllexport) FStats			GStats;


__declspec(dllexport) FRebuildTools	GRebuildTools;
__declspec(dllexport) FMatineeTools	GMatineeTools;
__declspec(dllexport) FTerrainTools	GTerrainTools;


__declspec(dllexport) FStatGraph*		GStatGraph			= 0;
__declspec(dllexport) FTempLineBatcher* GTempLineBatcher	= 0;
__declspec(dllexport) STDbgLine*		GDbgLine			= 0;
__declspec(dllexport) INT				GDbgLineIndex		= 0;


__declspec(dllexport) UR6AbstractGameManager*	GR6GameManager			= 0;
__declspec(dllexport) UR6MissionDescription*	GR6MissionDescription	= 0;
__declspec(dllexport) UR6ModMgr*				GModMgr					= 0;
__declspec(dllexport) UR6ServerInfo*			GServerOptions			= 0;
__declspec(dllexport) UR6GameOptions*			GGameOptions			= 0;
__declspec(dllexport) UGlobalTempObjects*		GGlobalTempObjects		= 0;
__declspec(dllexport) AR6eviLTesting*			GEvilTest				= 0;





















#pragma pack (push,4)















__declspec(dllexport) FName ENGINE_AIHearSound;
__declspec(dllexport) FName ENGINE_Accept;
__declspec(dllexport) FName ENGINE_AcceptInventory;
__declspec(dllexport) FName ENGINE_ActionStart;
__declspec(dllexport) FName ENGINE_ActorEntered;
__declspec(dllexport) FName ENGINE_ActorEnteredVolume;
__declspec(dllexport) FName ENGINE_ActorLeaving;
__declspec(dllexport) FName ENGINE_ActorLeavingVolume;
__declspec(dllexport) FName ENGINE_AddCameraEffect;
__declspec(dllexport) FName ENGINE_AddInteraction;
__declspec(dllexport) FName ENGINE_AnimEnd;
__declspec(dllexport) FName ENGINE_Attach;
__declspec(dllexport) FName ENGINE_BaseChange;
__declspec(dllexport) FName ENGINE_BeginEvent;
__declspec(dllexport) FName ENGINE_BeginPlay;
__declspec(dllexport) FName ENGINE_BreathTimer;
__declspec(dllexport) FName ENGINE_Broadcast;
__declspec(dllexport) FName ENGINE_BroadcastLocalized;
__declspec(dllexport) FName ENGINE_BroadcastLocalizedMessage;
__declspec(dllexport) FName ENGINE_Bump;
__declspec(dllexport) FName ENGINE_CanPlayIntroVideo;
__declspec(dllexport) FName ENGINE_CanPlayOutroVideo;
__declspec(dllexport) FName ENGINE_ChangeAnimation;
__declspec(dllexport) FName ENGINE_ClientHearSound;
__declspec(dllexport) FName ENGINE_ClientMessage;
__declspec(dllexport) FName ENGINE_ClientPBKickedOutMessage;
__declspec(dllexport) FName ENGINE_ClientSetNewViewTarget;
__declspec(dllexport) FName ENGINE_ClientTravel;
__declspec(dllexport) FName ENGINE_ConnectionFailed;
__declspec(dllexport) FName ENGINE_ConvertKeyToLocalisation;
__declspec(dllexport) FName ENGINE_DemoPlaySound;
__declspec(dllexport) FName ENGINE_DeployWeaponBipod;
__declspec(dllexport) FName ENGINE_Destroyed;
__declspec(dllexport) FName ENGINE_Detach;
__declspec(dllexport) FName ENGINE_DetailChange;
__declspec(dllexport) FName ENGINE_EncroachedBy;
__declspec(dllexport) FName ENGINE_EncroachingOn;
__declspec(dllexport) FName ENGINE_EndClimbLadder;
__declspec(dllexport) FName ENGINE_EndCrouch;
__declspec(dllexport) FName ENGINE_EndEvent;
__declspec(dllexport) FName ENGINE_EndedRotation;
__declspec(dllexport) FName ENGINE_EnemyNotVisible;
__declspec(dllexport) FName ENGINE_EyePosition;
__declspec(dllexport) FName ENGINE_Falling;
__declspec(dllexport) FName ENGINE_FellOutOfWorld;
__declspec(dllexport) FName ENGINE_FinishedInterpolation;
__declspec(dllexport) FName ENGINE_ForceGenerate;
__declspec(dllexport) FName ENGINE_GMProcessMsg;
__declspec(dllexport) FName ENGINE_GainedChild;
__declspec(dllexport) FName ENGINE_GameEnding;
__declspec(dllexport) FName ENGINE_GameTypeUseNbOfTerroristToSpawn;
__declspec(dllexport) FName ENGINE_Generate;
__declspec(dllexport) FName ENGINE_GetBackgroundsRoot;
__declspec(dllexport) FName ENGINE_GetBeaconText;
__declspec(dllexport) FName ENGINE_GetCampaignDir;
__declspec(dllexport) FName ENGINE_GetDefaultCampaignDir;
__declspec(dllexport) FName ENGINE_GetGameTypeIndex;
__declspec(dllexport) FName ENGINE_GetGameTypeName;
__declspec(dllexport) FName ENGINE_GetIniFilesDir;
__declspec(dllexport) FName ENGINE_GetLocalLogFileName;
__declspec(dllexport) FName ENGINE_GetLocalPlayerIp;
__declspec(dllexport) FName ENGINE_GetMapsDir;
__declspec(dllexport) FName ENGINE_GetModKeyword;
__declspec(dllexport) FName ENGINE_GetModName;
__declspec(dllexport) FName ENGINE_GetNbMods;
__declspec(dllexport) FName ENGINE_GetReticuleInfo;
__declspec(dllexport) FName ENGINE_GetServerIni;
__declspec(dllexport) FName ENGINE_GetSkins;
__declspec(dllexport) FName ENGINE_GetStoreGamePwd;
__declspec(dllexport) FName ENGINE_GetVideosRoot;
__declspec(dllexport) FName ENGINE_GetViewRotation;
__declspec(dllexport) FName ENGINE_HandleServerMsg;
__declspec(dllexport) FName ENGINE_HeadVolumeChange;
__declspec(dllexport) FName ENGINE_HearNoise;
__declspec(dllexport) FName ENGINE_HitWall;
__declspec(dllexport) FName ENGINE_Init;
__declspec(dllexport) FName ENGINE_InitGame;
__declspec(dllexport) FName ENGINE_InitInputSystem;
__declspec(dllexport) FName ENGINE_InitModMgr;
__declspec(dllexport) FName ENGINE_InitMultiPlayerOptions;
__declspec(dllexport) FName ENGINE_Initialize;
__declspec(dllexport) FName ENGINE_Initialized;
__declspec(dllexport) FName ENGINE_IsGameTypePlayWithNonRainbowNPCs;
__declspec(dllexport) FName ENGINE_IsGoggles;
__declspec(dllexport) FName ENGINE_IsMissionPack;
__declspec(dllexport) FName ENGINE_IsPlayerPassiveSpectator;
__declspec(dllexport) FName ENGINE_IsRavenShield;
__declspec(dllexport) FName ENGINE_KApplyForce;
__declspec(dllexport) FName ENGINE_KForceExceed;
__declspec(dllexport) FName ENGINE_KImpact;
__declspec(dllexport) FName ENGINE_KSkelConvulse;
__declspec(dllexport) FName ENGINE_KVelDropBelow;
__declspec(dllexport) FName ENGINE_KeyFrameReached;
__declspec(dllexport) FName ENGINE_KilledBy;
__declspec(dllexport) FName ENGINE_Landed;
__declspec(dllexport) FName ENGINE_LaunchR6MainMenu;
__declspec(dllexport) FName ENGINE_LightUpdateDirect;
__declspec(dllexport) FName ENGINE_LogGameSpecial;
__declspec(dllexport) FName ENGINE_LogGameSpecial2;
__declspec(dllexport) FName ENGINE_LogThis;
__declspec(dllexport) FName ENGINE_Login;
__declspec(dllexport) FName ENGINE_LongFall;
__declspec(dllexport) FName ENGINE_LostChild;
__declspec(dllexport) FName ENGINE_MayFall;
__declspec(dllexport) FName ENGINE_MenuLoadProfile;
__declspec(dllexport) FName ENGINE_MonitoredPawnAlert;
__declspec(dllexport) FName ENGINE_NewServerState;
__declspec(dllexport) FName ENGINE_Notify;
__declspec(dllexport) FName ENGINE_NotifyAfterLevelChange;
__declspec(dllexport) FName ENGINE_NotifyBump;
__declspec(dllexport) FName ENGINE_NotifyHeadVolumeChange;
__declspec(dllexport) FName ENGINE_NotifyHitMover;
__declspec(dllexport) FName ENGINE_NotifyHitWall;
__declspec(dllexport) FName ENGINE_NotifyLanded;
__declspec(dllexport) FName ENGINE_NotifyLevelChange;
__declspec(dllexport) FName ENGINE_NotifyPhysicsVolumeChange;
__declspec(dllexport) FName ENGINE_PawnEnteredVolume;
__declspec(dllexport) FName ENGINE_PawnIsMoving;
__declspec(dllexport) FName ENGINE_PawnLeavingVolume;
__declspec(dllexport) FName ENGINE_PawnStoppedMoving;
__declspec(dllexport) FName ENGINE_PhysicsChangedFor;
__declspec(dllexport) FName ENGINE_PhysicsVolumeChange;
__declspec(dllexport) FName ENGINE_PlayDying;
__declspec(dllexport) FName ENGINE_PlayFalling;
__declspec(dllexport) FName ENGINE_PlayJump;
__declspec(dllexport) FName ENGINE_PlayLandingAnimation;
__declspec(dllexport) FName ENGINE_PlayWeaponAnimation;
__declspec(dllexport) FName ENGINE_PlayerCalcView;
__declspec(dllexport) FName ENGINE_PlayerInput;
__declspec(dllexport) FName ENGINE_PlayerSeesMe;
__declspec(dllexport) FName ENGINE_PlayerTick;
__declspec(dllexport) FName ENGINE_PostBeginPlay;
__declspec(dllexport) FName ENGINE_PostFadeRender;
__declspec(dllexport) FName ENGINE_PostLogin;
__declspec(dllexport) FName ENGINE_PostNetBeginPlay;
__declspec(dllexport) FName ENGINE_PostRender;
__declspec(dllexport) FName ENGINE_PostTeleport;
__declspec(dllexport) FName ENGINE_PostTouch;
__declspec(dllexport) FName ENGINE_PreBeginPlay;
__declspec(dllexport) FName ENGINE_PreClientTravel;
__declspec(dllexport) FName ENGINE_PreLogOut;
__declspec(dllexport) FName ENGINE_PreLogin;
__declspec(dllexport) FName ENGINE_PreTeleport;
__declspec(dllexport) FName ENGINE_PrepareForMove;
__declspec(dllexport) FName ENGINE_ProcessHeart;
__declspec(dllexport) FName ENGINE_Process_KeyEvent;
__declspec(dllexport) FName ENGINE_Process_KeyType;
__declspec(dllexport) FName ENGINE_Process_Message;
__declspec(dllexport) FName ENGINE_Process_PostRender;
__declspec(dllexport) FName ENGINE_Process_PreRender;
__declspec(dllexport) FName ENGINE_Process_Tick;
__declspec(dllexport) FName ENGINE_R6ConnectionFailed;
__declspec(dllexport) FName ENGINE_R6ConnectionInProgress;
__declspec(dllexport) FName ENGINE_R6ConnectionInterrupted;
__declspec(dllexport) FName ENGINE_R6ConnectionSuccess;
__declspec(dllexport) FName ENGINE_R6DeadEndedMoving;
__declspec(dllexport) FName ENGINE_R6MakeNoise;
__declspec(dllexport) FName ENGINE_R6ProgressMsg;
__declspec(dllexport) FName ENGINE_R6QueryCircumstantialAction;
__declspec(dllexport) FName ENGINE_ReceiveLocalizedMessage;
__declspec(dllexport) FName ENGINE_ReceivedEngineWeapon;
__declspec(dllexport) FName ENGINE_ReceivedWeapons;
__declspec(dllexport) FName ENGINE_RemoveCameraEffect;
__declspec(dllexport) FName ENGINE_RemoveInteraction;
__declspec(dllexport) FName ENGINE_RenderFirstPersonGun;
__declspec(dllexport) FName ENGINE_Reset;
__declspec(dllexport) FName ENGINE_RestartServer;
__declspec(dllexport) FName ENGINE_RunAll;
__declspec(dllexport) FName ENGINE_SaveAndResetData;
__declspec(dllexport) FName ENGINE_SaveRemoteServerSettings;
__declspec(dllexport) FName ENGINE_SceneEnded;
__declspec(dllexport) FName ENGINE_SceneStarted;
__declspec(dllexport) FName ENGINE_SeeMonster;
__declspec(dllexport) FName ENGINE_SeePlayer;
__declspec(dllexport) FName ENGINE_ServerDisconnected;
__declspec(dllexport) FName ENGINE_ServerTravel;
__declspec(dllexport) FName ENGINE_SetAnimAction;
__declspec(dllexport) FName ENGINE_SetCurrentMod;
__declspec(dllexport) FName ENGINE_SetFocusTo;
__declspec(dllexport) FName ENGINE_SetIdentifyTarget;
__declspec(dllexport) FName ENGINE_SetInitialState;
__declspec(dllexport) FName ENGINE_SetMatchResult;
__declspec(dllexport) FName ENGINE_SetProgressTime;
__declspec(dllexport) FName ENGINE_SetWalking;
__declspec(dllexport) FName ENGINE_ShowUpgradeMenu;
__declspec(dllexport) FName ENGINE_ShowWeaponParticules;
__declspec(dllexport) FName ENGINE_SpecialCost;
__declspec(dllexport) FName ENGINE_SpecialHandling;
__declspec(dllexport) FName ENGINE_Spawned;
__declspec(dllexport) FName ENGINE_StartCrouch;
__declspec(dllexport) FName ENGINE_StopAnimForRG;
__declspec(dllexport) FName ENGINE_StopPlayFiring;
__declspec(dllexport) FName ENGINE_SuggestMovePreparation;
__declspec(dllexport) FName ENGINE_TeamMessage;
__declspec(dllexport) FName ENGINE_Tick;
__declspec(dllexport) FName ENGINE_Timer;
__declspec(dllexport) FName ENGINE_ToggleRadar;
__declspec(dllexport) FName ENGINE_TornOff;
__declspec(dllexport) FName ENGINE_Touch;
__declspec(dllexport) FName ENGINE_TravelPostAccept;
__declspec(dllexport) FName ENGINE_TravelPreAccept;
__declspec(dllexport) FName ENGINE_Trigger;
__declspec(dllexport) FName ENGINE_TriggerEvent;
__declspec(dllexport) FName ENGINE_UnTouch;
__declspec(dllexport) FName ENGINE_UnTrigger;
__declspec(dllexport) FName ENGINE_UpdateServer;
__declspec(dllexport) FName ENGINE_UpdateShadow;
__declspec(dllexport) FName ENGINE_UpdateWeaponAttachment;
__declspec(dllexport) FName ENGINE_UsedBy;
__declspec(dllexport) FName ENGINE_UserDisconnected;
__declspec(dllexport) FName ENGINE_WorldSpaceOverlays;
__declspec(dllexport) FName ENGINE_ZoneChange;






























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































#pragma pack (pop)









