//
//  AppDelegate.m
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/24/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioTest.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  
  AudioTest *at = [AudioTest audioTest];
  [at midiTest];
  return YES;
}

@end
