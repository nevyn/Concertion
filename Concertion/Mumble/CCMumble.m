
#import "CCMumble.h"
#import <UIKit/UIKit.h>

#import <MumbleKit/MKConnection.h>
#import <MumbleKit/MKServerModel.h>
#import <MumbleKit/MKAudio.h>
#import <MumbleKit/MKVersion.h>

@interface CCMumble () <MKConnectionDelegate, MKServerModelDelegate>
@property (nonatomic, strong) MKConnection *connection;
@property (nonatomic, strong) MKServerModel *serverModel;
@end

static CCMumble *g_sharedMumble = nil;

@implementation CCMumble

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_sharedMumble = [[CCMumble alloc] init];
    });

    return g_sharedMumble;
}

- (void)connectToHost:(NSString *)host;
{
    MKAudioSettings settings;
    [[MKAudio sharedAudio] readAudioSettings:&settings];
    settings.transmitType = MKTransmitTypeContinuous;
    [[MKAudio sharedAudio] updateAudioSettings:&settings];
    
    [[MKAudio sharedAudio] start];
    
    self.connection = [MKConnection new];
    self.connection.delegate = self;

    self.serverModel = [[MKServerModel alloc] initWithConnection:self.connection];
    [self.serverModel addDelegate:self];
    
    [self.connection setIgnoreSSLVerification:YES];
    [self.connection connectToHost:host port:64738];
}

- (MKChannel *)findChannelNamed:(NSString *)name amongst:(NSArray *)channels
{
    for (MKChannel *channel in channels) {
        if ([channel.channelName isEqualToString:name]) {
            return channel;
        }
        
        MKChannel *foundChannel = [self findChannelNamed:name amongst:channel.channels];
        if (foundChannel) {
            return foundChannel;
        }
    }
    
    return nil;
}

- (NSArray *)flatChildren:(MKChannel *)parent
{
    NSMutableArray *channels = [NSMutableArray new];
    for (MKChannel *channel in parent.channels) {
        if ([channel.channelName isEqual:@"Idle"]) {
            // Idle is an empty channel
            continue;
        }
        [channels addObject:channel];
        [channels addObjectsFromArray:[self flatChildren:channel]];
    }
    return channels;
}

- (void)joinOtherPlayer
{
    for (MKChannel *channel in [self flatChildren:self.serverModel.rootChannel]) {
        if (channel.users.count > 0) {
            NSLog(@"Joining channel %@", channel.channelName);
            [self.serverModel joinChannel:channel];
            break;
        }
    }
}

- (void)joinEmptyChannel
{
    for (MKChannel *channel in [self flatChildren:self.serverModel.rootChannel]) {
        if (channel.users.count == 0) {
            NSLog(@"Joining channel %@", channel.channelName);
            [self.serverModel joinChannel:channel];
            break;
        }
    }
}

- (void)joinChannelNamed:(NSString *)name
{
    MKChannel *channel = [self findChannelNamed:name amongst:self.serverModel.rootChannel.channels];

    if (channel) {
        [self.serverModel joinChannel:channel];
    } else {
        NSLog(@"Didn't find a channel named '%@'", name);
    }
}


#pragma mark - MKServerModelDelegate

