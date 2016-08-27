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
    
    // Displaying Footage Time
    var timeObserver: Any!
    let timeRemainingLabel = UILabel()
    
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
        
        // Add the Time Observer
        // Samples each second
        let timeInterval = CMTimeMakeWithSeconds(1.0, 10) // Once every second
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: .main, using: { elapsedTime in
            self.observeTime(elapsedTime: elapsedTime)
        })
        
        // Add the time observer label to the view
        timeRemainingLabel.textColor = .white
        view.addSubview(timeRemainingLabel)
    }
    
    deinit {
        // Get rid of this observer when the view is deinitialized
        avPlayer.removeTimeObserver(timeObserver)
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
        
        // Setup the Time label's formatting
        let controlsHeight: CGFloat = 30.0
        let controlsY = view.bounds.size.height - controlsHeight
        timeRemainingLabel.frame = CGRect(x: 5, y: controlsY, width: 60, height: controlsHeight)
    }
    
    // Force the view into landscape mode (which is how most video media is consumed.)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

}


// MARK: - Playing and Pausing
extension VideoPlayerViewController {
    
    private var playerIsPlaying: Bool {
        return avPlayer.rate > 0
    }
    
    func invisibleButtonTapped(sender: UIButton) {
        playerIsPlaying ? avPlayer.pause() : avPlayer.play()
    }
}


// MARK: - Updating the Time Label
extension VideoPlayerViewController {
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
    }
    
    internal func observeTime(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        if duration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
        }
    }
}
