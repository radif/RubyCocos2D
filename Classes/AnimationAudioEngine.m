//
//  AnimationAudioEngine.m
//  AnotherMonster
//
//  Created by Radif Sharafullin on 6/26/11.
//  Copyright 2011 Callaway Digital Arts. All rights reserved.
//


#import "AnimationAudioEngine.h"

#define cdaSoundNotFound -1
#define kCDAAudioFileIterationExpression @"?iteration="
#define kCDAKeyForPlayer @"P"
#define kCDAKeyForAudioFile @"f"
#define kCDAKeyForEmitterID @"e"
#define kCDAKeyForPausedAudioFile @"ps"
#define kCDAKeyForAutoUnloads @"u"

static AnimationAudioEngine * sharedAnimationAudioEngine;
@interface AnimationAudioEngine (Private)
-(int)indexForAudioFile:(NSString *)audioFile;
-(int)indexForPlayer:(AVAudioPlayer *)aPlayer;
@end
@implementation AnimationAudioEngine
@synthesize delegate;

+(AnimationAudioEngine *)sharedAnimationAudioEngine{
    @synchronized(self) {
        if (!sharedAnimationAudioEngine) 
            sharedAnimationAudioEngine= [[self alloc] init];
    }
    return sharedAnimationAudioEngine;  
}

-(id)init{
    self=[super init];
    if (self) {
        soundFiles=[[NSMutableArray alloc] init];    
        self.delegate=nil;
        enginePaused=FALSE;
    }
    return self;
}
-(void)freeSharedAnimationAudioEngine{
    @synchronized(self) {
        [sharedAnimationAudioEngine release];
        sharedAnimationAudioEngine=nil;
    }
}
-(void)dealloc{
    [self unloadAllAudioFiles];
    [soundFiles release];
    [super dealloc];
}
-(void)loadAudioFile:(NSString *)audioFile{
    [self loadAudioFile:audioFile volume:1.0f];
}
-(void)loadAudioFile:(NSString *)audioFile volume:(float)volume{
    @synchronized(soundFiles) {
        int index=[self indexForAudioFile:audioFile];
        if (index==cdaSoundNotFound) {
            //file not found, loading
            NSError *error;
            NSString *audioFilePath=[[audioFile componentsSeparatedByString:kCDAAudioFileIterationExpression] objectAtIndex:0];
            if ([[NSFileManager defaultManager] fileExistsAtPath:audioFilePath]) {
                AVAudioPlayer *player=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:&error];
                if (player) {
                    [player prepareToPlay];
                    player.volume=volume;
                    NSMutableDictionary *audioAsset=[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:player, audioFile, nil]
                                                                                       forKeys:[NSArray arrayWithObjects:kCDAKeyForPlayer,kCDAKeyForAudioFile, nil]];
                    [soundFiles addObject:audioAsset]; 
                    player.delegate=self;
                    [player release];
                }
            }
        }
    }
}
-(NSArray *)loadedAudioFiles{
    NSMutableArray *retVal=[NSMutableArray array];
    for (NSDictionary * audioAsset in soundFiles) 
        [retVal addObject: [audioAsset objectForKey:kCDAKeyForAudioFile]];
    return retVal;
}
-(void)unloadAudioFile:(NSString *)audioFile{
    @synchronized(soundFiles) {
        int index=[self indexForAudioFile:audioFile];
        if (index!=cdaSoundNotFound) {
            //file found, unloading...
            AVAudioPlayer *player=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForPlayer];
            [player stop];
            player.delegate=nil;
            [soundFiles removeObjectAtIndex:index];
        }
    }
}
-(void)unloadAudioFilesForEmitterID:(NSString *)emitterID{
    if (!emitterID) return;
    NSMutableArray *toRemove=[NSMutableArray array];
    for (NSDictionary * audioAsset in soundFiles) {
        if([[audioAsset objectForKey:kCDAKeyForEmitterID] isEqualToString:emitterID]){
            AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
            if ([player isPlaying]){
                [player stop];
                player.delegate=nil; 
            }
            [toRemove addObject:audioAsset];
        }
    }
    [soundFiles removeObjectsInArray:toRemove];
    
}
-(void)unloadAllAudioFilesExcept:(NSArray *)exceptions{
    @synchronized(soundFiles) {
        NSMutableArray *toRemove=[NSMutableArray array];
        for (NSDictionary * audioAsset in soundFiles) {
            NSString *audioFile=[audioAsset objectForKey:kCDAKeyForAudioFile];
            
            BOOL found=FALSE;
            for (NSString *exception in exceptions) 
                if ([exception isEqualToString:audioFile]) {
                    found=TRUE;
                    break;
                }
            if (!found) {
                AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
                [player stop];
                player.delegate=nil; 
                [toRemove addObject:audioAsset];
            }
            
        }
        
        
        
        [soundFiles removeObjectsInArray:toRemove];
        
        
    }
}

