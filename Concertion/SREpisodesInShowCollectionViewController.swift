//
//  SREpisodesInShowCollectionViewController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

class SREpisodesInShowCollectionViewController: UICollectionViewController {
    
    var program: SverigesRadio.Program? = nil;
    var episodes: SverigesRadio.EpisodeList? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

        if (self.program != nil) {
            self.program!.fetchEpisodes().onComplete { (value) -> () in
                self.episodes = value
                self.collectionView?.reloadData()
            }
        }
    }

    
    func item(at indexPath :NSIndexPath) -> SverigesRadio.Episode {
        return self.episodes![indexPath.row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let episode = self.episodes![indexPath.row]
        
        let track = Track(
            title: episode.name,
            artistName: self.program!.name,
            imageURL: episode.imageURL,
            streamingURL: episode.broadcastURL!
        )
        PlaybackController.sharedInstance().startConcertion(track)
		self.navigationController?.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("concertion")! as UIViewController, animated: true)
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.episodes != nil ? self.episodes!.count : 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EpisodeCell", forIndexPath: indexPath) as UICollectionViewCell
    
        // Configure the cell
        
        let item = self.item(at: indexPath)
        
        let imageView = cell.viewWithTag(1) as UIImageView
        let label = cell.viewWithTag(2) as UILabel
        
        label.text = item.name
        UIImage.fetch(item.imageURL) { (image) in
            imageView.image = image
            let fade = CATransition()
            fade.type = kCATransitionFade
            imageView.layer.addAnimation(fade, forKey: "transition")
        }
    
        return cell
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
