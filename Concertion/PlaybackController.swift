//
//  PlaybackController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit
import AVFoundation

public struct Track {
	let title: String
	let artistName: String
	let imageURL: NSURL?
	let streamingURL: NSURL!
}

public class Concertion: NSObject {
	public var name = RandomConcertionName()
	public internal(set) var currentTrack: Track?
	public internal(set) var playing: Bool = false
	public internal(set) var time: PlaybackTime?
	
	public struct PlaybackTime {
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
	
	// Broadcast after making changes
	public func sendWasChangedLocally()
	{
		for listener in changedLocallyListeners {
			listener()
		}
	}
	var changedLocallyListeners : [() -> ()] = []
	
	public func sendWasChangedRemotely()
	{
		for listener in changedRemotelyListeners {
			listener()
		}
	}
	var changedRemotelyListeners : [() -> ()] = []
}


public class PlaybackController: NSObject {
	
	// MARK: Public
	
	public class func sharedInstance() -> PlaybackController
	{
		if _playControllerSingleton == nil {
			_playControllerSingleton = PlaybackController()
		}
		return _playControllerSingleton!
	}
	
	
	public private(set) var currentConcertion : Concertion = Concertion()
	
	
	public func play(track: Track) {
		player.play(track.streamingURL.absoluteString)
		self.currentConcertion.currentTrack = track
		self.currentConcertion.playing = true
		self.currentConcertion.time = Concertion.PlaybackTime(setAt:NSDate().timeIntervalSince1970, offset:0)
		self.currentConcertion.sendWasChangedLocally()
	}
	
	public func joinConcertion(concertion: Concertion) {
		self.currentConcertion.changedRemotelyListeners.removeAll()
		self.currentConcertion = concertion
		self.currentConcertion.changedRemotelyListeners.append({
			[unowned self]
			(Void) -> Void in
			self.updateFromConcertion()
		})
		self.updateFromConcertion()
	}
	
	// MARK: Private
	private var player: STKAudioPlayer = STKAudioPlayer()
	private lazy var obs : FBKVOController = FBKVOController(observer: self, retainObserved: false)
	
	private func updateFromConcertion() {
		if let track = self.currentConcertion.currentTrack {
			player.play(track.streamingURL.absoluteString)
			player.seekToTime(self.currentConcertion.time!.currentOffset())
		} else {
			self.player.pause()
		}
	}
	
}
var _playControllerSingleton : PlaybackController?

extension Array {
	func randomChoice() -> T {
		return self[Int(arc4random_uniform(UInt32(self.count)))]
	}
}

func RandomConcertionName() -> String {
	return ["Speedy", "Lounging", "Turbulent", "Fascinating", "Tectonic", "Hallucinatory", "Timid", "Midnight"].randomChoice() + " " + ["Llama", "Ocean", "Tulip", "Thunderstorm", "Blue", "Pancake", "Torus", "Autumn Evening", "Oracle", "Orange", "Face", "Plankton"].randomChoice()
}
