/*===========================================================================
	FireClasses.h: Ravenshield Fire class declarations.
	Reconstructed for decompilation — procedural texture classes.

	7 classes: UFractalTexture (base), UFireTexture, UWaterTexture,
	UWaveTexture, UFluidTexture, UIceTexture, UWetTexture.
===========================================================================*/
#if _MSC_VER
#pragma pack (push,4)
#endif

#ifndef FIRE_API
#define FIRE_API DLL_IMPORT
#endif

/*==========================================================================
	Helper structures used by Fire texture classes.
==========================================================================*/

class FSpark
{
public:
	BYTE Type;
	BYTE Heat;
	BYTE X;
	BYTE Y;
	BYTE ByteA;
	BYTE ByteB;
	BYTE ByteC;
	BYTE ByteD;

	FSpark& operator=( const FSpark& Other );
};

struct FDrop
{
	BYTE Type;
	BYTE Depth;
	BYTE X;
	BYTE Y;
	BYTE ByteA;
	BYTE ByteB;
	BYTE ByteC;
	BYTE ByteD;

	FDrop& operator=( const FDrop& Other );
};

struct KeyPoint
{
	BYTE Type;
	BYTE Heat;
	BYTE X;
	BYTE Y;
	BYTE ByteA;
	BYTE ByteB;
	BYTE ByteC;
	BYTE ByteD;

	KeyPoint& operator=( const KeyPoint& Other );
};

struct LineSeg
{
	BYTE X1;
	BYTE Y1;
	BYTE X2;
	BYTE Y2;
};

/*==========================================================================
	UFractalTexture — base for all procedural Fire textures.
	Exported from Fire.dll.
==========================================================================*/

class FIRE_API UFractalTexture : public UTexture
{
	DECLARE_CLASS(UFractalTexture,UTexture,0,Fire)

	// UFractalTexture interface.
	virtual void Init( INT InUSize, INT InVSize );
	virtual void PostLoad();
	virtual void PostEditChange();
	virtual void Prime();
	virtual void TouchTexture( INT X, INT Y, FLOAT Z );
};

/*==========================================================================
	UFireTexture — animated fire effect texture.
==========================================================================*/

class FIRE_API UFireTexture : public UFractalTexture
{
	DECLARE_CLASS(UFireTexture,UFractalTexture,0,Fire)

	// UTexture interface.
	virtual void Clear( DWORD Flags );
	virtual void Init( INT InUSize, INT InVSize );
	virtual void ConstantTimeTick();
	virtual void Click( DWORD Flags, FLOAT X, FLOAT Y );
	virtual void MousePosition( DWORD Flags, FLOAT X, FLOAT Y );
	virtual void TouchTexture( INT X, INT Y, FLOAT Z );

	// UObject interface.
	virtual void PostLoad();
	virtual void Serialize( FArchive& Ar );

private:
	void AddSpark( INT X, INT Y );
	void CloseSpark( INT X, INT Y );
	void DeleteSparks( INT X, INT Y, INT Z );
	void DrawFlashRamp( LineSeg Seg, BYTE A, BYTE B );
	void DrawSparkLine( INT X1, INT Y1, INT X2, INT Y2, INT H );
	void FirePaint( INT X, INT Y, DWORD C );
	void MoveSpark( FSpark* S );
	void MoveSparkAngle( FSpark* S, BYTE Angle );
	void MoveSparkTwo( FSpark* S );
	void MoveSparkXY( FSpark* S, signed char DX, signed char DY );
	void PostDrawSparks();
	void RedrawSparks();
	void TempDrawSpark( INT X, INT Y, INT H );
};

/*==========================================================================
	UWaterTexture — animated water ripple effect texture.
==========================================================================*/

class FIRE_API UWaterTexture : public UFractalTexture
{
	DECLARE_CLASS(UWaterTexture,UFractalTexture,0,Fire)

	// UTexture interface.
	virtual void Clear( DWORD Flags );
	virtual void Init( INT InUSize, INT InVSize );
	virtual void Click( DWORD Flags, FLOAT X, FLOAT Y );
	virtual void MousePosition( DWORD Flags, FLOAT X, FLOAT Y );
	virtual void TouchTexture( INT X, INT Y, FLOAT Z );

	// UObject interface.
	virtual void PostLoad();
	virtual void Destroy();

	// Public methods.
	void CalculateWater();
	void WaterRedrawDrops();

private:
	void AddDrop( INT X, INT Y );
	void DeleteDrops( INT X, INT Y, INT Z );
	void WaterPaint( INT X, INT Y, DWORD C );
};

/*==========================================================================
	UWaveTexture — animated wave effect texture.
==========================================================================*/

class FIRE_API UWaveTexture : public UWaterTexture
{
	DECLARE_CLASS(UWaveTexture,UWaterTexture,0,Fire)

	// UTexture interface.
	virtual void Clear( DWORD Flags );
	virtual void Init( INT InUSize, INT InVSize );
	virtual void ConstantTimeTick();

	// UObject interface.
	virtual void PostLoad();

	// Public methods.
	void SetWaveLight();
};

/*==========================================================================
	UFluidTexture — fluid simulation texture.
==========================================================================*/

class FIRE_API UFluidTexture : public UWaterTexture
{
	DECLARE_CLASS(UFluidTexture,UWaterTexture,0,Fire)

	// UTexture interface.
	virtual void Clear( DWORD Flags );
	virtual void Init( INT InUSize, INT InVSize );
	virtual void ConstantTimeTick();

	// UObject interface.
	virtual void PostLoad();

	// Public methods.
	void CalculateFluid();
};

/*==========================================================================
	UIceTexture — animated ice/glass effect texture.
==========================================================================*/

class FIRE_API UIceTexture : public UFractalTexture
{
	DECLARE_CLASS(UIceTexture,UFractalTexture,0,Fire)

	// UTexture interface.
	virtual void Clear( DWORD Flags );
	virtual void Init( INT InUSize, INT InVSize );
	virtual void ConstantTimeTick();
	virtual void Tick( FLOAT DeltaTime );
	virtual void Click( DWORD Flags, FLOAT X, FLOAT Y );
	virtual void MousePosition( DWORD Flags, FLOAT X, FLOAT Y );

	// UObject interface.
	virtual void PostLoad();
	virtual void Destroy();

private:
	void MoveIcePosition( FLOAT Delta );
	void RenderIce( FLOAT Delta );
	void BlitIceTex();
	void BlitTexIce();
};

/*==========================================================================
	UWetTexture — animated wet surface effect texture.
==========================================================================*/

class FIRE_API UWetTexture : public UFractalTexture
{
	DECLARE_CLASS(UWetTexture,UFractalTexture,0,Fire)

	// UTexture interface.
	virtual void Clear( DWORD Flags );
	virtual void Init( INT InUSize, INT InVSize );
	virtual void ConstantTimeTick();

	// UObject interface.
	virtual void PostLoad();
	virtual void Destroy();

private:
	void ApplyWetTexture();
	void SetRefractionTable();
};

#if _MSC_VER
#pragma pack (pop)
#endif