-(void)unloadAllAudioFiles{
    @synchronized(soundFiles) {
        for (NSDictionary * audioAsset in soundFiles) {
            AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
            [player stop];
            player.delegate=nil;
            
        }
        [soundFiles removeAllObjects];  
    }
}
-(void)playAudioFile:(NSString *)audioFile{
    [self playAudioFile:audioFile volume:1.0f numberOfLoops:0];
}
-(void)stopAndPlayAudioFile:(NSString *)audioFile{
    [self stopAndPlayAudioFile:audioFile volume:1.0f numberOfLoops:0];
}
-(void)stopAndPlayAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops{
    if (enginePaused) return;
    //plying if loaded or loading and playing if not loaded
    int index=[self indexForAudioFile:audioFile];
    if (index!=cdaSoundNotFound) {
        AVAudioPlayer *player=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForPlayer];
        player.volume=volume;
        player.numberOfLoops=numberOfLoops;
        [player stop];
        [player setCurrentTime:0.0f];
        [player play];
        
    }else{
        [self loadAudioFile:audioFile volume:volume];
        [self playAudioFile:audioFile volume:volume numberOfLoops:numberOfLoops];
    }
}
-(void)playAudioFileInPausedMode:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops forEmitterID:(NSString *)emitterID{
    BOOL m_enginePaused=enginePaused;
    enginePaused=FALSE;
    [self playAudioFile:audioFile volume:volume numberOfLoops:numberOfLoops forEmitterID:emitterID];
    enginePaused=m_enginePaused;
}
-(void)playAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops{
    if (enginePaused) return;
    //playing if loaded or loading and playing if not loaded
    int index=[self indexForAudioFile:audioFile];
    if (index!=cdaSoundNotFound) {
        AVAudioPlayer *player=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForPlayer];
        player.volume=volume;
        player.numberOfLoops=numberOfLoops;
        [player play];
        
    }else{
        [self loadAudioFile:audioFile volume:volume];
        int index=[self indexForAudioFile:audioFile];
        if (index!=cdaSoundNotFound)
            [self playAudioFile:audioFile volume:volume numberOfLoops:numberOfLoops];
    }
}
-(void)stopAudioFile:(NSString *)audioFile{
    if (enginePaused) return;
    //stopping if found, not loading if not found
    int index=[self indexForAudioFile:audioFile];
    if (index!=cdaSoundNotFound) {
        AVAudioPlayer *player=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForPlayer];
        [player setCurrentTime:0.0f];
        [player stop];
        
    }
}
-(void)pauseAudioFile:(NSString *)audioFile{
    if (enginePaused) return;
    //pausing if loaded, ignoring if not loaded
    int index=[self indexForAudioFile:audioFile];
    if (index!=cdaSoundNotFound) {
        AVAudioPlayer *player=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForPlayer];
        [player pause];
        
    }
    
}

-(void)pauseAudioFilesForEmitterID:(NSString *)emitterID{
    if (enginePaused) return;
    if (!emitterID) return;
    for (NSDictionary * audioAsset in soundFiles) {
        if([[audioAsset objectForKey:kCDAKeyForEmitterID] isEqualToString:emitterID]){
            AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
            if ([player isPlaying]){
                [player pause];
            }
        }
    }
    
    

}

-(void)pauseCurrentlyPlayingAudioFiles{
    if (enginePaused) return;
    for (NSDictionary * audioAsset in soundFiles) {
        AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
        if ([player isPlaying]) {
            [player pause];
        };
    }
}


-(BOOL)isAudioFilePlaying:(NSString *)audioFile{
    AVAudioPlayer *player=[self audioPlayerForAudioFile:audioFile];
    if (!player) return FALSE;
    return player.isPlaying;
}
-(AVAudioPlayer *)audioPlayerForAudioFile:(NSString *)audioFile{
    int index=[self indexForAudioFile:audioFile];
    if (index!=cdaSoundNotFound) return [[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForPlayer];
    return nil;
}
#pragma mark auto unloading sounds
-(void)playOneShot:(NSString *)audioFile{
    [self playOneShot:audioFile volume:1.0f];
}
-(void)playOneShot:(NSString *)audioFile volume:(float)volume{
    [self playOneShot:audioFile volume:1.0f forEmitterID:nil];
}
-(void)playOneShot:(NSString *)audioFile volume:(float)volume forEmitterID:(NSString *)emitterID{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioFile]) {
        if (emitterID) 
            [self stopCurrentlyPlayingSoundsForEmitterID:emitterID];
        NSError *error=nil;
        AVAudioPlayer *player=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFile] error:&error];
        if (player) {
            [player prepareToPlay];
            player.volume=volume;
            NSMutableDictionary *audioAsset=[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:player, audioFile,[NSNumber numberWithBool:TRUE] , nil]
                                                                               forKeys:[NSArray arrayWithObjects:kCDAKeyForPlayer,kCDAKeyForAudioFile,kCDAKeyForAutoUnloads, nil]];
            
            if (emitterID) 
                [audioAsset setObject:emitterID forKey:kCDAKeyForEmitterID];
            
            [soundFiles addObject:audioAsset]; 
            player.delegate=self;
            [player release];
            [player play];
        }
    }
    
    
    
    
}
-(void)playAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops forEmitterID:(NSString *)emitterID autoUnloads:(BOOL)autoUnloads{
    [self playAudioFile:audioFile volume:volume numberOfLoops:numberOfLoops forEmitterID:emitterID];
    if (autoUnloads) {
        //find the sound file
        int index=[self indexForAudioFile:audioFile];
        if (index!=cdaSoundNotFound) 
            [[soundFiles objectAtIndex:index] setObject:[NSNumber numberWithBool:autoUnloads] forKey:kCDAKeyForAutoUnloads];
    }
    
}
#pragma mark emitter specific
-(void)playAudioFile:(NSString *)audioFile volume:(float)volume numberOfLoops:(int)numberOfLoops forEmitterID:(NSString *)emitterID{
    if (enginePaused) return;
    if (emitterID) 
        [self stopCurrentlyPlayingSoundsForEmitterID:emitterID];
    
    [self playAudioFile:audioFile volume:volume numberOfLoops:numberOfLoops];
    
    if (emitterID) {
        int index=[self indexForAudioFile:audioFile];
        if (index!=cdaSoundNotFound) 
            [[soundFiles objectAtIndex:index] setObject:emitterID forKey:kCDAKeyForEmitterID];
    }
    
}

