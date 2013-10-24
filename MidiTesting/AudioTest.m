//
//  AudioTest.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/24/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "AudioTest.h"

@interface AudioTest()

@property (readwrite) AUGraph   processingGraph;
@property (readwrite) AudioUnit samplerUnit;
@property (readwrite) AudioUnit ioUnit;

@end

@implementation AudioTest

@synthesize processingGraph;
@synthesize samplerUnit;
@synthesize ioUnit;

+ audioTest
{
  return [[self alloc] init];
}

- (void) midiTest
{
  OSStatus result = noErr;
  
  [self createAUGraph];
  [self startAUGraph];
  [self startMusicSequence];
}

- (void)createAUGraph
{
  OSStatus result = noErr;
  AUNode samplerNode, ioNode;
  
  AudioComponentDescription componentDescription = {};
  componentDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
  
  // create the AU Graph
  result = NewAUGraph(&processingGraph);
  NSCAssert(result == noErr, @"Unable to create AUGraph object. Error code %d '%.4s'", (int)result, (const char *)&result);
  
  // Add the Sampler to the graph
  componentDescription.componentType = kAudioUnitType_MusicDevice;
  componentDescription.componentSubType = kAudioUnitSubType_Sampler;
  result = AUGraphAddNode(processingGraph, &componentDescription, &samplerNode);
  NSCAssert(result == noErr, @"Unable to add sampler to AUGraph. Error code %d '%.4s'", (int)result, (const char *)&result);
  
  // Add the output unit
  componentDescription.componentType = kAudioUnitType_Output;
  componentDescription.componentSubType = kAudioUnitSubType_RemoteIO; // output to speakers
  result = AUGraphAddNode(processingGraph, &componentDescription, &ioNode);
  NSCAssert(result == noErr, @"Unable to add the output unit to AUGraph. Error code %d '%.4s'", (int)result, (const char *)&result);
  
  // open the graph
  result = AUGraphOpen(processingGraph);
  NSCAssert(result == noErr, @"Unable to open the AUGraph. Error code %d '%.4s'", (int)result, (const char *)&result);
  
  // connect the sampler to the output
  result = AUGraphConnectNodeInput(processingGraph, samplerNode, 0, ioNode, 0);
  NSCAssert(result == noErr, @"Unable to connect the sampler to the output. Error code %d '%.4s'", (int)result, (const char *)&result);
  
  // obtain a reference to the sampler from its graph node
  result = AUGraphNodeInfo(processingGraph, samplerNode, 0, &samplerUnit);
  NSCAssert(result == noErr, @"Unable to get a reference to the sampler unit. Error code %d '%.4s'", (int)result, (const char *)&result);
  
  // obtain a reference to the output unit from its graph node
  result = AUGraphNodeInfo(processingGraph, ioNode, 0, &ioUnit);
  NSCAssert(result == noErr, @"Unable to get a reference to the io unit. Error code %d '%.4s'", (int)result, (const char *)&result);
}

- (void)startAUGraph
{
  OSStatus result = noErr;
  if(processingGraph)
  {
    result = AUGraphInitialize(processingGraph);
    NSAssert (result == noErr, @"Unable to initialze AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
    
    result = AUGraphStart(processingGraph);
    NSAssert (result == noErr, @"Unable to start AUGraph object. Error code: %d '%.4s'", (int) result, (const char *)&result);
  }
}

- (void)startMusicSequence
{
  MusicSequence sequence;
  NewMusicSequence(&sequence);
  
  // load up the MIDI File
  NSString *midiFilePath = [[NSBundle mainBundle] pathForResource:@"simpletest" ofType:@"mid"];
  NSURL *midiFileURL = [NSURL fileURLWithPath:midiFilePath];
  MusicSequenceFileLoad(sequence, (__bridge CFURLRef)midiFileURL, 0, 0);
  
  MusicPlayer player;
  NewMusicPlayer(&player);
  
  MusicPlayerSetSequence(player, sequence);
  MusicPlayerPreroll(player);
  MusicPlayerStart(player);
  
  // get length of track so that we know how long to kill time for
  MusicTrack track;
  MusicTimeStamp length;
  UInt32 size = sizeof(length);
  MusicSequenceGetIndTrack(sequence, 1, &track);
  MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &length, &size);
  NSLog(@"Track length in beats: %f", length);
  
  OSStatus result = noErr;
  
  while(1)
  {
    usleep(3 * 1000 * 1000);
    MusicTimeStamp now = 0;
    result = MusicPlayerGetTime(player, &now);
    NSAssert (result == noErr, @"Unable to get the music player time. Error code: %d '%.4s'", (int) result, (const char *)&result);
    NSLog(@"Current time: %6.2f beats", now);
    
    Float32 load;
    result = AUGraphGetCPULoad(processingGraph, &load);
    NSAssert (result == noErr, @"Unable to get cpu load. Error code: %d '%.4s'", (int) result, (const char *)&result);
    NSLog(@"CPU Load: %.2f", load * 100.0);
    
    if(now >= length)
    {
      break;
    }
  }
  
  // stop the player and dispose of objects
  MusicPlayerStop(player);
  DisposeMusicSequence(sequence);
  DisposeMusicPlayer(player);
}

@end
