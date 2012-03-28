//
//  AnimationAudioEngine.h
//  AnotherMonster
//
//  Created by Radif Sharafullin on 6/26/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@class AnimationAudioEngine;
@protocol AnimationAudioEngineDelegate <NSObject>
@optional
- (void)audioPlayerDidFinishPlaying:(AnimationAudioEngine *)audioEngine forFile:(NSString *)audioFile successfully:(BOOL)flag;
- (void)audioPlayerDecodeErrorDidOccur:(AnimationAudioEngine *)audioEngine forFile:(NSString *)audioFile error:(NSError *)error;
- (void)audioPlayerBeginInterruption:(AnimationAudioEngine *)audioEngine forFile:(NSString *)audioFile;
- (void)audioPlayerEndInterruption:(AnimationAudioEngine *)audioEngine forFile:(NSString *)audioFile withFlags:(NSUInteger)flags;
@end

@interface AnimationAudioEngine : NSObject <AVAudioPlayerDelegate> {
   @private
    NSMutableArray *soundFiles;
    BOOL enginePaused;
}
@property (nonatomic, assign) id <AnimationAudioEngineDelegate> delegate;

+(AnimationAudioEngine *)sharedAnimationAudioEngine;

-(void)loadAudioFile:(NSString *)audioFile;
-(void)loadAudioFile:(NSString *)audioFile volume:(float)volume;
-(NSArray *)loadedAudioFiles;
-(void)unloadAudioFile:(NSString *)audioFile;
-(void)unloadAllAudioFiles;
-(void)unloadAllAudioFilesExcept:(NSArray *)exceptions;
-(void)unloadAudioFilesForEmitterID:(NSString *)emitterID;

/*!
 @plying if loaded or loading and playing if not loaded
 */
-(void)playAudioFile:(NSString *)audioFile;
-(void)playAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops;
-(void)stopAndPlayAudioFile:(NSString *)audioFile;
-(void)stopAndPlayAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops;

/*!
 @emitter specific sounds (sounds belonging to the same emitter id never overlap)
 */
-(void)playAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops forEmitterID:(NSString *)emitterID;
/*!
 @This will inload the file as soon as it stops
 */
-(void)playOneShot:(NSString *)audioFile;
-(void)playOneShot:(NSString *)audioFile volume:(float)volume;
-(void)playOneShot:(NSString *)audioFile volume:(float)volume forEmitterID:(NSString *)emitterID;
-(void)playAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops forEmitterID:(NSString *)emitterID autoUnloads:(BOOL)autoUnloads;
/*!
 @This will force playing the sound even if the engine is paused. This feature is not recommended to use, unless you know what you are doing.
 */
-(void)playAudioFileInPausedMode:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops forEmitterID:(NSString *)emitterID;
/*!
 @global pause/stop
 */
-(void)pauseAudioEngine;
-(void)resumeAudioEngine;

-(void)stopCurrentlyPlayingSounds;
-(void)stopCurrentlyPlayingSoundsForEmitterID:(NSString *)emitterID;

-(BOOL)isAudioFilePlaying:(NSString *)audioFile;


/*!
 @stopping if found, not loading if not found
 */
-(void)stopAudioFile:(NSString *)audioFile;

/*!
 @pausing if found, not loading if not found
 */
-(void)pauseAudioFile:(NSString *)audioFile;

-(void)pauseAudioFilesForEmitterID:(NSString *)emitterID;//you can access the data about whether the file is paused or not from audioPlayerForAudioFile and check whether the player is paused. To resume call playAudioFile

-(void)pauseCurrentlyPlayingAudioFiles;//you can access the data about whether the file is paused or not from audioPlayerForAudioFile and check whether the player is paused. To resume call playAudioFile

/*!
 @returning nil if not found
 */
-(AVAudioPlayer *)audioPlayerForAudioFile:(NSString *)audioFile;

//TODO: loop support
@end
