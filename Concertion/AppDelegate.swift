//
//  AppDelegate.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var service = ConcertionService()

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
        CCMumble.sharedInstance().connectToHost("172.20.10.10")
		return true
	}
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
    }

}

