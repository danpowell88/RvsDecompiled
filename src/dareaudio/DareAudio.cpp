/*=============================================================================
	DareAudio.cpp: DARE Audio Subsystem implementation.
	Reconstructed for Ravenshield decompilation project.

	UDareAudioSubsystem bridges Unreal Engine audio to the DARE middleware.
	Three DLL variants are built from this source:
	  - DareAudio.dll        (links SNDDSound3DDLL_ret.dll)
	  - DareAudioScript.dll  (links SNDDSound3DDLL_VSR.dll)
	  - DareAudioRelease.dll (links SNDDSound3DDLL_VBD.dll — not in retail)
=============================================================================*/

#include "DareAudioPrivate.h"

/*-----------------------------------------------------------------------------
	Package.
-----------------------------------------------------------------------------*/

IMPLEMENT_PACKAGE(DareAudio);

/*-----------------------------------------------------------------------------
	UDareAudioSubsystem class registration.
-----------------------------------------------------------------------------*/

IMPLEMENT_CLASS(UDareAudioSubsystem);

/*-----------------------------------------------------------------------------
	Static data member definitions.
	These are exported at ordinals 80-84.
-----------------------------------------------------------------------------*/

FLOAT*     UDareAudioSubsystem::m_VolumeInit          = NULL;
INT        UDareAudioSubsystem::m_bInitialized        = 0;
AActor*    UDareAudioSubsystem::m_pLastAmbienceObject  = NULL;
AActor*    UDareAudioSubsystem::m_pLastViewPortActor   = NULL;
UViewport* UDareAudioSubsystem::m_pViewport            = NULL;

/*-----------------------------------------------------------------------------
	Constructors / Destructor / Assignment.
-----------------------------------------------------------------------------*/

UDareAudioSubsystem::UDareAudioSubsystem()
{
}

UDareAudioSubsystem::UDareAudioSubsystem(const UDareAudioSubsystem& Other)
	: UAudioSubsystem(Other)
{
}

UDareAudioSubsystem& UDareAudioSubsystem::operator=(const UDareAudioSubsystem& Other)
{
	UAudioSubsystem::operator=(Other);
	return *this;
}

/*-----------------------------------------------------------------------------
	UObject interface.
-----------------------------------------------------------------------------*/

void UDareAudioSubsystem::StaticConstructor()
{
}

void UDareAudioSubsystem::PostEditChange()
{
}

void UDareAudioSubsystem::Destroy()
{
}

void UDareAudioSubsystem::ShutdownAfterError()
{
}

/*-----------------------------------------------------------------------------
	FExec interface.
-----------------------------------------------------------------------------*/

UBOOL UDareAudioSubsystem::Exec(const TCHAR* Cmd, FOutputDevice& Ar)
{
	return 0;
}

/*-----------------------------------------------------------------------------
	UAudioSubsystem interface — Initialisation.
-----------------------------------------------------------------------------*/

UBOOL UDareAudioSubsystem::Init()
{
	return 1;
}

void UDareAudioSubsystem::CleanUp()
{
}

UViewport* UDareAudioSubsystem::GetViewport()
{
	return m_pViewport;
}

UBOOL UDareAudioSubsystem::SetViewport(UViewport* InViewport, FString DeviceName)
{
	return 0;
}

void UDareAudioSubsystem::Update(FSceneNode* SceneNode)
{
}

/*-----------------------------------------------------------------------------
	Sound registration.
-----------------------------------------------------------------------------*/

void UDareAudioSubsystem::RegisterSound(USound* Sound)
{
}

void UDareAudioSubsystem::UnregisterSound(USound* Sound)
{
}

/*-----------------------------------------------------------------------------
	Sound playback.
-----------------------------------------------------------------------------*/

UBOOL UDareAudioSubsystem::PlaySoundW(AActor* Actor, USound* Sound, INT Slot, INT Flags)
{
	return 0;
}

