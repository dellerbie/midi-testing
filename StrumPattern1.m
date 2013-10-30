//
//  StrumPattern1.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "StrumPattern1.h"

@implementation StrumPattern1

+ (NSArray *)strumEvents
{
  NSMutableArray *events = [[NSMutableArray alloc] init];
  
  // tuples of startBeat & duration
  NSArray *rawTimeEvents = @[@[@1.0, @1.0], @[@2.0, @1.0], @[@3.0, @1.0], @[@4.0, @1.0]];
  for(NSArray *timeEvent in rawTimeEvents)
  {
    StrumEvent strumEvent;
    strumEvent.timestamp = [[timeEvent objectAtIndex:0] doubleValue];
    strumEvent.duration = [[timeEvent objectAtIndex:1] doubleValue];
    strumEvent.strumDirection = kStrumDirection_Down;
    NSValue *value = [NSValue valueWithBytes:&strumEvent objCType:@encode(StrumEvent)];
    [events addObject:value];
  }
  
  return [events copy];
}

@end
