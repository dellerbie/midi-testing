//
//  Song.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "Song.h"
#import "Bar.h"
#import <tgmath.h>

@interface Song()

@property (nonatomic, strong) NSMutableArray *bars;

@end

@implementation Song

+ (NSDictionary *) notes
{
  static NSDictionary *notes;
  if(notes == nil)
  {
    notes = @{ @"C": @60, @"C#": @61, @"D": @62, @"D#": @63, @"E": @64, @"F": @65, @"F#": @66, @"G": @67, @"G#": @68, @"A": @69, @"A#": @70, @"B": @71};
  }
  return notes;
}

// gets the first beat number for the given barNumber
// in 4/4 time
+ (int)beatNumberForBarNumber:(int) barNumber
{
  return (4 * barNumber) - 3;
}

- (id)init
{
  self = [super init];
  if(self)
  {
    [self setBars:[[NSMutableArray alloc] init]];
  }
  return self;
}

- (NSString *)description
{
  NSString *desc = @"";
  for(Bar *bar in self.bars)
  {
    [desc stringByAppendingString:[bar description]];
    [desc stringByAppendingString:@"\n"];
  }
  return desc;
}

- (Bar *)appendBar
{
  Bar *bar = [[Bar alloc] init];
  [bar setBarNumber:[[self bars] count] + 1];
  [[self bars] addObject:bar];
  return bar;
}

- (Bar *)addBarAtBarNumber:(int)barNumber
{
  Bar *bar = [[Bar alloc] init];
  [bar setBarNumber:barNumber];
  [[self bars] insertObject:bar atIndex:barNumber - 1];
  return bar;
}

- (void)addProgession:(Progression *)progression withStrumPattern:(int)strumPatternNumber toTrack:(MusicTrack)track atBar:(Bar *)bar
{
  NSArray *chords = [progression chords];
  NSArray *strumEvents = [StrumPattern strumEventsForPatternNumber:strumPatternNumber];
  
  int currentNote = [[[Song notes] objectForKey:[chords objectAtIndex:0]] integerValue];
  MusicTimeStamp currentBeat = 1.0;
  
  for(NSValue *value in strumEvents)
  {
    StrumEvent strumEvent;
    [value getValue:&strumEvent];
    
    MusicTimeStamp timestamp = strumEvent.timestamp;
    if(floor(timestamp) != currentBeat)
    {
      currentNote = [[[Song notes] objectForKey:[chords objectAtIndex:floor(timestamp - 1.0)]] integerValue];
    }
    
    currentBeat = timestamp;
    
    float beatNumber = [Song beatNumberForBarNumber:[bar barNumber]];
    MusicTimeStamp realTimeStamp = beatNumber + (timestamp - 1.0);
    NSLog(@"Note: %i, Duration: %f, timestamp: %f", currentNote, strumEvent.duration, realTimeStamp);
    
    MIDINoteMessage noteMessage = { 0, currentNote, 100, 0, strumEvent.duration };
    MusicTrackNewMIDINoteEvent(track, realTimeStamp, &noteMessage);
  }
  
  [bar setStrumPatternNumber:strumPatternNumber];
  [bar setProgression:progression];
}

@end