//
//
/////------------------------------------------
///// @name Connection and disconnection events
/////------------------------------------------
//
///// Called upon successfully authenticating with a server.
///// This method is deprecated, see serverModel:joinedServerAsUser:withWelcomeMessage:.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The MKUser object representing the local user.
//- (void) serverModel:(MKServerModel *)model joinedServerAsUser:(MKUser *)user;
//
///// Called upon successfully authenticating with a server.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The MKUser object representing the local user.
///// @param msg    The welcome message presented by the server.
- (void) serverModel:(MKServerModel *)model joinedServerAsUser:(MKUser *)user withWelcomeMessage:(MKTextMessage *)msg;
{
    [self joinChannelNamed:@"Idle"];
}
//
///// Called when disconnected from the server (forcefully or not).
/////
///// @param model  The MKServerModel object in which this event originated.
//- (void) serverModelDisconnected:(MKServerModel *)model;
//
/////-------------------
///// @name User changes
/////-------------------
//
///// Called when a new user joins the server.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The user who joined the server.
//- (void) serverModel:(MKServerModel *)model userJoined:(MKUser *)user;
//
///// Called when the talk state of a user changes.
///// This event is fired when the audio subsystem (MKAudio and its minions) notify
///// the MKServerModel that audio data from a user on the connection handled by the
///// server model is being played back.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The user whose talk state changed.
//- (void) serverModel:(MKServerModel *)model userTalkStateChanged:(MKUser *)user;
//
///// Called when a user is renamed.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The user that was renamed.
//- (void) serverModel:(MKServerModel *)model userRenamed:(MKUser *)user;
//
///// Called when a user is moved to another channel.
///// This is also called when a user changes the channel he resides in (in which
///// case user is equivalent to mover).
/////
///// In case the server initiated the move, the mover is nil.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The user that was moved.
///// @param chan   The channel to which user was moved to.
///// @param mover  The user that performed the user move. If the move was
/////               performed by the server, mover is nil.
- (void) serverModel:(MKServerModel *)model userMoved:(MKUser *)user toChannel:(MKChannel *)chan byUser:(MKUser *)mover
{
//    [model requestAccessControlForChannel:chan];
    [self.serverModel createChannelWithName:@"Mine" parent:chan temporary:YES];
}
//
///// Called when a user is moved to another channel.
///// This is also called when a user changes the channel he resides in (in which
///// case user is equivalent to mover).
/////
///// In case the server initiated the move, the mover is nil.
/////
///// @param model     The MKServerModel object in which this event originated.
///// @param user      The user that was moved.
///// @param chan      The channel to which user was moved to.
///// @param prevChan  The channel from which the user was moved. (May be nil)
///// @param mover     The user that performed the user move. If the move was
/////                  performed by the server, mover is nil.
//- (void) serverModel:(MKServerModel *)model userMoved:(MKUser *)user toChannel:(MKChannel *)chan fromChannel:(MKChannel *)prevChan byUser:(MKUser *)mover;
//
///// Called when a user's comment is changed.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user whose comment was changed.
//- (void) serverModel:(MKServerModel *)model userCommentChanged:(MKUser *)user;
//
///// Called when a user's texture is changed.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user whose texture was changed.
//- (void) serverModel:(MKServerModel *)model userTextureChanged:(MKUser *)user;
//
/////--------------------
///// @name Text messages
/////--------------------
//
///// Called whenever a text message is receieved.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param msg    The MKTextMessage object representing the received text message.
///// @param user   The MKUser that sent the text message (nil if the message was sent by the server).
//- (void) serverModel:(MKServerModel *)model textMessageReceived:(MKTextMessage *)msg fromUser:(MKUser *)user;
//
/////--------------------------------
///// @name Self-mute and self-deafen
/////--------------------------------
//
///// Called when a user self-mutes himself.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The user who self-muted himself.
//- (void) serverModel:(MKServerModel *)model userSelfMuted:(MKUser *)user;
//
///// Called when a user removes his self-mute status.
/////
///// @param model  The MKServerModel object in which this event originated.
///// @param user   The user who removed his self-mute status.
//- (void) serverModel:(MKServerModel *)model userRemovedSelfMute:(MKUser *)user;
//
///// Called when a user self-mute-deafens himself.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who self-muted and self-deafened himself.
//- (void) serverModel:(MKServerModel *)model userSelfMutedAndDeafened:(MKUser *)user;
//
///// Called when a user removes his self-mute-deafen status.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who removed his self-mute-deafen status.
//- (void) serverModel:(MKServerModel *)model userRemovedSelfMuteAndDeafen:(MKUser *)user;
//
///// Called by the MKServerModel when a user's self-mute-deafen status changes.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user whose self-mute-deafen status changed.
//- (void) serverModel:(MKServerModel *)model userSelfMuteDeafenStateChanged:(MKUser *)user;
//
/////----------------------------------------
///// @name Muting, deafening and suppressing
/////----------------------------------------
//
///// Called when a user mutes-deafens another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who was mute-deafened.
///// @param actor  The user who initiated the mute-deafen action on the other user.
/////               May be nil if the server mute-deafened the user.
//- (void) serverModel:(MKServerModel *)model userMutedAndDeafened:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user removes mute-deafen status from another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user whose mute-deafen status was removed.
///// @param actor  The user who iniated the removal of the other user's mute-deafen status.
/////               May be nil if the server removed the mute-deafen status.
//- (void) serverModel:(MKServerModel *)model userUnmutedAndUndeafened:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user is muted by another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who was muted.
///// @param actor  The user who muted the other user. May be nil if the user was muted by
/////               the server.
//- (void) serverModel:(MKServerModel *)model userMuted:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user is unmuted by another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who was unmuted.
///// @param actor  The user who unmuted the other user. May be nil if the user was unmuted by the
/////               server.
//- (void) serverModel:(MKServerModel *)model userUnmuted:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user is deafened by another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who was deafened.
///// @param actor  The user who deafened the other user. May be nil if the user was deafened by
/////               the server.
//- (void) serverModel:(MKServerModel *)model userDeafened:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user is undeafened by another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who was undeafened.
///// @param actor  The user who undeafened the other user. May be nil if the user was undeafened
/////               by the server.
//- (void) serverModel:(MKServerModel *)model userUndeafened:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user is suppressed by another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who was suppressed.
///// @param actor  The user who suppressed the other user. May be nil if the user was
/////              suppressed by the server.
//- (void) serverModel:(MKServerModel *)model userSuppressed:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user is unsuppressed by another user.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user who was unsuppressed.
///// @param actor  The user who unsuppresed the other user. May be nil if the user was
/////               unsupressed by the server.
//- (void) serverModel:(MKServerModel *)model userUnsuppressed:(MKUser *)user byUser:(MKUser *)actor;
//
///// Called when a user's mute state changes.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user whose mute state changed.
//- (void) serverModel:(MKServerModel *)model userMuteStateChanged:(MKUser *)user;
//
/////------------------------------
///// @name Other user flag changes
/////------------------------------
//
///// Called when the user's authenticated flag changes.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user whose authenticated flag changed.
//- (void) serverModel:(MKServerModel *)model userAuthenticatedStateChanged:(MKUser *)user;
//
///// Called when a user's priorty speaker flag changes.
/////
///// @param model  The MKServerModel in which this event originated.
///// @param user   The user whose priority speaker flag changed.
//- (void) serverModel:(MKServerModel *)model userPrioritySpeakerChanged:(MKUser *)user;
//
///// Called when a user's recording flag changes.
/////
///// @param model   The MKServerModle in which this event originated.
///// @param user    The user whose recording flag changed.
//- (void) serverModel:(MKServerModel *)model userRecordingStateChanged:(MKUser *)user;
//
/////--------------------
///// @name Leaving users
/////--------------------
//
///// Called when a user is banned by another user (or the server).
///// When a user is banned, he is also kicked from the server at the
///// same time.
/////
///// @param model   The MKServerModel in which this event originated.
///// @param user    The user that was banned.
///// @param actor   The user that banned the other user. May be nil if the
/////                ban was initiated by the server.
///// @param reason  The reason for the ban.
//- (void) serverModel:(MKServerModel *)model userBanned:(MKUser *)user byUser:(MKUser *)actor forReason:(NSString *)reason;
//
///// Called when a user is kicked by another user (or the server).
/////
///// @param model   The MKServerModel in which this event originated.
///// @param user    The user that was kicked.
///// @param actor   The user that kicked the other user. May be nil if the
/////                server initiated the kick.
///// @param reason  The reason for kicking the user off the server.
//- (void) serverModel:(MKServerModel *)model userKicked:(MKUser *)user byUser:(MKUser *)actor forReason:(NSString *)reason;
//
///// Called when a user disconnects from the server.
/////
///// @param model   The MKServerModel in which this event originated.
///// @param user    The user that disconnected.
//- (void) serverModel:(MKServerModel *)model userDisconnected:(MKUser *)user;
//
///// Called when a user leaves the server.
/////
///// @param model   The MKServerModel in which this event originated.
///// @param user    The user that left the server.
//- (void) serverModel:(MKServerModel *)model userLeft:(MKUser *)user;
//
/////-----------------------------
///// @name Channel-related events
/////-----------------------------
//
///// Called when a new channel is added.
/////
///// @param model    The MKserverModel in which this event originated.
///// @param channel  The channel that was added.
//- (void) serverModel:(MKServerModel *)model channelAdded:(MKChannel *)channel;
//
///// Called when a channel is removed from the server.
/////
///// @param model    The MKServerModel in which this event originated.
///// @param channel  The channel that was removed.
//- (void) serverModel:(MKServerModel *)model channelRemoved:(MKChannel *)channel;
//
///// Called when a channel is renamed.
/////
///// @param model    The MKServerModel in which this event originated.
///// @param channel  The channel that was renamed.
//- (void) serverModel:(MKServerModel *)model channelRenamed:(MKChannel *)channel;
//
///// Called when a channel's position is changed.
/////
///// @param model    The MKServerModel in which this event originated.
///// @param channel  The channel whose position was changed.
//- (void) serverModel:(MKServerModel *)model channelPositionChanged:(MKChannel *)channel;
//
///// Called when a channel (and all of its subchannels, and users) is re-parented.
/////
///// @param model    The MKServerModel in which this event originated.
///// @param channel  The channel that was moved.
//- (void) serverModel:(MKServerModel *)model channelMoved:(MKChannel *)channel;
//
///// Called when a channel description is changed.
/////
///// @param model    The MKServerModel in which this event originated.
///// @param channel  The channel whose description was changed.
//- (void) serverModel:(MKServerModel *)model channelDescriptionChanged:(MKChannel *)channel;
//
///// Called when a complete list of links for a channel is receieved. (This happens
///// mostly during initial connect).
/////
///// @param model     The MKServerModel in which this event originated.
///// @param newLinks  An array of channels whose links were changed.
///// @param channel   The channel for which newLinks were set for.
//- (void) serverModel:(MKServerModel *)model linksSet:(NSArray *)newLinks forChannel:(MKChannel *)channel;
//
///// Called when new channels links are added to a channel.
/////
///// @param model     The MKServerModel in which this event originated.
///// @param newLinks  An array of channels that the channel was linked to.
///// @param channel   The channel that the links were added to.
//- (void) serverModel:(MKServerModel *)model linksAdded:(NSArray *)newLinks toChannel:(MKChannel *)channel;
//
///// Called when channel links are removed from a channel.
/////
///// @param model         The MKServerModel in which this event originated.
///// @param removedLinks  An array of channels that were unlinked from the channel.
///// @param channel       The channel that the links were removed from.
//- (void) serverModel:(MKServerModel *)model linksRemoved:(NSArray *)removedLinks fromChannel:(MKChannel *)channel;
//
///// Called when a channel's links change.
/////
///// @param model    The MKServerModel in which this event originated.
///// @param channel  The channel whose links changed.
//- (void) serverModel:(MKServerModel *)model linksChangedForChannel:(MKChannel *)channel;
//
/////-------------------------------------
///// @name Errors and missing permissions
/////-------------------------------------
//
///// Called when a permission error occurred for a given channel for a given user.
/////
///// @param  model    The MKServerModel in which this permission error occurred.
///// @param  perm     The permission that was denied
///// @param  user     The user for whom the permission was denied.
///// @param  channel  The channel in which the permission was denied.
- (void) serverModel:(MKServerModel *)model permissionDenied:(MKPermission)perm forUser:(MKUser *)user inChannel:(MKChannel *)channel
{
    NSLog(@"%@ %d %@", NSStringFromSelector(_cmd), perm, channel);
}
//
///// Called when a channel was attempted to be named or renamed to something
///// which was not allowed by the server.
/////
//// @param  model  The MKServerModel in which this error occured.
//- (void) serverModelInvalidChannelNameError:(MKServerModel *)model;
//
///// Called when an attempt to modify the SuperUser failed.
/////
///// @param  model  The MKServerModel in which the error occurred.
//- (void) serverModelModifySuperUserError:(MKServerModel *)model;
//
///// Called when the server received a text message that was too long.
/////
///// @param  model  The MKServerModel in which the error occurred.
//- (void) serverModelTextMessageTooLongError:(MKServerModel *)model;
//
///// Called when an action could not be performed on a temporary channel.
/////
///// @param  model  The MKServerModel in which the error occurred.
- (void) serverModelTemporaryChannelError:(MKServerModel *)model
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
//
///// Called when a certificate is needed, but not persent, for a given operation.
/////
///// @param  model  The MKServerModel in which the error occurred.
///// @param  user   The user who did not have a certificate.
//- (void) serverModel:(MKServerModel *)model missingCertificateErrorForUser:(MKUser *)user;
//
///// Called when an action involving an invalid username occurs.
/////
///// @param  model  The MKServerModel in which this error occurred.
///// @param  name   The name that was deemed invalid by the server. May be nil.
//- (void) serverModel:(MKServerModel *)model invalidUsernameErrorForName:(NSString *)name;
//
///// Called when a channel user move operation failed because the destination
///// channel was full. (Note: A joinChannel: also counts as a move operation.)
/////
///// @param  model  The MKServerModel in which this error occurred.
//- (void) serverModelChannelFullError:(MKServerModel *)model;
//
///// Called when a channel create operation failed because the channel
///// name was invalid.
/////
///// @param  model  The MKServerModel in which this error occurred.
//- (void) serverModelChannelNameError:(MKServerModel *)model;
//
///// Called when a simple 'Permission denied.' message is sufficient to show to the user.
///// Can include a reason. This kind of permission error is also used as a fallback, if
///// the server detects that a client is using a too old version of the Mumble protocol
///// to understand all error types.
/////
///// @param  model   The MKServerModel in which this error occurred.
///// @param  reason  The reason for the error. May be nil if no reason was given.
- (void) serverModel:(MKServerModel *)model permissionDeniedForReason:(NSString *)reason
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
//
///// Called after an access control request
/////
///// @param  model            The MKServerModel in which this event originated.
///// @param  accessControl    The requested access control.
///// @param  channel          The channel to which access control refers.
- (void) serverModel:(MKServerModel *)model didReceiveAccessControl:(MKAccessControl *)accessControl forChannel:(MKChannel *)channel
{
    NSLog(@"ACL %@ %@", NSStringFromSelector(_cmd), accessControl);
}



