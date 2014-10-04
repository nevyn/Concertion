//
//  RootSourcesCollectionViewController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

class RootSourcesCollectionViewController: UICollectionViewController {
    
    var stations :SverigesRadio.ChannelList? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        SverigesRadio().channels().onComplete { (value) -> () in
            // Take 5 first. the range subscript seems bugged
            var firstFive = SverigesRadio.ChannelList()
            for i in 1...min(5, value.count) {
                firstFive.append(value[i])
            }
            self.stations = firstFive
            self.collectionView?.reloadData()
        }
    }

	
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		//segue.destinationViewController
    }
	
	// MARK: Data
    
    func sections() -> [[Track]] {
        let srTracks: [Track] = (self.stations != nil) ? self.stations!.map({ (channel) -> Track in
            return Track(title: channel.name,
                artistName: "Sveriges Radio",
                imageURL:channel.imageURL,
                streamingURL: channel.liveAudioFileURL
            )
        }) : []
        
        return [srTracks]
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
        return contentForSection(section).count + 1
    }
	
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView
	{
		let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "SectionHeader", forIndexPath: indexPath) as UICollectionReusableView
		let label = view.viewWithTag(1) as UILabel
		
		label.text = ["Nearby Concertions", "Recommended SR stations", "Spotify music"][indexPath.section]
		
		return view
	}


    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let content = contentForSection(indexPath.section)
		if indexPath.row == content.count {
			return collectionView.dequeueReusableCellWithReuseIdentifier("MoreCell", forIndexPath: indexPath) as UICollectionViewCell
		}
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendCell", forIndexPath: indexPath) as UICollectionViewCell
    
        // Configure the cell
    
        return cell
    }
	
	override  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		let content = contentForSection(indexPath.section)

		if indexPath.row == content.count {
			self.performSegueWithIdentifier("showSR", sender: self)
			return
		}
        
        let track = content[indexPath.row]
        
		PlaybackController.sharedInstance().play(track)
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
