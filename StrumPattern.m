//
//  StrumPattern.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "StrumPattern.h"

@implementation StrumPattern

+ (NSArray *)strumEventsForPatternNumber:(int)patternNumber
{
  NSMutableArray *events = [[NSMutableArray alloc] init];
  
  NSString *pattern = [NSString stringWithFormat:@"pattern%i", patternNumber];
  
  for(NSArray *timeEvent in [self performSelector: NSSelectorFromString(pattern)])
  {
    StrumEvent strumEvent;
    strumEvent.timestamp = [[timeEvent objectAtIndex:0] doubleValue];
    strumEvent.duration = [[timeEvent objectAtIndex:1] doubleValue];
    strumEvent.strumDirection = [[timeEvent objectAtIndex:2] integerValue];;
    NSValue *value = [NSValue valueWithBytes:&strumEvent objCType:@encode(StrumEvent)];
    [events addObject:value];
  }
  
  return [events copy];
}

+ (NSArray *)pattern1
{
  static NSArray *rawTimeEvents = nil;
  if(rawTimeEvents == nil)
  {
    rawTimeEvents = @[@[@1.0, @1.0, @1.0], @[@2.0, @1.0, @1.0], @[@3.0, @1.0, @1.0], @[@4.0, @1.0, @1.0]];
  }
  return rawTimeEvents;
}



@end
