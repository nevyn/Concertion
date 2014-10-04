//
//  RootSourcesCollectionViewController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

class ConcertionsCollectionViewController: UICollectionViewController {
    
    var stations :SverigesRadio.ChannelList? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
	
    }

	
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		//segue.destinationViewController
    }
	
	// MARK: Data
    
    func sections() -> [[Track]] {
        return [
			[Track(title: "asdf", artistName: "asdf", imageURL: nil, streamingURL: NSURL(string:"asdf")), Track(title: "asdf", artistName: "asdf", imageURL: nil, streamingURL: NSURL(string:"asdf"))],
		]
    }
	
	func contentForSection(section: Int) -> [Track]
	{
        return self.sections()[section]
	}
	

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return self.sections().count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return contentForSection(section).count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let content = contentForSection(indexPath.section)
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as UICollectionViewCell
    
        // Configure the cell
    
        return cell
    }
	
	override  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		let content = contentForSection(indexPath.section)
        
        let track = content[indexPath.row]
	}

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