UBOOL UDareAudioSubsystem::StopSound(AActor* Actor, USound* Sound)
{
	return 0;
}

void UDareAudioSubsystem::StopAllSounds()
{
}

void UDareAudioSubsystem::StopAllSoundsActor(AActor* Actor, ESoundSlot Slot)
{
}

void UDareAudioSubsystem::NoteDestroy(AActor* Actor)
{
}

/*-----------------------------------------------------------------------------
	Music.
-----------------------------------------------------------------------------*/

UBOOL UDareAudioSubsystem::PlayMusic(USound* Music, INT SongSection)
{
	return 0;
}

UBOOL UDareAudioSubsystem::PlayMusic(FString MusicName, FLOAT FadeInTime)
{
	return 0;
}

UBOOL UDareAudioSubsystem::StopMusic(USound* Music)
{
	return 0;
}

UBOOL UDareAudioSubsystem::StopMusic(INT SongSection, FLOAT FadeOutTime)
{
	return 0;
}

UBOOL UDareAudioSubsystem::StopAllMusic(FLOAT FadeOutTime)
{
	return 0;
}

void UDareAudioSubsystem::StopAllMusic()
{
}

/*-----------------------------------------------------------------------------
	Bank / Map loading.
-----------------------------------------------------------------------------*/

void UDareAudioSubsystem::AddAndFindBankInSound(USound* Sound, ELoadBankSound LoadType)
{
}

void UDareAudioSubsystem::AddSoundBank(FString BankName, ELoadBankSound LoadType)
{
}

void UDareAudioSubsystem::LoadBankMap(ULevel* Level, FString MapName)
{
}

void UDareAudioSubsystem::PostLoadMap(ULevel* Level)
{
}

void UDareAudioSubsystem::SetBankInfo(ER6SoundState State)
{
}

/*-----------------------------------------------------------------------------
	Sound queries.
-----------------------------------------------------------------------------*/

FLOAT UDareAudioSubsystem::GetDuration(USound* Sound)
{
	return 0.0f;
}

FLOAT UDareAudioSubsystem::GetPosition(AActor* Actor, USound* Sound)
{
	return 0.0f;
}

UBOOL UDareAudioSubsystem::SND_IsSoundPlaying(AActor* Actor, USound* Sound)
{
	return 0;
}

UBOOL UDareAudioSubsystem::IsPlayingAnyActor(USound* Sound)
{
	return 0;
}

/*-----------------------------------------------------------------------------
	Volume control.
-----------------------------------------------------------------------------*/

FLOAT UDareAudioSubsystem::SND_GetVolume_TypeSound(ESoundSlot Slot)
{
	return 0.0f;
}

FLOAT UDareAudioSubsystem::SND_GetVolumeInit_TypeSound(ESoundSlot Slot)
{
	return 0.0f;
}

FLOAT UDareAudioSubsystem::SND_GetVolumeLine(ESoundVolume VolType)
{
	return 0.0f;
}

void UDareAudioSubsystem::SND_SetVolumeLine(ESoundVolume VolType, FLOAT Volume)
{
}

void UDareAudioSubsystem::SND_ChangeVolume_TypeSound(ESoundSlot Slot, FLOAT Volume)
{
}

void UDareAudioSubsystem::SND_ChangeVolumeLinear_TypeSound(ESoundSlot Slot, INT Volume)
{
}

void UDareAudioSubsystem::SND_ChangeVolume_AllTypeSound(FLOAT Volume)
{
}

void UDareAudioSubsystem::SND_ChangeVolume_AllButOneTypeSound(ESoundSlot Slot, FLOAT Volume)
{
}

void UDareAudioSubsystem::SND_ChangeVolume_Actor(AActor* Actor, ESoundSlot Slot, FLOAT Volume)
{
}

void UDareAudioSubsystem::SND_ResetVolumeSoundObjectType(ESoundSlot Slot)
{
}

void UDareAudioSubsystem::SND_ResetVolume_AllTypeSound()
{
}