#pragma mark - MKConnectionDelgate

/// This method is called once a connection has been established to the remote host, and
/// the TLS handshake has finished.
/// Once the MKConnection has sent this message to its delegate, it is safe to authenticate
/// with the server.
///
/// @param conn  The connection that was opened.
- (void) connectionOpened:(MKConnection *)conn
{
    [conn authenticateWithUsername:[self randomUsername] password:nil accessTokens:nil];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (NSString *)randomUsername
{
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
     NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    return uuidString;
}

/// This method is called if a connection cannot be stablished to the given server.
///
/// @param conn The connection that this occurred in.
/// @param err  Error describing why the connection could not be established.
- (void) connection:(MKConnection *)conn unableToConnectWithError:(NSError *)err
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mumble" message:@"Connection error" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    [alert show];
}

/// This method is called whenever the connection is closed, be it by an error, or by
/// disconnection. If the disconnection was caused by an error, the err parameter will
/// be a non-nil value.
///
/// This method can only be called after the connection has been opened. If an error occurs
/// during the connection phase, the method `connection:unableToConnectWithError:` will be
/// called instead.
///
/// @param conn  The connection that was closed.
/// @param err   The error that caused the disconnection. (Nil if not caused by an error)
- (void) connection:(MKConnection *)conn closedWithError:(NSError *)err
{
    NSLog(@"%@ %@", NSStringFromSelector(_cmd), err);
    [conn reconnect];
}

/// This method is called if the MKConnection could not verify the TLS certificate chain
/// of the remote server as trusted.
///
/// To implement support for self-signed certificates, one wold typically save the digest
/// of the leaf certificate of the server's certificate chain somewhere along with host
/// information for the server (hostname:port) that the trust failure happened on.
/// Then, every time a connection attempt is made, the trust failure can then be remedied
/// by setting setIgnoreSSLVerification property on the MKConnection and issuing a
/// reconnect to the MKConnection object.
///
/// @param conn   The connection that the trust failure occurred on.
/// @param chain  The TLS certificate chain of the remote server.
///               (An array of MKCertificate objects)
- (void) connection:(MKConnection *)conn trustFailureInCertificateChain:(NSArray *)chain
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

/// The connection attempt was rejected. This could, for example, be an authentication failure.
///
/// @param conn         The MKConnection object whose connection was rejected.
/// @param reason       The reason for the rejected connection attempt. (See MKRejectReason).
/// @param explanation  A textual description of the reason for rejection.
- (void) connection:(MKConnection *)conn rejectedWithReason:(MKRejectReason)reason explanation:(NSString *)explanation
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}


@end
