class WaterVolume extends PhysicsVolume;


//#exec AUDIO IMPORT FILE="..\botpack\Sounds\Generic\dsplash.WAV" NAME="DSplash" GROUP="Generic"
//#exec AUDIO IMPORT FILE="..\botpack\Sounds\Generic\wtrexit1.WAV" NAME="WtrExit1" GROUP="Generic"

//#exec AUDIO IMPORT FILE="..\botpack\Sounds\Generic\uWater1a.WAV" NAME="InWater" GROUP="Generic"
//	AmbientSound=InWater

//    ViewFog=(X=0.1289,Y=0.1953,Z=0.17578)
//    ViewFlash=(X=-0.078,Y=-0.078,Z=-0.078)

defaultproperties
{
     bWaterVolume=True
     bDistanceFog=True
     FluidFriction=2.400000
     DistanceFogStart=8.000000
     DistanceFogEnd=2000.000000
     DistanceFogColor=(B=128,G=64,R=32,A=64)
     LocationName="under water"
}
