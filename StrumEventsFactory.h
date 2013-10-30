//
//  StrumPatternFactory.h
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StrumEventsFactory : NSObject

+ (NSArray *)strumEventsForPatternNumber: (int)patternNumber;

@end