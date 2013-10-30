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
@property (nonatomic, strong) StrumPattern *strumPattern;
@property (nonatomic) int barNumber;

-(id) initWithProgression:(Progression *)progression strumPattern:(StrumPattern *)strumPattern;

@end
