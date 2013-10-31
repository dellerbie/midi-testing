//
//  Progression.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "Progression.h"

@implementation Progression

@synthesize chords = _chords;

- (id)initWithChords:(NSArray *)chords
{
  self = [super init];
  if(self)
  {
    NSAssert([chords count] == 4, @"4 chords are required for a progession.");
    NSMutableArray *upcaseChords = [[NSMutableArray alloc] init];
    for(NSString *chord in chords)
    {
      [upcaseChords addObject:[chord uppercaseString]];
    }
    [self setChords:upcaseChords];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"[%@]", [[self chords] componentsJoinedByString:@","]];;
}

@end
