/*=============================================================================
	R6WeaponsClasses.h: R6Weapons class declarations.
	Reconstructed from Ravenshield 1.56 SDK and Ghidra analysis.

	9 classes: Weapons, bullets, gadgets, grenades, reticule, smoke.
=============================================================================*/

#if _MSC_VER
#pragma pack(push, 4)
#endif

#ifndef R6WEAPONS_API
#define R6WEAPONS_API DLL_IMPORT
#endif

/*==========================================================================
	AUTOGENERATE_NAME / AUTOGENERATE_FUNCTION entries.
==========================================================================*/

#ifndef NAMES_ONLY
#undef  AUTOGENERATE_NAME
#undef  AUTOGENERATE_FUNCTION
#define AUTOGENERATE_NAME(name) extern R6WEAPONS_API FName R6WEAPONS_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif

AUTOGENERATE_NAME(HideAttachment)
AUTOGENERATE_NAME(NbBulletChange)
AUTOGENERATE_NAME(SetGadgetStaticMesh)

#ifndef NAMES_ONLY

/*==========================================================================
	Forward declarations.
==========================================================================*/

class AR6Pawn;
class AR6PlayerController;
class AR6SFX;
class AR6BulletManager;
class AR6Reticule;
class AEmitter;
class AR6DemolitionsGadget;

/*==========================================================================
	Enums.
==========================================================================*/

enum eHitResult
{
	HR_NoMaterial = 0,
	HR_Explode    = 1,
	HR_Ricochet   = 2,
	HR_GoThrough  = 3,
};

/*==========================================================================
	Structs.
==========================================================================*/

struct FstAccuracyType
{
	FLOAT fBaseAccuracy;
	FLOAT fShuffleAccuracy;
	FLOAT fWalkingAccuracy;
	FLOAT fWalkingFastAccuracy;
	FLOAT fRunningAccuracy;
	FLOAT fReticuleTime;
	FLOAT fAccuracyChange;
	FLOAT fWeaponJump;
};

struct FstWeaponCaps
{
	INT bSingle;
	INT bThreeRound;
	INT bFullAuto;
	INT bCMag;
	INT bSilencer;
	INT bLight;
	INT bMiniScope;
	INT bHeatVision;
};

struct FsDamagePercentage
{
	FLOAT fHead;
	FLOAT fBody;
	FLOAT fArms;
	FLOAT fLegs;
};

/*==========================================================================
	AR6Weapons
==========================================================================*/

class R6WEAPONS_API AR6Weapons : public AR6AbstractWeapon
{
public:
	DECLARE_CLASS(AR6Weapons, AR6AbstractWeapon, 0, R6Weapons)

	BYTE  m_aiNbOfBullets[20];
	BYTE  m_iNbOfRoundsInBurst;
	BYTE  m_eRateOfFire;
	BYTE  m_wNbOfBounce;
	INT   C_iMaxNbOfClips;
	INT   m_iClipCapacity;
	INT   m_iNbOfClips;
	INT   m_iNbOfExtraClips;
	INT   m_iCurrentClip;
	INT   m_iNbOfRoundsToShoot;
	INT   m_iCurrentNbOfClips;
	INT   m_iCurrentAverage;
	INT   m_iDbgNextReticule;
	BITFIELD m_bPlayLoopingSound : 1;
	BITFIELD m_bSoundLog : 1;
	BITFIELD bShowLog : 1;
	BITFIELD m_bFireOn : 1;
	BITFIELD m_bEmptyAllClips : 1;
	FLOAT m_fMuzzleVelocity;
	FLOAT m_MuzzleScale;
	FLOAT m_fAverageDegChanges;
	FLOAT m_fAverageDegTable[5];
	FLOAT m_fStablePercentage;
	FLOAT m_fWorstAccuracy;
	FLOAT m_fOldWorstAccuracy;
	FLOAT m_fEffectiveAccuracy;
	FLOAT m_fDesiredAccuracy;
	FLOAT m_fMaxAngleError;
	FLOAT m_fCurrentFireJump;
	FLOAT m_fFireSoundRadius;
	FLOAT m_fRateOfFire;
	FLOAT m_fDisplayFOV;
	UTexture*       m_WeaponIcon;
	AR6Reticule*    m_ReticuleInstance;
	AR6SFX*         m_pEmptyShellsEmitter;
	AR6SFX*         m_pMuzzleFlashEmitter;
	UClass*         m_pBulletClass;
	UClass*         m_pEmptyShells;
	UClass*         m_pMuzzleFlash;
	FstWeaponCaps   m_stWeaponCaps;
	FRotator        m_rLastRotation;
	FRotator        m_rBuckFirstBullet;
	FstAccuracyType m_stAccuracyValues;
	FVector         m_vPawnLocWhenKilled;
	FString         m_szReticuleClass;
	FString         m_szWithWeaponReticuleClass;

