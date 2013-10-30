//
//  Bar.h
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Progression.h"
#import "StrumPattern.h"

@interface Bar : NSObject

@property (nonatomic, strong) Progression *progression;
@property (nonatomic) int strumPatternNumber;

-(id) initWithProgression:(Progression *)progression strumPatternNumber:(int)strumPatternNumber;

@end
