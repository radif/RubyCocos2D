//
//  cdaGlobalFunctions.h
//  mscocktailsipad
//
//  Created by Radif Sharafullin on 4/18/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

/*!
 *  Caveats:
 *
 *  This file is included into each framework. The changes you make will apply across all the frameworks and possibly revisions of these frameworks. Consider TWICE before changing anything here!
 *  
 *  This file is marked as a private file of each library to avoid name clashes.
 *
 */

#import <Foundation/Foundation.h>
#define cdaLogLevel 1


#ifdef DEBUG
#define CDA_LOG_SELECTOR_NAME NSLog(@"%@",NSStringFromSelector(_cmd))
#define CDA_LOG_METHOD_NAME NSLog(@"%s",__FUNCTION__)
#define cdaLog( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )

#if cdaLogLevel >= 1
#define cdaLogL1( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define cdaLogL1( s, ... )
#endif

#if cdaLogLevel >= 2
#define cdaLogL2( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define cdaLogL2( s, ... )
#endif


#if cdaLogLevel >= 3
#define cdaLogL3( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define cdaLogL3( s, ... )
#endif


#if cdaLogLevel >= 4
#define cdaLogL4( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define cdaLogL4( s, ... )
#endif


#if cdaLogLevel >= 5
#define cdaLogL5( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define cdaLogL5( s, ... )
#endif


#if cdaLogLevel >= 6
#define cdaLogL6( s, ... ) NSLog( @"<%s : (%d)> %@",__FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define cdaLogL6( s, ... )
#endif



#define cdaLogMem( s, ... ) NSLog( @"<%s : (%d)[%d]> %@",__FUNCTION__, __LINE__,[cdaGlobalFunctions getFreeMemory], [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else

#define cdaLog( s, ... )
#define cdaLogL1( s, ... )
#define cdaLogL2( s, ... )
#define cdaLogL3( s, ... )
#define cdaLogL4( s, ... )
#define cdaLogL5( s, ... )
#define cdaLogL6( s, ... )

#define cdaLogMem( s, ... )
#define NSLog( s, ... )
#define CDA_LOG_SELECTOR_NAME
#define CDA_LOG_METHOD_NAME
#endif




#define CDA_RELEASE_SAFELY(__PTR) { if(__PTR){  [__PTR release]; __PTR = nil;} }
#define CDA_AUTORELEASE_SAFELY(__PTR) { [__PTR autorelease]; __PTR = nil; }
#define CDA_INVALIDATE_TIMER(__TMR) { [__TMR invalidate]; __TMR = nil; }
#define CDA_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

#define CDA_UNREGISTER_NOTIFICATIONS(x) [[NSNotificationCenter defaultCenter] removeObserver:x];



BOOL isiPhone();
BOOL isiPad();
NSString * deviceSuffix();
NSString * cdaPath(NSString *inPath);
NSString * cdaPathForLocalDirectory(NSString *inPath, NSString * localDirectory);
@interface cdaGlobalFunctions : NSObject {
}
+(NSError *)restoreVendorFiles;
//filesystem
+(BOOL)isiPhone;
+(BOOL)isiPad;
+(NSString *)deviceSuffix;
+(NSString *)cdaPath:(NSString *)inPath;
+(NSString *)cdaPath:(NSString *)inPath forLocaLDirectory:(NSString *) localDirectory;
+(NSString *)documentsPath;
+(NSString *)cachesPath;
+(NSString *)libraryPath;
// Gets the full bundle path of an item
+ (NSString *)getFullPath:(NSString *)inPath;	

// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createDirectories:(BOOL)inCreateDirectories;	

// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createItIfDoesntExist:(BOOL)inCreateDirectories;	

+(NSString *)uniqueTimestampID;

@end
