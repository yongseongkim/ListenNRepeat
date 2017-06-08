//
//  PlayerViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController {
    //MARK: Constants
    static let waveformPlotRatio = 20
    
    //MARK: IB Properties
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsTextView: UITextView!
    
    @IBOutlet weak var timeSliderTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeSliderDurationLabel: UILabel!
    
    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSeparateViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var repeatModeButton: UIButton!
    @IBOutlet weak var repeatBookmarkButton: UIButton!
    @IBOutlet weak var volumeView: AudioVolumeView!
    @IBOutlet weak var rateButton: UIButton!

    // Properties
    fileprivate var player: Player
    fileprivate var timer: Timer?
    fileprivate var scrollViewDragging = false
    fileprivate var playingWhenScrollStart = false
    fileprivate var scrollViewDecelerate = false
    fileprivate var bookmarkViews: [UIView]?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.player = Dependencies.sharedInstance().resolve(serviceType: Player.self)!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AppDelegate.currentAppDelegate()?.notificationCenter.removeObserver(self)
        self.player.notificationCenter.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.waveformView.delegate = self
        self.timeSeparateViewWidthConstraint.constant = UIScreen.scaleWidth
        self.timeSlider.setThumbImage(UIImage.size(width: 3, height: 16).color(UIColor.greenery).image, for: .normal)
        self.timeSlider.setMinimumTrackImage(UIImage.size(width: self.timeSlider.bounds.width, height: 3).color(UIColor.greenery).image, for: .normal)
        self.timeSlider.setMaximumTrackImage(UIImage.size(width: self.timeSlider.bounds.width, height: 3).color(UIColor.gray220).image, for: .normal)
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayerItemDidSet(object:)), name: Notification.Name.playerItemDidSet, object: nil)
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayerStateUpdatedNotification), name: Notification.Name.playerStateUpdated, object: nil)
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayingTimeUpdatedNotification), name: Notification.Name.playerTimeUpdated, object: nil)
        self.player.notificationCenter.addObserver(self, selector: #selector(handleBookmarkUpdatedNotification), name: Notification.Name.playerBookmakrUpdated, object: nil)
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.contentViewTopConstraint.constant != self.topLayoutGuide.length {
            self.contentViewTopConstraint.constant = self.topLayoutGuide.length
        }
    }

    // MARK - Private
    func enterForeground() {
        self.setup()
    }
    
    fileprivate func setup() {
        guard let item = self.player.currentItem else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.titleLabel.text = item.title ?? item.url?.lastPathComponent
        self.artistNameLabel.text = item.artist ?? "Unknown Artist"
        self.albumCoverImageView.image = item.artwork
        self.lyricsTextView.text = item.lyrics
        self.loadWavefromIfNecessary(item: item)
//        self.loadBookmarks(duration: self.player.duration)
        let duration = self.player.duration
        let minutes = Int(duration/60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        self.timeSliderDurationLabel.text = String(format: "%02d:%02d", minutes, seconds)
        self.durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
        self.setupButtons()
    }
    
    fileprivate func loadWavefromIfNecessary(item: PlayerItem) {
        guard let url = item.url else { return }
        if url.absoluteString == self.waveformView.url?.absoluteString {
            return
        }
        self.waveformView.loadWaveform(url: url)
    }
    
    fileprivate func loadBookmarks(duration: Double) {
//        self.bookmarkViews?.forEach({ (view) in
//            return view.removeFromSuperview()
//        })
//        self.bookmarkViews = [UIView]()
//        for time in self.player.bookmarkTimes {
//            let ratio = time / duration
//            let waveContainerSize = self.waveformView.contentSize
//            let view = UIView(frame: CGRect(x: Double(waveContainerSize.width).multiplied(by: ratio).subtracting(0.5), y: 0, width: 1, height: Double(waveContainerSize.height)))
//            view.backgroundColor = UIColor.directoireBlue
//            self.waveformView.addSubview(view)
//            self.bookmarkViews?.append(view)
//        }
    }
    
    fileprivate func setupButtons() {
        let state = self.player.state
        if state.isPlaying {
            self.playButton.setTitle("Pause", for: .normal)
        } else {
            self.playButton.setTitle("Play", for: .normal)
        }
        self.rateButton.setTitle(String(format: "x%.1f", state.rate), for: .normal)
        switch state.repeatMode {
        case .All:
            self.repeatModeButton.setTitle("Repeat All", for: .normal)
            break
        case .One:
            self.repeatModeButton.setTitle("Repeat One", for: .normal)
            break
        case .None:
            self.repeatModeButton.setTitle("None", for: .normal)
            break
        }
    }
    
    // MARK - Notification Handling
    func handlePlayerItemDidSet(object: Notification) {
        self.setup()
    }
    
    func handlePlayerStateUpdatedNotification() {
        self.setupButtons()
    }
    
    func handlePlayingTimeUpdatedNotification() {
        if (self.scrollViewDragging) {
            return
        }
        var progress: Double = 0
        if self.player.duration != 0 {
            progress = self.player.currentTime / self.player.duration
        }
        self.waveformView.move(progress: progress)
        self.timeSlider.value = Float(progress)
        self.timeSlider.sendActions(for: .valueChanged)
    }
    
    func handleBookmarkUpdatedNotification() {
        self.loadBookmarks(duration: self.player.duration)
    }
    
    
    // MARK - IB Actions
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func timeSliderValueChanged(_ sender: Any) {
        let current = Double(self.timeSlider.value) * self.player.duration
        let minutes = Int(abs(current/60))
        let seconds = Int(abs(current.truncatingRemainder(dividingBy: 60)))
        self.timeSliderTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func timeSliderTouchDown(_ sender: Any) {
        self.playingWhenScrollStart = self.player.state.isPlaying
        self.player.pause()
    }
    
    @IBAction func timeSliderTouchUpInside(_ sender: Any) {
        self.player.move(to: Double(self.timeSlider.value) * self.player.duration)
        if (self.playingWhenScrollStart) {
            self.player.resume()
        }
    }
    
    @IBAction func timeSliderTouchUpOutside(_ sender: Any) {
        self.player.move(to: Double(self.timeSlider.value) * self.player.duration)
        if (self.playingWhenScrollStart) {
            self.player.resume()
        }
    }
    
    @IBAction func showBookmarksButtonTapped(_ sender: Any) {
        let bookmarksViewController = AudioBookmarksViewController(nibName: AudioBookmarksViewController.className(), bundle: nil)
        bookmarksViewController.modalPresentationStyle = .custom
        self.present(bookmarksViewController, animated: true, completion: nil)
    }
    
    @IBAction func movePreviousBookmark(_ sender: Any) {
        self.player.movePreviousBookmark()
    }
    
    @IBAction func moveStartCurrentBookmark(_ sender: Any) {
        self.player.moveLatestBookmark()
    }
    
    @IBAction func moveNextBookmark(_ sender: Any) {
        self.player.moveNextBookmark()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if self.player.state.isPlaying {
            self.player.pause()
        } else {
            self.player.resume()
        }
    }
    
    @IBAction func moveBefore5SecondsButtonTapped(_ sender: Any) {
        self.player.moveBackward(seconds: 5)
    }
    
    @IBAction func moveBefore2SecondsButtonTapped(_ sender: Any) {
        self.player.moveBackward(seconds: 3)
    }
    
    @IBAction func moveBefore1SecondsButtonTapped(_ sender: Any) {
        self.player.moveBackward(seconds: 1)
    }
    
    @IBAction func moveAtStartButtonTapped(_ sender: Any) {
        self.player.move(to: 0)
    }
    
    @IBAction func moveAfter5SecondsButtonTapped(_ sender: Any) {
        self.player.moveForward(seconds: 5)
    }
    
    @IBAction func moveAfter10SecondsButtonTapped(_ sender: Any) {
        self.player.moveForward(seconds: 10)
    }
    
    @IBAction func playNextButtonTapped(_ sender: Any) {
        self.player.playNext()
    }
    
    @IBAction func playPreviousButtonTapped(_ sender: Any) {
        self.player.playPrev()
    }
    
    @IBAction func repeatModeButtonTapped(_ sender: Any) {
        self.player.nextRepeatMode()
    }
    
    @IBAction func repeatBookmarkButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addBookmarkButtonTapped(_ sender: Any) {
        do {
            try self.player.addBookmark()
        } catch PlayerError.alreadExistBookmarkNearby {
            print("already exist nearby")
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        self.player.nextRate()
    }
    
    @IBAction func lyricsButtonTapped(_ sender: Any) {
        self.lyricsView.isHidden = false
    }
    
    @IBAction func lyricsViewTapped(_ sender: Any) {
        self.lyricsView.isHidden = true
    }
}

extension PlayerViewController: WaveformViewDelegate {
    func waveformViewDidScroll(scrollView: UIScrollView) {
        var progress: Double = 0
        if (scrollView.contentSize.width > 0) {
            progress = Double((scrollView.contentOffset.x + scrollView.contentInset.left) / scrollView.contentSize.width)
        }
        let current = progress * self.player.duration
        let minutes = Int(abs(current/60))
        let seconds = Int(abs(current.truncatingRemainder(dividingBy: 60)))
        let millis = Int(abs((current * 10).truncatingRemainder(dividingBy: 10)))
        var format = "%02d:%02d.%d"
        if current < 0 {
            format = "-%02d:%02d.%d"
        }
        self.timeLabel.text = String(format: format, minutes, seconds, millis)
    }
    
    func waveformViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollViewDragging = true
        if (self.scrollViewDecelerate) {
            return
        }
        self.playingWhenScrollStart = self.player.state.isPlaying
        self.player.pause()
    }
    
    func waveformViewDidEndDragging(_ scrollView: UIScrollView, decelerate: Bool) {
        self.scrollViewDragging = false
        self.scrollViewDecelerate = decelerate
        if (!decelerate) {
            self.waveformViewDidEndDecelerating(scrollView: scrollView)
        }
    }
    
    func waveformViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollViewDecelerate = false
        let progress = Double((scrollView.contentInset.left + scrollView.contentOffset.x) / scrollView.contentSize.width)
        self.player.move(to: progress * self.player.duration)
        if (self.playingWhenScrollStart) {
            self.player.resume()
        }
    }
}
