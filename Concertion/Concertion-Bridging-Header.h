//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "FBKVOController.h"
#import <StreamingKit/STKAudioPlayer.h>
#import "XMLDictionary.h"
#import <ObjectiveDDP/MeteorClient.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FBKVOController.h"

#import "CCMumble.h"

static inline UInt32 playerStateToInt(STKAudioPlayerState type) {
    return (UInt32) type;
}
