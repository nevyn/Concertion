//
//  SRShowsInChannelCollectionViewController.swift
//  Concertion
//
//  Created by Joachim Bengtsson on 2014-10-04.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

class SRShowsInChannelCollectionViewController: UICollectionViewController {
    
    var channel: SverigesRadio.Channel? = nil;
    var programs: SverigesRadio.ProgramList? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = false
        
        if (self.channel != nil) {
            self.channel?.fetchPrograms().onComplete({ (value) -> () in
                self.programs = value
                self.collectionView?.reloadData()
            })
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        
        if let viewController = segue.destinationViewController as? SREpisodesInShowCollectionViewController {
            let cell = sender as UICollectionViewCell!
            let indexPath = self.collectionView?.indexPathForCell(cell)
            let item = self.item(at: indexPath!)
            
            viewController.program = item
        }

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.programs != nil ? self.programs!.count : 0
    }

    func item(at indexPath :NSIndexPath) -> SverigesRadio.Program {
        return self.programs![indexPath.row]
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ShowCell", forIndexPath: indexPath) as UICollectionViewCell
    
        // Configure the cell
        
        let program = item(at: indexPath)
        
        let imageView = cell.viewWithTag(1) as UIImageView
        let label = cell.viewWithTag(2) as UILabel
        
        label.text = program.name
        UIImage.fetch(program.imageURL) { (image) in
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
