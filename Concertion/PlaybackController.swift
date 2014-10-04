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


public class PlaybackController: NSObject {
	
	// MARK: Public
	
	public class func sharedInstance() -> PlaybackController
	{
		if _playControllerSingleton == nil {
			_playControllerSingleton = PlaybackController()
		}
		return _playControllerSingleton!
	}
	
	public private(set) var currentTrack: Track?
	
	
	public func play(track: Track) {
		player.play(track.streamingURL.absoluteString)
		currentTrack = track
	}
	
	// MARK: Private
	var player: STKAudioPlayer = STKAudioPlayer()
	lazy var obs : FBKVOController = FBKVOController(observer: self, retainObserved: false)
	
}
var _playControllerSingleton : PlaybackController?
