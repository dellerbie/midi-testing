//
//  Song.h
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Progression.h"
#import "StrumPattern.h"
#import "Bar.h"

@interface Song : NSObject

@property (nonatomic) MusicTrack track;
@property (nonatomic) MusicSequence sequence;
@property (nonatomic, strong) NSString *key;

+ (MusicTimeStamp)beatNumberForBarNumber:(int)barNumber;

- (id)initWithSequence:(MusicSequence)sequence track:(MusicTrack)track;
- (id)initWithSequence:(MusicSequence)sequence track:(MusicTrack)track file:(NSString *)fileName;

- (Bar *)appendBar;
- (void)removeBar:(Bar *)bar;
- (void)moveBar:(Bar *)bar toBarNumber:(int)barNumber;
- (void)addProgession:(Progression *)progression withStrumPattern:(int)strumPatternNumber toBar:(Bar *)bar;

@end
