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
	
	public class func sharedInstance() -> ConcertionService
	{
		return _concertionServiceSingleton!
	}
	
	public override init() {
		self.meteor = MeteorClient(DDPVersion:"pre2")
		meteor.addSubscription("concertions")
		ddp = ObjectiveDDP(URLString:"ws://api.concertion.eu:3000/websocket", delegate:meteor)
		// local testing
		//ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:@"ws://localhost:3000/websocket" delegate:self.meteorClient];

		
		super.init()
		_concertionServiceSingleton = self
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
		println("Service Connected")
	}
	func disconnected() {
		println("Service Disconnected")
	}
	
	func updated() {
		println("Concertions updated")
		var newConcertions : [Concertion] = []
		let oldConcertions = concertions
		var collection = meteor.collections["concertions"] as M13OrderedDictionary
		
		for key in collection.allKeys() {
			var desc = collection[key] as NSDictionary
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
			
			var track : NSDictionary! = desc["currentTrack"] as? NSDictionary
			var time : NSDictionary! = desc["time"] as? NSDictionary
			if [
				setIfChanged(&concertion.identifier, desc["_id"] as? String),
				setIfChanged(&concertion.name, desc["name"] as? String),
				setIfChanged(&concertion.currentTrack, track == nil ?  nil : Track(
					title: track["title"] as String,
					artistName: track["artistName"] as String,
					imageURL: NSURL(string:track["imageURL"] as String),
					streamingURL: NSURL(string:track["streamingURL"] as String)
				)),
				setIfChanged(&concertion.playing, desc["playing"] as? Bool),
				setIfChanged(&concertion.time, time == nil ? nil : Concertion.PlaybackTime(
					setAt: time["setAt"] as NSTimeInterval,
					offset: time["offset"] as NSTimeInterval
				))].reduce(true, { $0 && $1 })
			{
				concertion.changedRemotelyListener?()
			}
			
			newConcertions.append(concertion)
		}
		concertions = newConcertions
	}
	
	func publishNewConcertion(concertion: Concertion) {
		concertions.append(concertion)
		
		concertion.changedLocallyListener = {
			[unowned self]
			Void -> Void in
			self.pushConcertionChanges(concertion)
		}
		
		println("Sending consertion")
		self.meteor.callMethodName(
			"/concertions/insert",
			parameters:[concertion.serialized()],
			responseCallback:{
				(response: [NSObject: AnyObject]!, error: NSError!) -> Void in
				println("insert response: \(response) \(error)")
			}
		)
	}
	
	func pushConcertionChanges(concertion: Concertion) {
		println("Updating consertion")
		var params : [AnyObject] = [NSDictionary(dictionary: [
			"_id": concertion.identifier!
		]), NSDictionary(dictionary:[
			"$set": concertion.serialized()
		])]
		self.meteor.callMethodName(
			"/concertions/update",
			parameters:params,
			responseCallback:{
				(response: [NSObject: AnyObject]!, error: NSError!) -> Void in
				println("update response: \(response) \(error)")
			}
		)
	}
}

func setIfChanged<T: Equatable>(inout a: T?, b: T?) -> Bool
{
	if a? != b? {
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
