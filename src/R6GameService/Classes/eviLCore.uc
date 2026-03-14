//=============================================================================
//  eviLPatchService.uc : This class provides a script front-end to the 
//  patch service client facilities.
//
//============================================================================//

class eviLCore extends Object
	native;

native(3101) final static function string		EncryptCDKey(string clearCDKey);
native(3103) final static function string 		DecryptCDKey(string encryptedCDKey);
native(3108) final static function bool			IsCDKeyValidOnMachine(string encryptedCDKey);

defaultproperties
{
}
