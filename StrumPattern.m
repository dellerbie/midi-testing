//
//  StrumPattern.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "StrumPattern.h"

NSMutableDictionary *strumPatterns;

@implementation StrumPattern

+ (void)initialize
{
  strumPatterns = [[NSMutableDictionary alloc] init];
  
  NSString *patternsFile = [[NSBundle mainBundle] pathForResource:@"StrumPatterns" ofType:@"txt"];
  NSString *patternsTxt = [NSString stringWithContentsOfFile:patternsFile encoding:NSUTF8StringEncoding error:NULL];
  NSArray *patterns = [patternsTxt componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
  
  int patternNumber = 1;
  for(NSString *pattern in patterns)
  {
    // ignore comment and blank lines
    if([pattern hasPrefix:@"#"] || [pattern length] == 0)
    {
      continue;
    }
    NSArray *strumEvents = [pattern componentsSeparatedByString:@"|"];
    for(NSString *strumEvent in strumEvents)
    {
      NSArray *components = [strumEvent componentsSeparatedByString:@","];
      [self createStrumEventFromComponents:components forPatternNumber: patternNumber];
    }
    
    patternNumber++;
  }
}

+ (void)createStrumEventFromComponents:(NSArray *)components forPatternNumber:(int)patternNumber
{
  NSAssert([components count] == 3, @"Invalid component format for pattern number %i. %@", patternNumber, components);
  
  NSString *patternName = [NSString stringWithFormat:@"pattern%i", patternNumber];
  NSArray *strumEvents = [strumPatterns objectForKey: patternName];
  if(strumEvents == nil)
  {
    [strumPatterns setObject:[[NSMutableArray alloc] init] forKey:patternName];
  }
  
  StrumEvent strumEvent;
  strumEvent.timestamp = [[components objectAtIndex:0] doubleValue];
  strumEvent.duration = [[components objectAtIndex:1] doubleValue];
  strumEvent.strumDirection = [[components objectAtIndex:2] integerValue];
  
  NSMutableArray *strumEventsForPattern = [strumPatterns objectForKey:patternName];
  NSValue *value = [NSValue valueWithBytes:&strumEvent objCType:@encode(StrumEvent)];
  [strumEventsForPattern addObject:value];
}


+ (NSArray *)strumEventsForPatternNumber:(int)patternNumber
{
  NSString *patternName = [NSString stringWithFormat:@"pattern%i", patternNumber];
  NSArray *strumEvents = [strumPatterns objectForKey: patternName];
  NSAssert(strumEvents != nil, @"Strum Pattern%i is not defined", patternNumber);

  return strumEvents;
}

@end
