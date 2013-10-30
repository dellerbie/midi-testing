//
//  Song.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "Song.h"
#import "StrumEventsFactory.h"
#import <tgmath.h>

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

- (void)addProgession:(Progression *)progression withStrumPattern:(int)strumPatternNumber toTrack:(MusicTrack)track atBarNumber:(int)barNumber
{
  NSArray *chords = [progression chords];
  NSArray *strumEvents = [StrumEventsFactory strumEventsForPatternNumber:strumPatternNumber];
  
  int currentNote = [[[Song notes] objectForKey:[chords objectAtIndex:0]] integerValue];
  MusicTimeStamp currentBeat = 1.0;
  
  for(NSValue *value in strumEvents)
  {
    StrumEvent strumEvent;
    [value getValue:&strumEvent];
    
    MusicTimeStamp timestamp = strumEvent.timestamp;
    if(fmod(timestamp, 1.0) == 0.0 && timestamp != currentBeat)
    {
      currentBeat = timestamp;
      currentNote = currentNote = [[[Song notes] objectForKey:[chords objectAtIndex:floor(currentBeat - 1.0)]] integerValue];
    }
    
    float beatNumber = [Song beatNumberForBarNumber:barNumber];
    MusicTimeStamp realTimeStamp = beatNumber + (timestamp - 1.0);
    NSLog(@"Note: %i, Duration: %f, timestamp: %f", currentNote, strumEvent.duration, realTimeStamp);
    
    MIDINoteMessage noteMessage = { 0, currentNote, 100, 0, strumEvent.duration };
    MusicTrackNewMIDINoteEvent(track, realTimeStamp, &noteMessage);
  }
}

@end
