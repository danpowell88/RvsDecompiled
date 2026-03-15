//=============================================================================
// R6DescriptionManager - extracted from retail RavenShield 1.60
// Original decompile by Eliot.UELib (UE-Explorer 1.6.1)
// Comments from Ubisoft SDK 1.56 where applicable
//=============================================================================
// From SDK 1.56 - verify still applicable
//=============================================================================
//  R6DescriptionManager.uc : Class providing manipulation tools
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/10 * Created by Alexandre Dionne
//=============================================================================
class R6DescriptionManager extends Object;

static final function Class<R6Description> findPrimaryDefaultAmmo(Class<R6PrimaryWeaponDescription> WeaponDescriptionClass)
{
	local int i;
	local bool Found;

	Found = false;
	i = 0;
	J0x0F:

	// End:0x77 [Loop If]
	if(((i < WeaponDescriptionClass.default.m_Bullets.Length) && (Found == false)))
	{
		// End:0x6D
		if((Class<R6BulletDescription>(WeaponDescriptionClass.default.m_Bullets[i]).default.m_NameTag == "FMJ"))
		{
			Found = true;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0x0F;
	}
	// End:0x9A
	if(Found)
	{
		return Class<R6Description>(WeaponDescriptionClass.default.m_Bullets[i]);
	}
	i = 0;
	J0xA1:

	// End:0x10A [Loop If]
	if(((i < WeaponDescriptionClass.default.m_Bullets.Length) && (Found == false)))
	{
		// End:0x100
		if((Class<R6BulletDescription>(WeaponDescriptionClass.default.m_Bullets[i]).default.m_NameTag == "BUCK"))
		{
			Found = true;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0xA1;
	}
	// End:0x12D
	if(Found)
	{
		return Class<R6Description>(WeaponDescriptionClass.default.m_Bullets[i]);
	}
	return Class<R6Description>(WeaponDescriptionClass.default.m_Bullets[0]);
	return;
}

static final function Class<R6Description> findSecondaryDefaultAmmo(Class<R6SecondaryWeaponDescription> WeaponDescriptionClass)
{
	local int i;
	local bool Found;

	Found = false;
	i = 0;
	J0x0F:

	// End:0x77 [Loop If]
	if(((i < WeaponDescriptionClass.default.m_Bullets.Length) && (Found == false)))
	{
		// End:0x6D
		if((Class<R6BulletDescription>(WeaponDescriptionClass.default.m_Bullets[i]).default.m_NameTag == "FMJ"))
		{
			Found = true;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0x0F;
	}
	// End:0x9A
	if(Found)
	{
		return Class<R6Description>(WeaponDescriptionClass.default.m_Bullets[i]);
	}
	return Class<R6Description>(WeaponDescriptionClass.default.m_Bullets[0]);
	return;
}

static final function Class<R6BulletDescription> GetPrimaryBulletDesc(Class<R6PrimaryWeaponDescription> WeaponDescription, string token)
{
	local int i;
	local bool Found;
	local string caps_Token;

	caps_Token = Caps(token);
	J0x0D:

	// End:0x75 [Loop If]
	if(((i < WeaponDescription.default.m_Bullets.Length) && (Found == false)))
	{
		// End:0x6B
		if((Class<R6BulletDescription>(WeaponDescription.default.m_Bullets[i]).default.m_NameTag == caps_Token))
		{
			Found = true;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0x0D;
	}
	// End:0x9B
	if(Found)
	{
		return Class<R6BulletDescription>(WeaponDescription.default.m_Bullets[i]);		
	}
	else
	{
		return Class'R6Description.R6DescBulletNone';
	}
	return;
}

static final function Class<R6WeaponGadgetDescription> GetPrimaryWeaponGadgetDesc(Class<R6PrimaryWeaponDescription> WeaponDescription, string token)
{
	local int i;
	local bool Found;
	local string caps_Token;

	caps_Token = Caps(token);
	// End:0x23
	if((caps_Token == "NONE"))
	{
		return Class'R6Description.R6DescWeaponGadgetNone';
	}
	J0x23:

	// End:0xA7 [Loop If]
	if(((i < WeaponDescription.default.m_MyGadgets.Length) && (Found == false)))
	{
		// End:0x9D
		if(((WeaponDescription.default.m_MyGadgets[i] != none) && (Class<R6WeaponGadgetDescription>(WeaponDescription.default.m_MyGadgets[i]).default.m_NameID == caps_Token)))
		{
			Found = true;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0x23;
	}
	// End:0xCD
	if(Found)
	{
		return Class<R6WeaponGadgetDescription>(WeaponDescription.default.m_MyGadgets[i]);		
	}
	else
	{
		return Class'R6Description.R6DescWeaponGadgetNone';
	}
	return;
}

static final function Class<R6BulletDescription> GetSecondaryBulletDesc(Class<R6SecondaryWeaponDescription> WeaponDescription, string token)
{
	local int i;
	local bool Found;
	local string caps_Token;

	caps_Token = Caps(token);
	J0x0D:

	// End:0x75 [Loop If]
	if(((i < WeaponDescription.default.m_Bullets.Length) && (Found == false)))
	{
		// End:0x6B
		if((Class<R6BulletDescription>(WeaponDescription.default.m_Bullets[i]).default.m_NameTag == caps_Token))
		{
			Found = true;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0x0D;
	}
	// End:0x9B
	if(Found)
	{
		return Class<R6BulletDescription>(WeaponDescription.default.m_Bullets[i]);		
	}
	else
	{
		return Class'R6Description.R6DescBulletNone';
	}
	return;
}

static final function Class<R6WeaponGadgetDescription> GetSecondaryWeaponGadgetDesc(Class<R6SecondaryWeaponDescription> WeaponDescription, string token)
{
	local int i;
	local bool Found;
	local string caps_Token;

	caps_Token = Caps(token);
	// End:0x23
	if((caps_Token == "NONE"))
	{
		return Class'R6Description.R6DescWeaponGadgetNone';
	}
	J0x23:

	// End:0x8B [Loop If]
	if(((i < WeaponDescription.default.m_MyGadgets.Length) && (Found == false)))
	{
		// End:0x81
		if((Class<R6WeaponGadgetDescription>(WeaponDescription.default.m_MyGadgets[i]).default.m_NameID == caps_Token))
		{
			Found = true;			
		}
		else
		{
			(i++);
		}
		// [Loop Continue]
		goto J0x23;
	}
	// End:0xB1
	if(Found)
	{
		return Class<R6WeaponGadgetDescription>(WeaponDescription.default.m_MyGadgets[i]);		
	}
	else
	{
		return Class'R6Description.R6DescWeaponGadgetNone';
	}
	return;
}

