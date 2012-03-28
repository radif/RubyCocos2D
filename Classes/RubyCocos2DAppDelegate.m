//
//  TestShinyCocosAppDelegate.m
//  TestShinyCocos
//
//  Created by Rolando Abarca on 4/21/09.
//  Copyright Games For Food SpA 2009. All rights reserved.
//

#import "RubyCocos2DAppDelegate.h"
#import "ShinyCocos.h"
#import "cocos2d.h"
#import "GlobalFunctions.h"

// dummy function for future references
void sc_require(char *fname) {
}

@implementation RubyCocos2DAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:TRUE];

    
    //copy over the stuff to docs
	NSString *rubyVendor =  cdaPath(@"$(DOCUMENTS)/vendor");
    NSString *rubyLibs =  cdaPath(@"$(DOCUMENTS)/lib");

    //copy vendor for the first time
    if (![[NSFileManager defaultManager] fileExistsAtPath:rubyVendor]) 
        [[NSFileManager defaultManager] copyItemAtPath:cdaPath(@"$(BUNDLE)/vendor") toPath:rubyVendor error:nil];

    
    //copy libs for the first time
    if (![[NSFileManager defaultManager] fileExistsAtPath:rubyLibs]) 
        [[NSFileManager defaultManager] copyItemAtPath:cdaPath(@"$(BUNDLE)/lib") toPath:rubyLibs error:nil];
    
    
    ShinyCocosSetup(nil);
	ShinyCocosInitChipmunk();    
	ShinyCocosStart(window, self);
    
    return TRUE;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}



- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {

}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[Director sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[Director sharedDirector] startAnimation];
}

-(void) applicationWillTerminate: (UIApplication*) application {
	ShinyCocosStop();
	[[Director sharedDirector] release];
}

- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
