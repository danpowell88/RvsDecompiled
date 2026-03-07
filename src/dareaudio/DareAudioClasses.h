/*===========================================================================
	DareAudioClasses.h: UDareAudioSubsystem class declaration.
	Reconstructed from DareAudio.dll export table (87 symbols).

	UDareAudioSubsystem inherits from UAudioSubsystem (which inherits from
	USubsystem → UObject) and implements the FExec interface for console
	command processing. This dual inheritance produces two vtables, visible
	as ??_7UDareAudioSubsystem@@6BFExec@@@ and @@6BUObject@@@.

	The class acts as a bridge between Unreal Engine's audio API and the
	DARE (Digital Audio Rendering Engine) middleware. Static __stdcall
	callbacks (GetActorPos, GetMicroPos, etc.) are registered with DARE
	so it can query actor/microphone positions each audio frame.
===========================================================================*/

#if _MSC_VER
#pragma pack(push, 4)
#endif

#ifndef DAREAUDIO_API
#define DAREAUDIO_API DLL_IMPORT
#endif

/*==========================================================================
	UDareAudioSubsystem
==========================================================================*/

class DAREAUDIO_API UDareAudioSubsystem : public UAudioSubsystem
{
public:
	DECLARE_CLASS(UDareAudioSubsystem, UAudioSubsystem, CLASS_Config, DareAudio)

	// --- Constructors / Assignment ---
	// Note: destructor and InternalConstructor are provided by DECLARE_CLASS.
	UDareAudioSubsystem();
	UDareAudioSubsystem(const UDareAudioSubsystem& Other);
	UDareAudioSubsystem& operator=(const UDareAudioSubsystem& Other);

	// --- UObject interface ---
	void StaticConstructor();
	virtual void PostEditChange();
	virtual void Destroy();
	virtual void ShutdownAfterError();

	// --- FExec interface ---
	virtual UBOOL Exec(const TCHAR* Cmd, FOutputDevice& Ar);

	// --- UAudioSubsystem interface ---
	virtual UBOOL Init();
	virtual void CleanUp();
	virtual UViewport* GetViewport();
	virtual UBOOL SetViewport(UViewport* InViewport, FString DeviceName);
	virtual void Update(FSceneNode* SceneNode);

	// --- Sound registration ---
	virtual void RegisterSound(USound* Sound);
	virtual void UnregisterSound(USound* Sound);

	// --- Sound playback ---
	virtual UBOOL PlaySoundW(AActor* Actor, USound* Sound, INT Slot, INT Flags);
	virtual UBOOL StopSound(AActor* Actor, USound* Sound);
	virtual void StopAllSounds();
	virtual void StopAllSoundsActor(AActor* Actor, ESoundSlot Slot);
	virtual void NoteDestroy(AActor* Actor);

	// --- Music ---
	virtual UBOOL PlayMusic(USound* Music, INT SongSection);
	virtual UBOOL PlayMusic(FString MusicName, FLOAT FadeInTime);
	virtual UBOOL StopMusic(USound* Music);
	virtual UBOOL StopMusic(INT SongSection, FLOAT FadeOutTime);
	virtual UBOOL StopAllMusic(FLOAT FadeOutTime);
	virtual void StopAllMusic();

	// --- Bank / Map loading ---
	virtual void AddAndFindBankInSound(USound* Sound, ELoadBankSound LoadType);
	virtual void AddSoundBank(FString BankName, ELoadBankSound LoadType);
	virtual void LoadBankMap(ULevel* Level, FString MapName);
	virtual void PostLoadMap(ULevel* Level);
	virtual void SetBankInfo(ER6SoundState State);

	// --- Sound queries ---
	virtual FLOAT GetDuration(USound* Sound);
	virtual FLOAT GetPosition(AActor* Actor, USound* Sound);
	virtual UBOOL SND_IsSoundPlaying(AActor* Actor, USound* Sound);
	UBOOL IsPlayingAnyActor(USound* Sound);

