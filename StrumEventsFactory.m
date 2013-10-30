//
//  StrumPatternFactory.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "StrumEventsFactory.h"

@implementation StrumEventsFactory

+ (NSArray *)strumEventsForPatternNumber: (int)patternNumber
{
  NSString *classString = [NSString stringWithFormat:@"StrumPattern%i", patternNumber];
  Class patternClass = NSClassFromString(classString);
  NSLog(@"StrumPatternClass: %@", patternClass);
  NSArray *strumEvents = [patternClass performSelector: @selector(strumEvents)];
  return strumEvents;
}

@end
