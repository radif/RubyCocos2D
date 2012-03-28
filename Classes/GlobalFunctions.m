//
//  cdaGlobalFunctions.m
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

#import "GlobalFunctions.h"
#import <UIKit/UIDevice.h>
#include <mach/mach_time.h>
#import <UIKit/UIKit.h>

static NSString *_devSuffix=nil;
NSError * restoreVendorFiles(){
    NSError *err=nil;
    //copy over the stuff to docs
	NSString *rubyVendor =  cdaPath(@"$(DOCUMENTS)/vendor");
    NSString *rubyLibs =  cdaPath(@"$(DOCUMENTS)/lib");
    
    [[NSFileManager defaultManager] removeItemAtPath:rubyVendor error:&err];
    if (err) return err;
    [[NSFileManager defaultManager] removeItemAtPath:rubyLibs error:&err];
    if (err) return err;
    [[NSFileManager defaultManager] copyItemAtPath:cdaPath(@"$(BUNDLE)/vendor") toPath:rubyVendor error:&err];
    if (err) return err;
    [[NSFileManager defaultManager] copyItemAtPath:cdaPath(@"$(BUNDLE)/lib") toPath:rubyLibs error:&err];
    return err;

}
BOOL isiPhone(){
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}
BOOL isiPad(){
    return (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone);
}
NSString * deviceSuffix(){
    if(!_devSuffix) _devSuffix=[(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?  @"~iphone" : @"~ipad" retain];
    return _devSuffix;
}
NSString * cdaPathForLocalDirectory(NSString *inPath, NSString * localDirectory){
    inPath=[cdaGlobalFunctions cdaPath:inPath];
    if ([inPath rangeOfString:@"$(LOCAL).."].location!=NSNotFound) 
        inPath=[inPath stringByReplacingOccurrencesOfString:@"$(LOCAL).." withString:[localDirectory stringByDeletingLastPathComponent]];
    if ([inPath rangeOfString:@"$(LOCAL)"].location!=NSNotFound) 
        inPath=[inPath stringByReplacingOccurrencesOfString:@"$(LOCAL)" withString:localDirectory ];
    return  inPath;
}
NSString * cdaPath(NSString *inPath){
    //bundle
    if ([inPath rangeOfString:@"$(BUNDLE)"].location!=NSNotFound) 
        inPath=[inPath stringByReplacingOccurrencesOfString:@"$(BUNDLE)" withString:[[NSBundle mainBundle] resourcePath]];
	//documents
     if ([inPath rangeOfString:@"$(DOCUMENTS)"].location!=NSNotFound) 
         inPath=[inPath stringByReplacingOccurrencesOfString:@"$(DOCUMENTS)" withString:[cdaGlobalFunctions documentsPath] ];
	//cache
    if ([inPath rangeOfString:@"$(CACHES)"].location!=NSNotFound) 
        inPath=[inPath stringByReplacingOccurrencesOfString:@"$(CACHES)" withString:[cdaGlobalFunctions cachesPath]];
    //Library
    if ([inPath rangeOfString:@"$(LIBRARY)"].location!=NSNotFound) 
        inPath=[inPath stringByReplacingOccurrencesOfString:@"$(LIBRARY)" withString:[cdaGlobalFunctions libraryPath]];
	return inPath;
}
@implementation cdaGlobalFunctions
+(NSError *)restoreVendorFiles{
    return restoreVendorFiles();
}
+(BOOL)isiPhone{
    return isiPhone();
}
+(BOOL)isiPad{
    return isiPad();
}
+(NSString *)deviceSuffix{
    return deviceSuffix();
}

#pragma mark filesystem
// Gets the full bundle path of an item
+ (NSString *)getFullPath:(NSString *)inPath
{
	return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:inPath];
}
+(NSString *)documentsPath{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(NSString *)cachesPath{
	return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}
+(NSString *)libraryPath{
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+(NSString *)cdaPath:(NSString *)inPath{
    return cdaPath(inPath);
}

+(NSString *)cdaPath:(NSString *)inPath forLocaLDirectory:(NSString *) localDirectory{
    return cdaPathForLocalDirectory(inPath, localDirectory);
}

// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createDirectories:(BOOL)inCreateDirectories{
	NSString *tmpString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:inPath];
	NSString *directoryPath = [tmpString stringByDeletingLastPathComponent];
	if (inCreateDirectories && ![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
		[[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpString;
}


// Gets the document path of an item. If inCreateDirectories is YES, it will create intermediate
// directories that don't exist.
+ (NSString *)getDocumentPath:(NSString *)inPath createItIfDoesntExist:(BOOL)inCreateDirectories{
	NSString *tmpString = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:inPath];
	if (inCreateDirectories && ![[NSFileManager defaultManager] fileExistsAtPath:tmpString])
		[[NSFileManager defaultManager] createDirectoryAtPath:tmpString withIntermediateDirectories:YES attributes:nil error:nil];
	
	return tmpString;
}

+(NSString *)uniqueTimestampID{
	srandom(time(NULL));//ForID
	NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
	[dateFormatter setDateFormat:@"a-dd-yyyy-MM-hh-ss-mm"];
	NSString *dateString=[NSString stringWithFormat:@"%@",[dateFormatter stringFromDate:[NSDate date]]];
	[dateFormatter release];
	return 	[NSString stringWithFormat:@"%@-%llu-%i%i%i%i",dateString,mach_absolute_time(),random()%10000,random()%10000,random()%10000,random()%10000];
	
}

@end
