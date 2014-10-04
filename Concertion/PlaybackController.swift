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
		if let alivePlayer = player {
			alivePlayer.pause()
			obs.unobserve(alivePlayer)
		}
		var error: NSError?
		player = AVPlayer(URL: url)
		if player == nil {
			println(error)
		} else {
			obs.observe(player, keyPath: "status", options: .Initial, block: {
				(selff : AnyObject!, playerr : AnyObject!, change : [NSObject : AnyObject]!) -> Void in
				var actualPlayer = playerr as AVPlayer
				switch(actualPlayer.status) {
					case .ReadyToPlay:
						actualPlayer.play()
					case .Unknown:
						println("Nothing yet...")
					case .Failed:
						println("ERRRORRR \(actualPlayer.error)")
				}
			})
		}
	}
	
	// MARK: Private
	var player: AVPlayer?
	lazy var obs : FBKVOController = FBKVOController(observer: self, retainObserved: false)
	
}
var _playControllerSingleton : PlaybackController?
