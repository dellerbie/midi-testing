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

@interface Song : NSObject

@property (nonatomic, strong) NSArray *bars;

- (void)addProgession:(Progression *) progression
     withStrumPattern:(int) strumPatternNumber
              toTrack:(MusicTrack) track
          atBarNumber:(int) barNumber;

@end
