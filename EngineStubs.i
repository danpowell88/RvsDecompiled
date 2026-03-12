




























#pragma optimize("", off)




#pragma warning(push)
#pragma warning(disable: 4291) 
inline void* operator new(size_t, void* p) noexcept { return p; }
inline void  operator delete(void*, void*) noexcept {}
#pragma warning(pop)
















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



	