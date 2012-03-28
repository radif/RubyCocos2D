//
//  main.m
//  TestShinyCocos
//
//  Created by Rolando Abarca on 4/21/09.
//  Copyright Games For Food SpA 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShinyCocos.h"

int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"RubyCocos2DAppDelegate");
    [pool release];
    return retVal;
}