	// --- Volume control ---
	virtual FLOAT SND_GetVolume_TypeSound(ESoundSlot Slot);
	virtual FLOAT SND_GetVolumeInit_TypeSound(ESoundSlot Slot);
	virtual FLOAT SND_GetVolumeLine(ESoundVolume VolType);
	virtual void SND_SetVolumeLine(ESoundVolume VolType, FLOAT Volume);
	virtual void SND_ChangeVolume_TypeSound(ESoundSlot Slot, FLOAT Volume);
	virtual void SND_ChangeVolumeLinear_TypeSound(ESoundSlot Slot, INT Volume);
	virtual void SND_ChangeVolume_AllTypeSound(FLOAT Volume);
	virtual void SND_ChangeVolume_AllButOneTypeSound(ESoundSlot Slot, FLOAT Volume);
	virtual void SND_ChangeVolume_Actor(AActor* Actor, ESoundSlot Slot, FLOAT Volume);
	virtual void SND_ResetVolumeSoundObjectType(ESoundSlot Slot);
	virtual void SND_ResetVolume_AllTypeSound();
	virtual void SND_ResetVolume_ButOneTypeSound(ESoundSlot Slot);

	// --- Fade ---
	virtual void SND_FadeSound(FLOAT FadeTime, INT Direction, ESoundSlot Slot);
	virtual void SND_SaveCurrentFadeValue();
	virtual void SND_ReturnSavedFadeValue(FLOAT FadeTime);

	// --- Sound options ---
	virtual void SND_SetSoundOptions(bool bEAX, FString DeviceName);

	// --- Tick ---
	virtual void TickUpdate(FLOAT DeltaTime, ALevelInfo* LevelInfo);

	// --- Ambient sounds ---
	void UpdateAmbientSounds(FCoords& Coords);
	void UpdateSoundList();

private:
	// --- Private helper methods ---
	FLOAT GetDuration(DWORD SoundHandle);
	void CreateMicro();
	void CreateSoundTypes();
	void CreateVolumeLines();
	void StopSoundPlaying(FString EventName);

	// --- Static DARE callbacks (registered with the DARE engine) ---
	// These are called by DARE each audio frame to query game state.
	static void    __stdcall GetActorInfo(long ActorId, char* InfoBuffer, long BufferSize);
	static INT     __stdcall GetActorMicroLink(long ActorId, long MicroId);
	static long    __stdcall GetActorMultiLayer(long ActorId, long LayerId, int Param);
	static void    __stdcall GetActorPos(long ActorId, _SND_tdstVectorFloat* OutPos);
	static INT     __stdcall GetActorRollOff(long ActorId, _SND_tdstRollOffParam* OutRollOff);
	static void    __stdcall GetActorSpeed(long ActorId, _SND_tdstVectorFloat* OutSpeed);
	static long    __stdcall GetActorSwitch(long ActorId, long SwitchId);
	static void    __stdcall GetMicroPos(long MicroId, _SND_tdstVectorFloat* OutPos);
	static void    __stdcall GetMicroSpeed(long MicroId, _SND_tdstVectorFloat* OutSpeed);
	static void    __stdcall GetMicroNormal(long MicroId, _SND_tdstVectorFloat* OutNormal);
	static void    __stdcall GetMicroTangeant(long MicroId, _SND_tdstVectorFloat* OutTangent);
	static void    __stdcall GetSoundExtraCoef(long ActorId, _SND_tdstBlockEvent* Event, FLOAT* OutCoef1, FLOAT* OutCoef2, FLOAT* OutCoef3);

	// --- Static data members ---
	static FLOAT*   m_VolumeInit;
	static INT      m_bInitialized;
	static AActor*  m_pLastAmbienceObject;
	static AActor*  m_pLastViewPortActor;

public:
	// m_pViewport is public static (@@2 in mangled name)
	static UViewport* m_pViewport;
};

#if _MSC_VER
#pragma pack(pop)
#endif
