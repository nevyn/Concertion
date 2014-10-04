//
//  PlaybackController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit
import AVFoundation


public class PlaybackController: NSObject {
	
	// MARK: Public
	
	class func sharedInstance() -> PlaybackController
	{
		if _playControllerSingleton == nil {
			_playControllerSingleton = PlaybackController()
		}
		return _playControllerSingleton!
	}
	
	
	public func play(url: NSURL) {
		player.play(url.absoluteString)
	}
	
	// MARK: Private
	var player: STKAudioPlayer = STKAudioPlayer()
	lazy var obs : FBKVOController = FBKVOController(observer: self, retainObserved: false)
	
}
var _playControllerSingleton : PlaybackController?