-(void)pauseAudioEngine{
    if (enginePaused) return;
    enginePaused=TRUE;
    for (NSMutableDictionary * audioAsset in soundFiles) {
        if (![audioAsset objectForKey:kCDAKeyForPausedAudioFile]) {
            AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
            if ([player isPlaying]){
                [player pause];
                //saveState
                [audioAsset setObject:[NSNumber numberWithBool:TRUE] forKey:kCDAKeyForPausedAudioFile];            
            }
        }
    }
}

-(void)resumeAudioEngine{
    if (!enginePaused) return;
    enginePaused=FALSE;
    for (NSMutableDictionary * audioAsset in soundFiles) {
        if ([audioAsset objectForKey:kCDAKeyForPausedAudioFile]) {
            AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
            /*if ([player isPlaying])*/ [player play];
            //clearState
            [audioAsset removeObjectForKey:kCDAKeyForPausedAudioFile];            
        }
    }
}

-(void)stopCurrentlyPlayingSounds{
    for (NSDictionary * audioAsset in soundFiles) {
        AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
        if ([player isPlaying]) {
            [player stop];
            [player setCurrentTime:0.0f];
        };
    }
}
-(void)stopCurrentlyPlayingSoundsForEmitterID:(NSString *)emitterID{
    if (enginePaused) return;
    if (!emitterID) return;
    for (NSDictionary * audioAsset in soundFiles) {
        if([[audioAsset objectForKey:kCDAKeyForEmitterID] isEqualToString:emitterID]){
            AVAudioPlayer *player=[audioAsset objectForKey:kCDAKeyForPlayer];
            if ([player isPlaying]){
                [player stop];
                [player setCurrentTime:0.0f]; 
            }
        }
    }
}

#pragma mark private
-(int)indexForAudioFile:(NSString *)audioFile{
    int count =[soundFiles count];
    for (int i=0;i<count;++i) {
        NSString *aFile=[[soundFiles objectAtIndex:i] objectForKey:kCDAKeyForAudioFile];
        if ([aFile isEqualToString:audioFile]) 
            return i;
    }
    return cdaSoundNotFound;
}

-(int)indexForPlayer:(AVAudioPlayer *)aPlayer{
    int count =[soundFiles count];
    for (int i=0;i<count;++i) {
        AVAudioPlayer *player=[[soundFiles objectAtIndex:i] objectForKey:kCDAKeyForPlayer];
        if (player==aPlayer) 
            return i;
    }
    return cdaSoundNotFound;
}

#pragma mark player delegates

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    int index=[self indexForPlayer:player];
    NSString *audioFile=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForAudioFile];
    if ([self.delegate respondsToSelector:@selector(audioPlayerDidFinishPlaying:forFile:successfully:)]){
        [self.delegate audioPlayerDidFinishPlaying:self forFile:audioFile successfully:flag];
    }
    //if autoUnloads:
    if ([[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForAutoUnloads]) {
        [player setDelegate:nil];
        [self unloadAudioFile:audioFile];
    }
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    
    int index=[self indexForPlayer:player];
    NSString *audioFile=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForAudioFile];
    if ([self.delegate respondsToSelector:@selector(audioPlayerDecodeErrorDidOccur:forFile:error:)])
        [self.delegate audioPlayerDecodeErrorDidOccur:self forFile:audioFile error:error];
    
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player{
    int index=[self indexForPlayer:player];
    NSString *audioFile=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForAudioFile];
    if ([self.delegate respondsToSelector:@selector(audioPlayerBeginInterruption:forFile:)]) 
        [self.delegate audioPlayerBeginInterruption:self forFile:audioFile];
    
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags{
    int index=[self indexForPlayer:player];
    NSString *audioFile=[[soundFiles objectAtIndex:index] objectForKey:kCDAKeyForAudioFile];
    
    if ([self.delegate respondsToSelector:@selector(audioPlayerEndInterruption:forFile:withFlags:)]) 
        [self.delegate audioPlayerEndInterruption:self forFile:audioFile withFlags:flags];
    
}


@end