void UDareAudioSubsystem::SND_ResetVolume_ButOneTypeSound(ESoundSlot Slot)
{
}

/*-----------------------------------------------------------------------------
	Fade.
-----------------------------------------------------------------------------*/

void UDareAudioSubsystem::SND_FadeSound(FLOAT FadeTime, INT Direction, ESoundSlot Slot)
{
}

void UDareAudioSubsystem::SND_SaveCurrentFadeValue()
{
}

void UDareAudioSubsystem::SND_ReturnSavedFadeValue(FLOAT FadeTime)
{
}

/*-----------------------------------------------------------------------------
	Sound options.
-----------------------------------------------------------------------------*/

void UDareAudioSubsystem::SND_SetSoundOptions(bool bEAX, FString DeviceName)
{
}

/*-----------------------------------------------------------------------------
	Tick.
-----------------------------------------------------------------------------*/

void UDareAudioSubsystem::TickUpdate(FLOAT DeltaTime, ALevelInfo* LevelInfo)
{
}

/*-----------------------------------------------------------------------------
	Ambient sounds / Update helpers.
-----------------------------------------------------------------------------*/

void UDareAudioSubsystem::UpdateAmbientSounds(FCoords& Coords)
{
}

void UDareAudioSubsystem::UpdateSoundList()
{
}

/*-----------------------------------------------------------------------------
	Private helpers.
-----------------------------------------------------------------------------*/

FLOAT UDareAudioSubsystem::GetDuration(DWORD SoundHandle)
{
	return 0.0f;
}

void UDareAudioSubsystem::CreateMicro()
{
}

void UDareAudioSubsystem::CreateSoundTypes()
{
}

void UDareAudioSubsystem::CreateVolumeLines()
{
}

void UDareAudioSubsystem::StopSoundPlaying(FString EventName)
{
}

/*-----------------------------------------------------------------------------
	Static DARE callbacks.
	These are registered with the DARE engine via SND_fn_vSetRet* calls.
	DARE calls them each audio frame to query game-world state.
-----------------------------------------------------------------------------*/

void __stdcall UDareAudioSubsystem::GetActorInfo(long ActorId, char* InfoBuffer, long BufferSize)
{
}

INT __stdcall UDareAudioSubsystem::GetActorMicroLink(long ActorId, long MicroId)
{
	return 0;
}

long __stdcall UDareAudioSubsystem::GetActorMultiLayer(long ActorId, long LayerId, int Param)
{
	return 0;
}

void __stdcall UDareAudioSubsystem::GetActorPos(long ActorId, _SND_tdstVectorFloat* OutPos)
{
}

INT __stdcall UDareAudioSubsystem::GetActorRollOff(long ActorId, _SND_tdstRollOffParam* OutRollOff)
{
	return 0;
}

void __stdcall UDareAudioSubsystem::GetActorSpeed(long ActorId, _SND_tdstVectorFloat* OutSpeed)
{
}

long __stdcall UDareAudioSubsystem::GetActorSwitch(long ActorId, long SwitchId)
{
	return 0;
}

void __stdcall UDareAudioSubsystem::GetMicroPos(long MicroId, _SND_tdstVectorFloat* OutPos)
{
}

void __stdcall UDareAudioSubsystem::GetMicroSpeed(long MicroId, _SND_tdstVectorFloat* OutSpeed)
{
}

void __stdcall UDareAudioSubsystem::GetMicroNormal(long MicroId, _SND_tdstVectorFloat* OutNormal)
{
}

void __stdcall UDareAudioSubsystem::GetMicroTangeant(long MicroId, _SND_tdstVectorFloat* OutTangent)
{
}

void __stdcall UDareAudioSubsystem::GetSoundExtraCoef(long ActorId, _SND_tdstBlockEvent* Event, FLOAT* OutCoef1, FLOAT* OutCoef2, FLOAT* OutCoef3)
{
}
