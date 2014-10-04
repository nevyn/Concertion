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
	
	public override init() {
		self.meteor = MeteorClient(DDPVersion:"pre2")
		meteor.addSubscription("concertions")
		ddp = ObjectiveDDP(URLString:"ws://localhost:3000/websocket", delegate:meteor)
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
		println(meteor.collections["concertions"])
	}
}