	virtual void  ProcessState(FLOAT);
	virtual INT   IsBlockedBy(AActor const*) const;
	virtual void  PreNetReceive();
	virtual void  PostNetReceive();
	virtual void  TickAuthoritative(FLOAT);
	virtual INT   GetHeartBeatStatus();
	virtual void  ShowWeaponParticles(AR6Pawn*, AR6PlayerController*);
	virtual FLOAT ComputeEffectiveAccuracy(FLOAT, FLOAT);
	virtual FLOAT GetMovingModifier(FLOAT, FLOAT);
	virtual bool  WeaponIsNotFiring();

	void eventHideAttachment();

AR6Weapons() {}
};

/*==========================================================================
	AR6Bullet
==========================================================================*/

class R6WEAPONS_API AR6Bullet : public AR6AbstractBullet
{
public:
	DECLARE_CLASS(AR6Bullet, AR6AbstractBullet, 0, R6Weapons)

	INT   m_iEnergy;
	INT   m_iPenetrationFactor;
	INT   m_iNoArmorModifier;
	INT   m_iBulletGroupID;
	BITFIELD m_bBulletIsGone : 1;
	BITFIELD m_bIsGrenade : 1;
	BITFIELD m_bBulletDeactivated : 1;
	BITFIELD bShowLog : 1;
	FLOAT m_fKillStunTransfer;
	FLOAT m_fRangeConversionConst;
	FLOAT m_fRange;
	FLOAT m_fExplosionRadius;
	FLOAT m_fKillBlastRadius;
	FLOAT m_fExplosionDelay;
	AActor*          m_AffectedActor;
	AR6BulletManager* m_BulletManager;
	FVector          m_vSpawnedPosition;
	FString          m_szAmmoName;
	FString          m_szAmmoType;
	FString          m_szBulletType;

	virtual INT IsBlockedBy(AActor const*) const;
	virtual INT ShouldTrace(AActor*, DWORD);

	FLOAT RangeConversion(FLOAT);
	FLOAT StunLoss(FLOAT);

	void execBulletGoesThroughSurface(FFrame& Stack, RESULT_DECL);

AR6Bullet() {}
};

/*==========================================================================
	AR6Gadget
==========================================================================*/

class R6WEAPONS_API AR6Gadget : public AR6Weapons
{
public:
	DECLARE_CLASS(AR6Gadget, AR6Weapons, 0, R6Weapons)

protected:
	AR6Gadget() {}
};

/*==========================================================================
	AR6Grenade
==========================================================================*/

class R6WEAPONS_API AR6Grenade : public AR6Bullet
{
public:
	DECLARE_CLASS(AR6Grenade, AR6Bullet, 0, R6Weapons)

	BYTE  m_eOldPhysic;
	BYTE  m_eExplosionSoundType;
	BYTE  m_eGrenadeType;
	INT   m_iNumberOfFragments;
	BITFIELD m_bFirstImpact : 1;
	BITFIELD m_bDestroyedByImpact : 1;
	FLOAT m_fDuration;
	FLOAT m_fShakeRadius;
	FLOAT m_fEffectiveOutsideKillRadius;
	USound*  m_sndExplosionSound;
	USound*  m_sndExplosionSoundStop;
	USound*  m_sndExplodeMetal;
	USound*  m_sndExplodeWater;
	USound*  m_sndExplodeAir;
	USound*  m_sndExplodeDirt;
	USound*  m_ImpactSound;
	USound*  m_ImpactGroundSound;
	USound*  m_ImpactWaterSound;
	USound*  m_sndEarthQuake;
	AR6DemolitionsGadget* m_Weapon;
	AEmitter*  m_pEmmiter;
	UClass*  m_pExplosionParticles;
	UClass*  m_pExplosionParticlesLOW;
	UClass*  m_pExplosionLight;
	UClass*  m_GrenadeDecalClass;
	FsDamagePercentage m_DmgPercentStand;
	FsDamagePercentage m_DmgPercentCrouch;
	FsDamagePercentage m_DmgPercentProne;

