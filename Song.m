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
+ (MusicTimeStamp)beatNumberForBarNumber:(int) barNumber
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
  
  desc = [desc stringByAppendingString:[NSString stringWithFormat:@"%i Bars\n", [[self bars] count]]];

  int barNum = 1;
  for(Bar *bar in self.bars)
  {
    desc = [desc stringByAppendingString:[NSString stringWithFormat:@"Bar #%i => ", barNum]];
    desc = [desc stringByAppendingString:[bar description]];
    desc = [desc stringByAppendingString:@"\n"];
    barNum++;
  }
  return desc;
}

- (Bar *)appendBar
{
  Bar *bar = [[Bar alloc] init];
  [[self bars] addObject:bar];
  return bar;
}

- (Bar *)addBarAtBarNumber:(int)barNumber
{
  // TODO: shift MusicTrack events
  // SEE: MusicTrackMoveEvents
  Bar *bar = [[Bar alloc] init];
  [[self bars] insertObject:bar atIndex:barNumber - 1];
  return bar;
}

- (void)removeBar:(Bar *)bar
{
  // TODO: clear events for bar
  // SEE: MusicTrackCut
  [[self bars] removeObject:bar];
}

- (void)moveBar:(Bar *)bar toBarNumber:(int)barNumber
{
  int index = [[self bars] indexOfObject:bar];
  NSLog(@"index of bar to move: %i", index);
  
  MusicTimeStamp beatToMoveFrom = [Song beatNumberForBarNumber:index+1];
  MusicTimeStamp beatEndTime = beatToMoveFrom + 4;
  MusicTimeStamp beatToMoveTo = [Song beatNumberForBarNumber:barNumber];
  
  NSLog(@"beatToMoveFrom: %f, beatEndTime: %f, beatToMoveTo: %f", beatToMoveFrom, beatEndTime, beatToMoveTo);

  MusicTrack tmpTrack;
  MusicSequenceNewTrack(self.sequence, &tmpTrack);
  
  // copy to tmpTracks first beat
  OSStatus result = MusicTrackCopyInsert(self.track, beatToMoveFrom, beatEndTime, tmpTrack, 1.0);
  NSAssert (result == noErr, @"Unable to move bar. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // remove the events from the original track
  result = MusicTrackCut(self.track, beatToMoveFrom, beatEndTime);
  NSAssert (result == noErr, @"Unable to move bar. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // copy the events from the tmpTrack back to the new position in the original track
  result = MusicTrackCopyInsert(tmpTrack, 1.0, 5.0, self.track, beatToMoveTo);
  NSAssert (result == noErr, @"Unable to move bar. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // get rid of the tmpTrack
  result = MusicSequenceDisposeTrack(self.sequence, tmpTrack);
  NSAssert (result == noErr, @"Unable to move bar. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // update the bar position in the data structure
  [[self bars] exchangeObjectAtIndex:index withObjectAtIndex:barNumber - 1];
}

- (void)addProgession:(Progression *)progression withStrumPattern:(int)strumPatternNumber toBar:(Bar *)bar
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
    
    float beatNumber = [Song beatNumberForBarNumber: [[self bars] indexOfObject: bar] + 1];
    MusicTimeStamp realTimeStamp = beatNumber + (timestamp - 1.0);
    NSLog(@"Note: %i, Duration: %f, timestamp: %f", currentNote, strumEvent.duration, realTimeStamp);
    
    MIDINoteMessage noteMessage = { 0, currentNote, 100, 0, strumEvent.duration };
    
    // TODO: Might have to remove the previous events first
    // SEE: MusicTrackClear
    MusicTrackNewMIDINoteEvent(self.track, realTimeStamp, &noteMessage);
  }
  
  [bar setStrumPatternNumber:strumPatternNumber];
  [bar setProgression:progression];
}

@end
