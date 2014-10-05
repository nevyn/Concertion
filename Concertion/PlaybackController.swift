//
//  PlaybackController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit
import AVFoundation

public struct Track : Equatable {
	let title: String
	let artistName: String
	let imageURL: NSURL?
	let streamingURL: NSURL!
}
public func ==(lhs: Track, rhs: Track) -> Bool {
	return lhs.title == rhs.title &&
		lhs.artistName == rhs.artistName &&
		lhs.imageURL == rhs.imageURL &&
		lhs.streamingURL == rhs.streamingURL
}


public class Concertion: NSObject, Equatable {
	public var name : String? = RandomConcertionName()
	public internal(set) var identifier: String? = NSUUID().UUIDString
	public internal(set) var currentTrack: Track?
	public internal(set) var playing: Bool? = false
	public internal(set) var time: PlaybackTime?
	
	public struct PlaybackTime : Equatable {
		// the time at which the offset change was made
		let setAt: NSTimeInterval
		// the offset into the current track that was set
		let offset: NSTimeInterval
		
		// given the above two, which offset should we currently be at?
		func currentOffset() -> NSTimeInterval {
			let now = NSDate().timeIntervalSince1970

			return now - setAt + offset
		}
	}
	
	internal func serialized() -> Dictionary<String, AnyObject>
	{
		var ret : Dictionary<String, AnyObject> = Dictionary()
		if self.currentTrack != nil {
			ret["currentTrack"] = [
				"title": self.currentTrack!.title,
				"artistName": self.currentTrack!.artistName,
				"imageURL": self.currentTrack!.imageURL != nil ? self.currentTrack!.imageURL!.absoluteString! : "",
				"streamingURL": self.currentTrack!.streamingURL != nil ? self.currentTrack!.streamingURL!.absoluteString! : "",
			]
		}
		ret["name"] = self.name!
		ret["playing"] = self.playing?
		if self.time != nil {
			ret["time"] = [
				"setAt": self.time!.setAt,
				"offset": self.time!.offset,
			]
		}
		println("Serializing as \(ret)")
		
		return ret
	}
	
	// Broadcast after making changes
	var changedLocallyListener : (() -> ())? = nil
	
	var changedRemotelyListener : (() -> ())? = nil
}
public func ==(lhs: Concertion, rhs: Concertion) -> Bool {
	return lhs.identifier == rhs.identifier
}
public func ==(lhs: Concertion.PlaybackTime, rhs: Concertion.PlaybackTime) -> Bool {
	return lhs.setAt == rhs.setAt && lhs.offset == rhs.setAt
}


public class PlaybackController: NSObject, STKAudioPlayerDelegate {
	
	// MARK: Public
	
	public class func sharedInstance() -> PlaybackController
	{
		if _playControllerSingleton == nil {
			_playControllerSingleton = PlaybackController()
		}
		return _playControllerSingleton!
	}
	
	private override init()
	{
		super.init()
		player.delegate = self
	}
	
	
	public private(set) var currentConcertion : Concertion!
	
    
	public func play(track: Track) {
		player.play(track.streamingURL.absoluteString)
		
		if currentConcertion == nil {
			CCMumble.sharedInstance().joinEmptyChannel()
			println("Creating concertion!")
			currentConcertion = Concertion()
			ConcertionService.sharedInstance().registerNewConcertion(currentConcertion)
			self.currentConcertion?.changedRemotelyListener = {
				[unowned self]
				(Void) -> Void in
				self.updateFromConcertion()
			}
		}
		
		self.currentConcertion.currentTrack = track
		self.currentConcertion.playing = true
		self.currentConcertion.time = Concertion.PlaybackTime(setAt:NSDate().timeIntervalSince1970, offset:0)
		self.currentConcertion.changedLocallyListener?()
	}
	
	public func joinConcertion(concertion: Concertion?) {
        CCMumble.sharedInstance().joinOtherPlayer()
        
		self.currentConcertion?.changedRemotelyListener = nil
		self.currentConcertion = concertion
		self.currentConcertion?.changedRemotelyListener = {
			[unowned self]
			(Void) -> Void in
			self.updateFromConcertion()
		}
		println("Now in concertion \(concertion)")
		self.updateFromConcertion()
	}
	
	// MARK: Private
	private var player: STKAudioPlayer = STKAudioPlayer()
	private lazy var obs : FBKVOController = FBKVOController(observer: self, retainObserved: false)
	private var doSeek = false
	
	private func updateFromConcertion() {
		if let track = self.currentConcertion?.currentTrack {
			println("Updating from concertion: playing \(track.streamingURL) from \(self.currentConcertion.time!.currentOffset())")
			doSeek = true
			player.play(track.streamingURL.absoluteString)
			player.seekToTime(self.currentConcertion.time!.currentOffset())
		} else {
			println("Updating from concertion: not playing")
			self.player.pause()
		}
	}
	
	public func audioPlayer(player: STKAudioPlayer, didStartPlayingQueueItemId: NSObject)
	{
	
	}
	public func audioPlayer(player: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId: NSObject)
	{
	
	}
	public func audioPlayer(player: STKAudioPlayer, stateChanged: STKAudioPlayerState, previousState:STKAudioPlayerState)
	{
		if previousState == STKAudioPlayerStateBuffering && stateChanged == STKAudioPlayerStatePlaying && doSeek {
			player.seekToTime(self.currentConcertion.time!.currentOffset())
			doSeek = false
		}
	}
	public func audioPlayer(player: STKAudioPlayer, didFinishPlayingQueueItemId:NSObject, withReason:STKAudioPlayerStopReason, andProgress:Double, andDuration:Double)
	{
	
	}
	public func audioPlayer(player: STKAudioPlayer, unexpectedError:STKAudioPlayerErrorCode)
	{
		println("AudioPlayer error: \(unexpectedError)")
	}
	public func audioPlayer(player: STKAudioPlayer, logInfo:NSString)
	{
		println("AudioPlayer: \(logInfo)")
	}

	
}
var _playControllerSingleton : PlaybackController?

public func ==(lhs: STKAudioPlayerState, rhs: STKAudioPlayerState) -> Bool {
    return playerStateToInt(lhs) == playerStateToInt(rhs)
}

extension Array {
	func randomChoice() -> T {
		return self[Int(arc4random_uniform(UInt32(self.count)))]
	}
}

func RandomConcertionName() -> String {
	return ["Speedy", "Lounging", "Turbulent", "Fascinating", "Tectonic", "Hallucinatory", "Timid", "Midnight"].randomChoice() + " " + ["Llama", "Ocean", "Tulip", "Thunderstorm", "Blue", "Pancake", "Torus", "Autumn Evening", "Oracle", "Orange", "Face", "Plankton"].randomChoice()
}