	virtual void PostNetReceive();

AR6Grenade() {}
};

/*==========================================================================
	AR6Reticule
==========================================================================*/

class R6WEAPONS_API AR6Reticule : public AActor
{
public:
	DECLARE_CLASS(AR6Reticule, AActor, 0, R6Weapons)

	INT   m_iNonFunctionnalX;
	INT   m_iNonFunctionnalY;
	BITFIELD m_bIdentifyCharacter : 1;
	BITFIELD m_bAimingAtFriendly : 1;
	BITFIELD m_bShowNames : 1;
	FLOAT m_fAccuracy;
	FLOAT m_fZoomScale;
	FLOAT m_fReticuleOffsetX;
	FLOAT m_fReticuleOffsetY;
	UFont*  m_SmallFont_14pt;
	FColor  m_color;
	FString m_CharacterName;

	void UpdateReticule(AR6PlayerController*, FLOAT);

AR6Reticule() {}
};

/*==========================================================================
	AR6DemolitionsGadget
==========================================================================*/

class R6WEAPONS_API AR6DemolitionsGadget : public AR6Gadget
{
public:
	DECLARE_CLASS(AR6DemolitionsGadget, AR6Gadget, 0, R6Weapons)

	BITFIELD m_bDetonated : 1;
	BITFIELD m_bChargeInPosition : 1;
	BITFIELD m_bCanPlaceCharge : 1;
	BITFIELD m_bInstallingCharge : 1;
	BITFIELD m_bCancelChargeInstallation : 1;
	BITFIELD m_bRaiseWeapon : 1;
	BITFIELD m_bHide : 1;
	BITFIELD m_bDetonator : 1;
	AR6Reticule*   m_ReticuleConfirm;
	AR6Reticule*   m_ReticuleBlock;
	AR6Reticule*   m_ReticuleDetonator;
	UStaticMesh*   m_DetonatorStaticMesh;
	UTexture*      m_DetonatorTexture;
	UStaticMesh*   m_ChargeStaticMesh;
	AR6Grenade*    BulletActor;
	FName          m_ChargeAttachPoint;
	FName          m_DetonatorAttachPoint;
	UClass*        m_pExplosionParticles;
	FVector        m_vLocation;
	FString        m_szReticuleBlockClass;
	FString        m_szDetonatorReticuleClass;

	virtual void PreNetReceive();
	virtual void PostNetReceive();

	void eventNbBulletChange();
	void eventSetGadgetStaticMesh();

AR6DemolitionsGadget() {}
};

/*==========================================================================
	AR6GrenadeWeapon
==========================================================================*/

class R6WEAPONS_API AR6GrenadeWeapon : public AR6Gadget
{
public:
	DECLARE_CLASS(AR6GrenadeWeapon, AR6Gadget, 0, R6Weapons)

	BYTE  m_eThrow;
	BITFIELD m_bCanThrowGrenade : 1;
	BITFIELD m_bFistPersonAnimFinish : 1;
	BITFIELD m_bPinToRemove : 1;
	BITFIELD m_bReadyToThrow : 1;

protected:
	AR6GrenadeWeapon() {}
};

/*==========================================================================
	AR6SmokeCloud
==========================================================================*/

class R6WEAPONS_API AR6SmokeCloud : public AActor
{
public:
	DECLARE_CLASS(AR6SmokeCloud, AActor, 0, R6Weapons)

	FLOAT     m_fStartTime;
	FLOAT     m_fExpansionTime;
	FLOAT     m_fFinalRadius;
	FLOAT     m_fCurrentRadius;
	AR6Grenade* m_grenade;

	virtual INT IsBlockedBy(AActor const*) const;
	virtual INT ShouldTrace(AActor*, DWORD);

AR6SmokeCloud() {}
};

/*==========================================================================
	AR6HBSGadget
==========================================================================*/

class R6WEAPONS_API AR6HBSGadget : public AR6Gadget
{
public:
	DECLARE_CLASS(AR6HBSGadget, AR6Gadget, 0, R6Weapons)

	BITFIELD m_bHeartBeatOn : 1;
	USound*  m_sndActivation;
	USound*  m_sndDesactivation;

	virtual INT GetHeartBeatStatus();

	void execToggleHeartBeatProperties(FFrame& Stack, RESULT_DECL);

AR6HBSGadget() {}
};

#endif // !NAMES_ONLY

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif

#if _MSC_VER
#pragma pack(pop)
#endif
