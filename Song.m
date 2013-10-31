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

NSMutableDictionary *notes;
NSMutableDictionary *chordSteps;

@implementation Song

+ (void) initialize
{
  NSArray *noteKeys = @[@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B"];
  
  // this where we want the keys to start. 60 is middle C
  NSArray *noteValues = @[@60, @61, @62, @63, @64, @65, @66, @67, @68, @69, @70, @71];
  notes = [[NSMutableDictionary alloc] initWithObjects:noteValues forKeys:noteKeys];
  
  NSArray *steps = @[@0, @2, @4, @5, @7, @9, @11];
  NSArray *chords = @[@"I", @"II", @"III", @"IV", @"V", @"VI", @"VII"];
  chordSteps = [[NSMutableDictionary alloc] initWithObjects:steps forKeys:chords];
}

// gets the first beat number for the given barNumber
// in 4/4 time
+ (MusicTimeStamp)beatNumberForBarNumber:(int) barNumber
{
  return (4 * barNumber) - 3;
}

- (id)initWithSequence:(MusicSequence)sequence track:(MusicTrack)track
{
  self = [super init];
  if(self)
  {
    [self setSequence:sequence];
    [self setTrack:track];
    [self setBars:[[NSMutableArray alloc] init]];
    [self setKey:@"C"];
  }
  return self;
}

- (id)initWithSequence:(MusicSequence)sequence track:(MusicTrack)track file:(NSString *)fileName
{
  self = [self initWithSequence:sequence track:track];
  if(self)
  {
    NSBundle *applicationBundle = [NSBundle mainBundle];
    NSString *path = [applicationBundle pathForResource:fileName ofType:@"plist"];
    if(path)
    {
      NSMutableDictionary *songSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
      [self setKey:[songSettings objectForKey:@"Key"]];

      // add the bars to the song
      NSArray *tmpBars = [songSettings objectForKey:@"Bars"];
      for(NSDictionary *bar in tmpBars)
      {
        int strumPattern = [[bar objectForKey:@"StrumPattern"] integerValue];
        NSString *p = [bar objectForKey:@"Progression"];
        NSArray *chords = [p componentsSeparatedByString:@","];
        Progression *progression = [[Progression alloc] initWithChords:chords];
        Bar *bar = [self appendBar];
        [self addProgession:progression withStrumPattern:strumPattern toBar:bar];
      }
    }
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

- (void)removeBar:(Bar *)bar
{
  int index = [[self bars] indexOfObject:bar];
  if(index == NSNotFound)
  {
    NSLog(@"Couldn't find bar to remove from Song#bars");
    return;
  }
  
  NSLog(@"index of bar to remove: %i", index);
  
  // remove the events from the track
  MusicTimeStamp beatToRemoveFrom = [Song beatNumberForBarNumber:index+1];
  MusicTimeStamp beatEndTime = beatToRemoveFrom + 4;
  
  NSLog(@"beatToRemoveFrom: %f, beatEndTime: %f", beatToRemoveFrom, beatEndTime);
  OSStatus result = MusicTrackCut(self.track, beatToRemoveFrom, beatEndTime);
  NSAssert (result == noErr, @"Unable to cut track. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // remove it from the bars list
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
  OSStatus result = MusicSequenceNewTrack(self.sequence, &tmpTrack);
  NSAssert (result == noErr, @"Unable to create temporary track. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // copy to tmpTracks first beat
  result = MusicTrackCopyInsert(self.track, beatToMoveFrom, beatEndTime, tmpTrack, 1.0);
  NSAssert (result == noErr, @"Unable to copy insert track. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // remove the events from the original track
  result = MusicTrackCut(self.track, beatToMoveFrom, beatEndTime);
  NSAssert (result == noErr, @"Unable to cut track. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // copy the events from the tmpTrack back to the new position in the original track
  result = MusicTrackCopyInsert(tmpTrack, 1.0, 5.0, self.track, beatToMoveTo);
  NSAssert (result == noErr, @"Unable to copy insert track. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // get rid of the tmpTrack
  result = MusicSequenceDisposeTrack(self.sequence, tmpTrack);
  NSAssert (result == noErr, @"Unable to dispose track. Error code: %d '%.4s'", (int) result, (const char *)&result);
  
  // update the bar position in the data structure
  [[self bars] removeObject:bar];
  [[self bars] insertObject:bar atIndex:barNumber - 1];
}

- (void)addProgession:(Progression *)progression withStrumPattern:(int)strumPatternNumber toBar:(Bar *)bar
{
  NSArray *chords = [progression chords];
  NSArray *strumEvents = [StrumPattern strumEventsForPatternNumber:strumPatternNumber];
  
  int chordStep = [[chordSteps objectForKey:[chords objectAtIndex:0]] integerValue];
  int currentNote = [self noteForChordStep:chordStep];
  
  MusicTimeStamp currentBeat = 1.0;
  
  for(NSValue *value in strumEvents)
  {
    StrumEvent strumEvent;
    [value getValue:&strumEvent];
    
    MusicTimeStamp timestamp = strumEvent.timestamp;
    if(floor(timestamp) != currentBeat)
    {
      chordStep = [[chordSteps objectForKey:[chords objectAtIndex:floor(timestamp - 1.0)]] integerValue];
      currentNote = [self noteForChordStep:chordStep];
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

- (int)noteForChordStep:(int)chordStep
{
  int keyNote = [[notes objectForKey:[self key]] integerValue];
  int note = keyNote;
  if(keyNote != NSNotFound)
  {
    note = keyNote + chordStep;
  }
  return note;
}

@end
