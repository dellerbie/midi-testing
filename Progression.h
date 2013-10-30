//
//  Progression.h
//  MidiTesting
//
//  Created by Derrick Ellerbie on 10/30/13.
//  Copyright (c) 2013 dellerbie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Progression : NSObject

@property (nonatomic, strong) NSArray *chords;

- (id)initWithChords:(NSArray *)chords;

@end
