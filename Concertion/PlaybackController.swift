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
	let streamingURL: NSURL
}

public class Concertion: NSObject {
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
	
	
	public var currentConcertion : Concertion = Concertion() {
		didSet {
			
		}
	}
	
	
	public func play(track: Track) {
		player.play(track.streamingURL.absoluteString)
		self.currentConcertion.currentTrack = track
	}
	
	// MARK: Private
	private var player: STKAudioPlayer = STKAudioPlayer()
	private lazy var obs : FBKVOController = FBKVOController(observer: self, retainObserved: false)
	
}
var _playControllerSingleton : PlaybackController?
