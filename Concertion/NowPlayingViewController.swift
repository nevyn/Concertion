//
//  NowPlayingViewController.swift
//  Concertion
//
//  Created by Patrik Sjöberg on 05/10/14.
//  Copyright (c) 2014 Concertionists. All rights reserved.
//

import UIKit

class NowPlayingViewController: UIViewController {
    let kvo = FBKVOController()
    var track: Track? {
        didSet {
            self.updateNowPlaying()
        }
    }
    
    @IBOutlet var titleLabel: UILabel?;
    @IBOutlet var artistLabel: UILabel?;
    @IBOutlet var imageView: UIImageView?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        kvo.observe(PlaybackController.sharedInstance(), keyPath: "currentConcertion.currentTrack", options: NSKeyValueObservingOptions.Initial) { (observer, object, change) -> () in
            print(change)
            self.track = PlaybackController.sharedInstance().currentConcertion.currentTrack
        }
        self.track = PlaybackController.sharedInstance().currentConcertion.currentTrack
    }
    
    func updateNowPlaying() -> Void {
        if self.track == nil {
            return
        }
        self.titleLabel?.text = self.track?.title
        self.artistLabel?.text = self.track?.artistName
        
        if let imageView = self.imageView {
            UIImage.fetch(self.track!.imageURL!) { (image) in
                self.imageView!.image = image
                let fade = CATransition()
                fade.type = kCATransitionFade
                self.imageView!.layer.addAnimation(fade, forKey: "transition")
            }
        }
    }
}