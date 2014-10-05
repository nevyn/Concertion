//
//  CCMumble.h
//  Concertion
//
//  Created by Patrik Sjöberg on 04/10/14.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCMumble : NSObject

+ (instancetype)sharedInstance;

- (void)connectToHost:(NSString *)host;

- (void)joinChannelNamed:(NSString *)name;

- (void)joinOtherPlayer;
- (void)joinEmptyChannel;

@end
