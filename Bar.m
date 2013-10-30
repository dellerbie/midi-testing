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
@synthesize strumPattern = _strumPattern;

-(id) initWithProgression:(Progression *)progression strumPattern:(StrumPattern *)strumPattern
{
  self = [super init];
  if(self)
  {
    [self setProgression:progression];
    [self setStrumPattern:strumPattern];
  }
  return self;
}

@end
