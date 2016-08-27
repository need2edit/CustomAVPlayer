//
//  VideoPlayerViewController.swift
//  CustomAVPlayer
//
//  Created by Jake Young on 8/27/16.
//  Copyright © 2016 Jake Young. All rights reserved.
//  Code from the tutorial at http://binarymosaic.com/custom-video-player-for-ios-with-avfoundation/

import UIKit
import AVFoundation

class VideoPlayerViewController: UIViewController {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        let url = URL(string: "https://content.jwplatform.com/manifests/vM7nH0Kl.m3u8")
        let playerItem = AVPlayerItem(url: url!)
        avPlayer.replaceCurrentItem(with: playerItem)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avPlayer.play() // Start the playback
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Layout subviews manually
        avPlayerLayer.frame = view.bounds
    }
    
    // Force the view into landscape mode (which is how most video media is consumed.)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

}
