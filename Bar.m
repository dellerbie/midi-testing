//
//  Bar.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "Bar.h"

@implementation Bar

@synthesize progression = _progression;
@synthesize strumPatternNumber = _strumPatternNumber;

- (id)initWithProgression:(Progression *)progression strumPatternNumber:(int)strumPatternNumber
{
  self = [super init];
  if(self)
  {
    [self setProgression:progression];
    [self setStrumPatternNumber:strumPatternNumber];
  }
  return self;
}

- (NSString *)description
{
  NSString *desc = [NSString stringWithFormat:@"Progression: %@, StrumPattern #%i", self.progression, self.strumPatternNumber];
  return desc;
}

@end
