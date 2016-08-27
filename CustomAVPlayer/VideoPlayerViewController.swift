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

    // Playback
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    // Controlling Playback
    let invisibleButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        // Add the button on top of the video view
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(invisibleButtonTapped), for: .touchUpInside)
        
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
        
        // We're adding a button that is over the whole screen
        // You might want to handle this with gesture recognizers
        // or format this in a branded / visible way.
        invisibleButton.frame = view.bounds
    }
    
    // Force the view into landscape mode (which is how most video media is consumed.)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

}


extension VideoPlayerViewController {
    
    private var playerIsPlaying: Bool {
        return avPlayer.rate > 0
    }
    
    func invisibleButtonTapped(sender: UIButton) {
        playerIsPlaying ? avPlayer.pause() : avPlayer.play()
    }
}
