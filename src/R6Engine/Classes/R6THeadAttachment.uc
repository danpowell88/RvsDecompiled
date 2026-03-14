//=============================================================================
// R6THeadAttachment - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6THeadAttachment.uc : Terrorist head attachment base class
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Guillaume Borgia
//=============================================================================
class R6THeadAttachment extends StaticMeshActor;

function bool SetAttachmentStaticMesh(R6Pawn.EHeadAttachmentType eAttType, R6Pawn.ETerroristType eTerro)
{
	local int iNbChoice;
	local string aMesh[10];
	local StaticMesh sm;

	switch(eTerro)
	{
		// End:0x0C
		case 0:
		// End:0x140
		case 1:
			switch(eAttType)
			{
				// End:0xB9
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM06B1T1Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM09B1T1Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM10B1T1Glasses";
					iNbChoice = 3;
					// End:0x13D
					break;
				// End:0x12B
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM06B1T1SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM09B1T1SGlasses";
					iNbChoice = 2;
					// End:0x13D
					break;
				// End:0x13A
				case 2:
					iNbChoice = 0;
					// End:0x13D
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0x145
		case 2:
		// End:0x2AA
		case 3:
			switch(eAttType)
			{
				// End:0x223
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM01B2T2Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM06B2T2Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM09B2T2Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM10B2T2Glasses";
					iNbChoice = 4;
					// End:0x2A7
					break;
				// End:0x295
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM06B2T2SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM09B2T2SGlasses";
					iNbChoice = 2;
					// End:0x2A7
					break;
				// End:0x2A4
				case 2:
					iNbChoice = 0;
					// End:0x2A7
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0x689
		case 4:
			switch(eAttType)
			{
				// End:0x4AE
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM01M1T1Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM02M1T1Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM03M1T1Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM05M1T1Glasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM07M1T1Glasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM08M1T1Glasses";
					aMesh[6] = "R6THeadAttachment_SM.R6TM09M1T1Glasses";
					aMesh[7] = "R6THeadAttachment_SM.R6TM11M1T1Glasses";
					aMesh[8] = "R6THeadAttachment_SM.R6TM13M1T1Glasses";
					aMesh[9] = "R6THeadAttachment_SM.R6TM14M1T1Glasses";
					iNbChoice = 10;
					// End:0x686
					break;
				// End:0x5E8
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM05M1T1SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM08M1T1SGlasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM09M1T1SGlasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM13M1T1SGlasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM14M1T1SGlasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM15M1T1SGlasses";
					iNbChoice = 6;
					// End:0x686
					break;
				// End:0x683
				case 2:
					aMesh[0] = "R6THeadAttachment_SM.R6TM11M1T1GMask";
					aMesh[1] = "R6THeadAttachment_SM.R6TM13M1T1GMask";
					aMesh[2] = "R6THeadAttachment_SM.R6TM15M1T1GMask";
					iNbChoice = 3;
					// End:0x686
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0xA68
		case 5:
			switch(eAttType)
			{
				// End:0x88D
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM01M1T3Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM02M1T3Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM03M1T3Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM05M1T3Glasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM07M1T3Glasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM08M1T3Glasses";
					aMesh[6] = "R6THeadAttachment_SM.R6TM09M1T3Glasses";
					aMesh[7] = "R6THeadAttachment_SM.R6TM11M1T3Glasses";
					aMesh[8] = "R6THeadAttachment_SM.R6TM13M1T3Glasses";
					aMesh[9] = "R6THeadAttachment_SM.R6TM14M1T3Glasses";
					iNbChoice = 10;
					// End:0xA65
					break;
				// End:0x9C7
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM05M1T3SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM08M1T3SGlasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM09M1T3SGlasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM13M1T3SGlasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM14M1T3SGlasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM15M1T3SGlasses";
					iNbChoice = 6;
					// End:0xA65
					break;
				// End:0xA62
				case 2:
					aMesh[0] = "R6THeadAttachment_SM.R6TM11M1T3GMask";
					aMesh[1] = "R6THeadAttachment_SM.R6TM13M1T3GMask";
					aMesh[2] = "R6THeadAttachment_SM.R6TM15M1T3GMask";
					iNbChoice = 3;
					// End:0xA65
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0xE47
		case 6:
			switch(eAttType)
			{
				// End:0xC6C
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM01M2T2Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM02M2T2Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM03M2T2Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM05M2T2Glasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM07M2T2Glasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM08M2T2Glasses";
					aMesh[6] = "R6THeadAttachment_SM.R6TM09M2T2Glasses";
					aMesh[7] = "R6THeadAttachment_SM.R6TM11M2T2Glasses";
					aMesh[8] = "R6THeadAttachment_SM.R6TM13M2T2Glasses";
					aMesh[9] = "R6THeadAttachment_SM.R6TM14M2T2Glasses";
					iNbChoice = 10;
					// End:0xE44
					break;
				// End:0xDA6
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM05M2T2SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM08M2T2SGlasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM09M2T2SGlasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM13M2T2SGlasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM14M2T2SGlasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM15M2T2SGlasses";
					iNbChoice = 6;
					// End:0xE44
					break;
				// End:0xE41
				case 2:
					aMesh[0] = "R6THeadAttachment_SM.R6TM11M2T2GMask";
					aMesh[1] = "R6THeadAttachment_SM.R6TM13M2T2GMask";
					aMesh[2] = "R6THeadAttachment_SM.R6TM15M2T2GMask";
					iNbChoice = 3;
					// End:0xE44
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0x1226
		case 7:
			switch(eAttType)
			{
				// End:0x104B
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM01M2T4Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM02M2T4Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM03M2T4Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM05M2T4Glasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM07M2T4Glasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM08M2T4Glasses";
					aMesh[6] = "R6THeadAttachment_SM.R6TM09M2T4Glasses";
					aMesh[7] = "R6THeadAttachment_SM.R6TM11M2T4Glasses";
					aMesh[8] = "R6THeadAttachment_SM.R6TM13M2T4Glasses";
					aMesh[9] = "R6THeadAttachment_SM.R6TM14M2T4Glasses";
					iNbChoice = 10;
					// End:0x1223
					break;
				// End:0x1185
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM05M2T4SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM08M2T4SGlasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM09M2T4SGlasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM13M2T4SGlasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM14M2T4SGlasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM15M2T4SGlasses";
					iNbChoice = 6;
					// End:0x1223
					break;
				// End:0x1220
				case 2:
					aMesh[0] = "R6THeadAttachment_SM.R6TM11M2T4GMask";
					aMesh[1] = "R6THeadAttachment_SM.R6TM13M2T4GMask";
					aMesh[2] = "R6THeadAttachment_SM.R6TM15M2T4GMask";
					iNbChoice = 3;
					// End:0x1223
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0x122B
		case 8:
		// End:0x1230
		case 11:
		// End:0x1235
		case 14:
		// End:0x15B0
		case 17:
			switch(eAttType)
			{
				// End:0x1439
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM02P1T1Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM03P1T1Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM04P1T1Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM06P1T1Glasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM07P1T1Glasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM08P1T1Glasses";
					aMesh[6] = "R6THeadAttachment_SM.R6TM10P1T1Glasses";
					aMesh[7] = "R6THeadAttachment_SM.R6TM11P1T1Glasses";
					aMesh[8] = "R6THeadAttachment_SM.R6TM13P1T1Glasses";
					aMesh[9] = "R6THeadAttachment_SM.R6TM15P1T1Glasses";
					iNbChoice = 10;
					// End:0x15AD
					break;
				// End:0x150F
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM06P1T1SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM08P1T1SGlasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM13P1T1SGlasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM15P1T1SGlasses";
					iNbChoice = 4;
					// End:0x15AD
					break;
				// End:0x15AA
				case 2:
					aMesh[0] = "R6THeadAttachment_SM.R6TM11P1T1GMask";
					aMesh[1] = "R6THeadAttachment_SM.R6TM13P1T1GMask";
					aMesh[2] = "R6THeadAttachment_SM.R6TM15P1T1GMask";
					iNbChoice = 3;
					// End:0x15AD
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0x15B5
		case 9:
		// End:0x15BA
		case 12:
		// End:0x15BF
		case 15:
		// End:0x193A
		case 18:
			switch(eAttType)
			{
				// End:0x17C3
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM02P2T2Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM03P2T2Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM04P2T2Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM06P2T2Glasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM07P2T2Glasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM08P2T2Glasses";
					aMesh[6] = "R6THeadAttachment_SM.R6TM10P2T2Glasses";
					aMesh[7] = "R6THeadAttachment_SM.R6TM11P2T2Glasses";
					aMesh[8] = "R6THeadAttachment_SM.R6TM13P2T2Glasses";
					aMesh[9] = "R6THeadAttachment_SM.R6TM15P2T2Glasses";
					iNbChoice = 10;
					// End:0x1937
					break;
				// End:0x1899
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM06P2T2SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM08P2T2SGlasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM13P2T2SGlasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM15P2T2SGlasses";
					iNbChoice = 4;
					// End:0x1937
					break;
				// End:0x1934
				case 2:
					aMesh[0] = "R6THeadAttachment_SM.R6TM11P2T2GMask";
					aMesh[1] = "R6THeadAttachment_SM.R6TM13P2T2GMask";
					aMesh[2] = "R6THeadAttachment_SM.R6TM15P2T2GMask";
					iNbChoice = 3;
					// End:0x1937
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0x193F
		case 10:
		// End:0x1944
		case 13:
		// End:0x1949
		case 16:
		// End:0x1C93
		case 19:
			switch(eAttType)
			{
				// End:0x1B1C
				case 0:
					aMesh[0] = "R6THeadAttachment_SM.R6TM02P3T3Glasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM03P3T3Glasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM04P3T3Glasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM06P3T3Glasses";
					aMesh[4] = "R6THeadAttachment_SM.R6TM07P3T3Glasses";
					aMesh[5] = "R6THeadAttachment_SM.R6TM08P3T3Glasses";
					aMesh[6] = "R6THeadAttachment_SM.R6TM10P3T3Glasses";
					aMesh[7] = "R6THeadAttachment_SM.R6TM13P3T3Glasses";
					aMesh[8] = "R6THeadAttachment_SM.R6TM15P3T3Glasses";
					iNbChoice = 9;
					// End:0x1C90
					break;
				// End:0x1BF2
				case 1:
					aMesh[0] = "R6THeadAttachment_SM.R6TM06P3T3SGlasses";
					aMesh[1] = "R6THeadAttachment_SM.R6TM08P3T3SGlasses";
					aMesh[2] = "R6THeadAttachment_SM.R6TM13P3T3SGlasses";
					aMesh[3] = "R6THeadAttachment_SM.R6TM15P3T3SGlasses";
					iNbChoice = 4;
					// End:0x1C90
					break;
				// End:0x1C8D
				case 2:
					aMesh[0] = "R6THeadAttachment_SM.R6TM11P3T3GMask";
					aMesh[1] = "R6THeadAttachment_SM.R6TM13P3T3GMask";
					aMesh[2] = "R6THeadAttachment_SM.R6TM15P3T3GMask";
					iNbChoice = 3;
					// End:0x1C90
					break;
				// End:0xFFFF
				default:
					break;
			}
			// End:0x1C96
			break;
		// End:0xFFFF
		default:
			break;
	}
	// End:0x1CD4
	if(__NFUN_151__(iNbChoice, 0))
	{
		sm = StaticMesh(DynamicLoadObject(aMesh[__NFUN_167__(iNbChoice)], Class'Engine.StaticMesh'));
		SetStaticMesh(sm);
		return true;		
	}
	else
	{
		return false;
	}
	return;
}

defaultproperties
{
	SkinsIndex=0
	RemoteRole=2
	bStatic=false
	bWorldGeometry=false
	bShadowCast=false
	bCollideActors=false
	bBlockActors=false
	bBlockPlayers=false
	bEdShouldSnap=false
	DrawScale3D=(X=-1.0000000,Y=-1.0000000,Z=1.0000000)
}
