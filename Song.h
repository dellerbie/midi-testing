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

- (Bar *)appendBar;
- (Bar *)addBarAtBarNumber:(int)barNumber;
- (void)removeBar:(Bar *)bar;
- (void)addProgession:(Progression *)progression withStrumPattern:(int)strumPatternNumber toTrack:(MusicTrack) track atBar:(Bar *)bar;

@end
