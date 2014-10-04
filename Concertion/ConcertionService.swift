//
//  ConcertionService.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

public class ConcertionService: NSObject {
	var meteor : MeteorClient
	var ddp : ObjectiveDDP
	var concertions : [Concertion] = []
	
	public override init() {
		self.meteor = MeteorClient(DDPVersion:"pre2")
		meteor.addSubscription("concertions")
		ddp = ObjectiveDDP(URLString:"ws://api.concertion.eu:3000/websocket", delegate:meteor)
		// local testing
		//ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:@"ws://localhost:3000/websocket" delegate:self.meteorClient];

		
		super.init()
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"connected", name:MeteorClientDidConnectNotification, object:nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"disconnected", name:MeteorClientDidDisconnectNotification, object:nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"updated", name:"concertions_added", object:nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"updated", name:"concertions_removed", object:nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector:"updated", name:"concertions_changed", object:nil)
		
		meteor.ddp = ddp
		meteor.ddp.connectWebSocket()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func connected() {
		println("Connected")
	}
	func disconnected() {
		println("Disconnected")
	}
	
	func updated() {
		println("Concertions:")
		var newConcertions : [Concertion] = []
		let oldConcertions = concertions
		for desc in meteor.collections["concertions"] as [AnyObject] {
			var concertion : Concertion!
			for old in oldConcertions {
				if old.identifier == desc["_id"] as String? {
					concertion = old
					break
				}
			}
			if concertion == nil {
				concertion = Concertion()
				concertion.changedLocallyListener = {
					[unowned self]
					Void -> Void in
					self.pushConcertionChanges(concertion)
				}
			}
			
			if
				setIfChanged(&concertion.identifier, desc["_id"] as? String) ||
				setIfChanged(&concertion.currentTrack, Track(
					title: desc["title"] as String,
					artistName: desc["artistName"] as String,
					imageURL: NSURL(string:desc["imageURL"] as String),
					streamingURL: NSURL(string:desc["streamingURL"] as String)!
				)) ||
				setIfChanged(&concertion.playing, desc["playing"] as? Bool) ||
				setIfChanged(&concertion.time, Concertion.PlaybackTime(
					setAt: desc["setAt"] as NSTimeInterval,
					offset: desc["offset"] as NSTimeInterval
				))
			{
				concertion.changedRemotelyListener?()
			}
			
			newConcertions.append(concertion)
		}
		println(meteor.collections["concertions"])
	}
	
	func pushConcertionChanges(concertion: Concertion) {
	
	}
}

func setIfChanged<T: Equatable>(inout a: T?, b: T?) -> Bool
{
	if a != b {
		a = b
		return true
	} else {
		return false
	}
}

func setIfChanged(inout a: Bool, b: Bool) -> Bool
{
	if a != b {
		a = b
		return true
	} else {
		return false
	}
}

var _concertionServiceSingleton: ConcertionService?
