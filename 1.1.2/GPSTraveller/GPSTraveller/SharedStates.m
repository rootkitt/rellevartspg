//
//  SharedStates.m
//  GPSTraveller
//
//  Created by Wen Shane on 13-7-5.
//  Copyright (c) 2013年 Wen Shane. All rights reserved.
//

#import "SharedStates.h"
#import "MobClick.h"
#import "ATMHud.h"
#import "ATMSoundFX.h"

#define DEFAULTS_UUID   @"UUID"

static SharedStates* singleton = nil;

@interface SharedStates()
{
    ATMSoundFX* mStartSound;
}
@property (nonatomic, retain) ATMSoundFX* mStartSound;
@end

@implementation SharedStates
@synthesize mStartSound;

+(SharedStates*)getInstance
{
    @synchronized([SharedStates class]){
        if(singleton ==nil){
            singleton = [[self alloc]init];
        }
    }
    return singleton;
}

- (void) dealloc
{
    self.mStartSound = nil;
    
    [super dealloc];
}

- (NSString*) getUUID
{
    NSString* sUUID = nil;
    NSUserDefaults* sDefaults = [NSUserDefaults standardUserDefaults];
    sUUID = [sDefaults objectForKey:DEFAULTS_UUID];
    
    if (!sUUID)
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString* sUUIDStr = (NSString *)CFUUIDCreateString (kCFAllocatorDefault,uuidRef);
        sUUID = [[sUUIDStr copy] autorelease];
        
        CFRelease(uuidRef);
        CFRelease(sUUIDStr);
        [sDefaults setValue:sUUID forKey:DEFAULTS_UUID];
    }
    
    return sUUID;
}

- (NSString*) getAcuringPointsInstruction
{
    NSString* sAcuringPointsInstruction = [MobClick getConfigParams:@"UPID_ACQUIRE_POINITS_INSTRUCTION"];
    if (!sAcuringPointsInstruction
        || sAcuringPointsInstruction.length <= 0)
    {
        sAcuringPointsInstruction = NSLocalizedString(@"Points Instruction", nil);
    }
    return sAcuringPointsInstruction;
    
}

- (void) showNotice:(NSString*)aNotice
{
    ATMHud* sHudForSaveSuccess = [[[ATMHud alloc] initWithDelegate:self] autorelease];
    [sHudForSaveSuccess setAlpha:0.6];
    [sHudForSaveSuccess setDisappearScaleFactor:1];
    [sHudForSaveSuccess setShadowEnabled:YES];
    [[[UIApplication sharedApplication] keyWindow] addSubview:sHudForSaveSuccess.view];
    
    [sHudForSaveSuccess setCaption:aNotice];
    [sHudForSaveSuccess show];
    [sHudForSaveSuccess hideAfter:1.2];
}

- (void) playSoundForStart
{
    if (!self.mStartSound)
    {
        NSString* sSoundFilePath = [[NSBundle mainBundle] pathForResource: @"start" ofType: @"wav"];
        self.mStartSound = [[[ATMSoundFX alloc] initWithContentsOfFile:sSoundFilePath] autorelease];
    }
    [self.mStartSound play];
}

@end
