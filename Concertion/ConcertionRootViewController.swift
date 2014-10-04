//
//  ConcertionRootViewController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-05.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

class ConcertionRootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.setNavigationBarHidden(true, animated: animated)
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.setNavigationBarHidden(false, animated:animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
