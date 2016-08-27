//
//  VideoPlayerViewController.swift
//  CustomAVPlayer
//
//  Created by Jake Young on 8/27/16.
//  Copyright © 2016 Jake Young. All rights reserved.
//  Code from the tutorial at http://binarymosaic.com/custom-video-player-for-ios-with-avfoundation/

import UIKit
import AVFoundation


// MARK: - Selector Syntax Sugar
extension Selector {
    
    // Toggle Playback
    static let invisibleButtonTapped = #selector(VideoPlayerViewController.invisibleButtonTapped)
    
    // Seeking
    static let sliderBeganTracking = #selector(VideoPlayerViewController.sliderBeganTracking(slider:))
    static let sliderEndedTracking = #selector(VideoPlayerViewController.sliderEndedTracking(slider:))
    static let sliderValueChanged = #selector(VideoPlayerViewController.sliderValueChanged(slider:))
}

class VideoPlayerViewController: UIViewController {
    

    // Playback
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    // Control Layout
    let controlsHeight: CGFloat = 30.0
    
    // Controlling Playback
    let invisibleButton = UIButton()
    
    // Displaying Footage Time
    var timeObserver: Any!
    let timeRemainingLabel = UILabel()
    let timeElapsedLabel = UILabel()
    
    // Seeking
    let seekSlider = UISlider()
    var playerRateBeforeSeek: Float = 0 {
        didSet {
            print(playerRateBeforeSeek)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        // An AVPlayerLayer is a CALayer instance to which the AVPlayer can
        // direct its visual output. Without it, the user will see nothing.
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        // Add the button on top of the video view
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: .invisibleButtonTapped, for: .touchUpInside)
        
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
        timeRemainingLabel.textAlignment = .center
        view.addSubview(timeRemainingLabel)
        
        timeElapsedLabel.textColor = .white
        timeElapsedLabel.textAlignment = .center
        view.addSubview(timeElapsedLabel)

        
        // The Seeking Scrubber
        view.addSubview(seekSlider)
        
        seekSlider.addTarget(self, action: .sliderBeganTracking, for: .touchDown)
        seekSlider.addTarget(self, action: .sliderEndedTracking, for: [.touchUpInside, .touchUpOutside])
        seekSlider.addTarget(self, action: .sliderValueChanged, for: .valueChanged)
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
        let controlsY = view.bounds.size.height - controlsHeight
        timeRemainingLabel.frame = CGRect(x: view.bounds.size.width - controlEdgePadding - 60, y: controlsY, width: 60, height: controlsHeight)
        
        timeElapsedLabel.frame = CGRect(x: controlEdgePadding, y: controlsY, width: 60, height: controlsHeight)
        
        // Setup the slider control for seeking
        seekSlider.frame = CGRect(x: timeElapsedLabelRightEdgePostion, y: controlsY, width: sliderWidth, height: controlsHeight)
    }
    
    private var controlEdgePadding: CGFloat {
        return 5.0
    }
    
    private var sliderWidth: CGFloat {
        return view.bounds.size.width - timeRemainingLabel.bounds.size.width - controlEdgePadding - timeElapsedLabel.bounds.size.width - controlEdgePadding
    }
    
    // Force the view into landscape mode (which is how most video media is consumed.)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

}


// MARK: - Layout Helpers
extension VideoPlayerViewController {
    
    var timeElapsedLabelRightEdgePostion: CGFloat {
        return timeElapsedLabel.frame.origin.x + timeElapsedLabel.bounds.size.width
    }
    
    var timeRemainingLabelRightEdgePostion: CGFloat {
        return timeRemainingLabel.frame.origin.x + timeRemainingLabel.bounds.size.width
    }
    
    var timeRemainingLabelLeftEdgePostion: CGFloat {
        return timeRemainingLabel.frame.origin.x
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
    
    internal func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = videoDuration - elapsedTime
        
        timeElapsedLabel.text = String(format: "%02d:%02d", ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
        
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        seekSlider.setValue(progress(elapsedTime: elapsedTime), animated: true)
    }
    
    internal func observeTime(elapsedTime: CMTime) {
        if videoDuration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        }
    }
}


// MARK: - Seeking
extension VideoPlayerViewController {
    
    func progress(elapsedTime: Float64) -> Float {
        let timeRemaining = videoDuration - elapsedTime
        return Float(elapsedTime / videoDuration)
    }
    
    var videoDuration: Float64 {
        return CMTimeGetSeconds(avPlayer.currentItem!.duration)
    }
    
    /// React when the slider began seeking
    ///
    /// - parameter slider: The slider control for the video.
    func sliderBeganTracking(slider: UISlider) {
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    
    /// React when the slider stopped seeking
    ///
    /// - parameter slider: The slider control for the video.
    func sliderEndedTracking(slider: UISlider) {
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
            if self.playerRateBeforeSeek > 0 {
                self.avPlayer.play()
            }
        }
    }
    
    
    /// React when the slider value changed
    ///
    /// - parameter slider: The slider control for the video.
    func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
    }
    
}
