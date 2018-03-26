//
//  MultiVideoPlayerViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

fileprivate extension UIInterfaceOrientation {
    init?(stringValue: String) {
        switch stringValue {
        case "UIInterfaceOrientationPortrait":
            self = .portrait
        case "UIInterfaceOrientationPortraitUpsideDown":
            self = .portraitUpsideDown
        case "UIInterfaceOrientationLandscapeLeft":
            self = .landscapeLeft
        case "UIInterfaceOrientationLandscapeRight":
            self = .landscapeRight
        default:
            return nil
        }
    }
}

/// The multi video player view controller is responsible for displaying new style videos in Storm.
///
/// Multi video players can take an array of videos and display the correct video for the current user's language.
///
/// Users also have the ability to change the language of their video manually
@objc(TSCMultiVideoPlayerViewController)
open class MultiVideoPlayerViewController: UIViewController {
	
	fileprivate var player: AVPlayer?
	
	private var videoPlayerLayer: AVPlayerLayer?
	
	private var retryYouTubeLink: StormLink?
	
	private var dontReload = false
	
	fileprivate var languageSwitched = false
	
	private var originalBarTintColor: UIColor?
	
	private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
	
	private let videos: [Video]
	
	private let playerControlsView: VideoPlayerControlsView = VideoPlayerControlsView()
	
	private let videoScrubView: TSCVideoScrubViewController = TSCVideoScrubViewController()

	/// Initialises the video player with an array of available videos
	///
	/// - Parameter videos: The videos which are available from storm
	public init(videos: [Video]) {
		
		self.videos = videos
		
		super.init(nibName: nil, bundle: nil)
		
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done".localised(with: "_STORM_VIDEOPLAYER_NAVIGATION_LEFT"), style: .plain, target: self, action: #selector(finishVideo))
		
		originalBarTintColor = UINavigationBar.appearance().barTintColor
		let navigationBar = UINavigationBar.appearance()
		navigationBar.barTintColor = UIColor(red: 74/255, green: 75/255, blue: 77/255, alpha: 1)
		
		playerControlsView.playButton.addTarget(self, action: #selector(playPause(sender:)), for: .touchUpInside)
		playerControlsView.languageButton?.addTarget(self, action: #selector(changeLanguage(sender:)), for: .touchUpInside)
		
		videoScrubView.videoProgressTracker.addTarget(self, action: #selector(progressSliderChanged(sender:)), for: .valueChanged)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		videos = []
		super.init(coder: aDecoder)
	}
	
	//MARK: -
	//MARK: View Controller Lifecycle
	//MARK: -
	
	override open func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if languageSwitched {
			return
		}
		
		// Try and find a video with the correct locale, falling back to the first video
		let video = videos.first(where: { (video) -> Bool in
			
			guard let locale = video.locale, let link = video.link, locale == StormLanguageController.shared.currentLocale  else {
				return false
			}
			
			switch link.linkClass {
				case .external:
					return true
				case .internal:
					return ContentController.shared.url(forCacheURL: link.url) != nil
				default:
					return true
			}

		}) ?? videos.first

		
		guard video != nil else { return }
		play(video: video!)
	}
	
	override open func viewDidLoad() {
		
		super.viewDidLoad()
		
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleBars)))
		view.backgroundColor = .black
		view.addSubview(playerControlsView)
		
		activityIndicator.frame = CGRect(x: 200, y: 200, width: 20, height: 20)
		activityIndicator.center = view.center
		view.addSubview(activityIndicator)
		
		activityIndicator.startAnimating()
	}
	
	override open func viewWillLayoutSubviews() {
		
		super.viewWillLayoutSubviews()
		
		videoPlayerLayer?.frame = view.bounds
		let orientation = UIApplication.shared.statusBarOrientation
		
		if UIInterfaceOrientationIsPortrait(orientation) {
			
			playerControlsView.frame = CGRect(x: 0, y: view.frame.height - 80, width: view.frame.width, height: 80)
			videoScrubView.frame = CGRect(x: navigationItem.titleView?.frame.minX ?? 0, y: navigationItem.titleView?.frame.minY ?? 0, width: 210, height: 44)
			
		} else {
			
			view.bringSubview(toFront: playerControlsView)
			playerControlsView.frame = CGRect(x: 0, y: view.frame.height - 40, width: view.frame.width, height: 40)
			videoScrubView.frame = CGRect(x: navigationItem.titleView?.frame.minX ?? 0, y: navigationItem.titleView?.frame.minY ?? 0, width: 400, height: 44)
		}
	}
	
	override open func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		UINavigationBar.appearance().barTintColor = originalBarTintColor
		if isBeingDismissed {
			player = nil
			videoPlayerLayer?.removeFromSuperlayer()
		}
        
        // If we can't get the supported orientations rotate away as we don't want to make any assumptions
        guard let supportedOrientationStrings = Bundle.main.infoDictionary?["UISupportedInterfaceOrientations"] as? [String] else {
            rotateDeviceToPortrait()
            return
        }
        
        // If we don't get the same number of enum's as we do the original strings we don't want to assume anything about orientationss
        let supportedOrientations = supportedOrientationStrings.flatMap({ UIInterfaceOrientation(stringValue: $0) })
        guard supportedOrientations.count == supportedOrientationStrings.count else {
            rotateDeviceToPortrait()
            return
        }
		
        guard !supportedOrientations.contains(UIApplication.shared.statusBarOrientation) else {
            return
        }
        
		rotateDeviceToPortrait()
	}
    
    private func rotateDeviceToPortrait() {
        
    }
	
	//MARK: -
	//MARK: Helper Functions
	//MARK: -
	
	@objc private func timeoutVideoLoad() {
		dontReload = true
	}
	
	fileprivate func play(video: Video) {
		
		guard let videoLink = video.link else {
			dismissAnimated()
			return
		}
		
		switch videoLink.linkClass {
			case .external:
				loadYouTubeVideo(for: videoLink)
				NotificationCenter.default.sendStatEventNotification(category: "Video", action: "YouTube - \(videoLink.url?.absoluteString ?? "Unknown")", label: nil, value: nil, object: self)
				break
			case .internal:
				guard let path =  ContentController.shared.url(forCacheURL: videoLink.url) else {
					dismissAnimated()
					return
				}
				NotificationCenter.default.sendStatEventNotification(category: "Video", action: "Local - \(videoLink.title ?? "Unknown")", label: nil, value: nil, object: self)
				playVideo(at: path)
				break
			default:
				return
		}
	}
	
	private func playVideo(at url: URL) {
		
		// Delete the old player and layer
		player = nil
		videoPlayerLayer = nil
		
		player = AVPlayer(url: url)
		player?.volume = 0.5
		videoPlayerLayer = AVPlayerLayer(player: player!)
		videoPlayerLayer?.videoGravity = .resizeAspect
		videoPlayerLayer?.frame = view.bounds
		
		view.layer.sublayers?.forEach({ (layer) in
			guard let playerLayer = layer as? AVPlayerLayer else { return }
			playerLayer.removeFromSuperlayer()
		})
		
		view.layer.addSublayer(videoPlayerLayer!)
		player?.play()
		
		let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		
		player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
			
			guard let welf = self, let player = welf.player, let currentItem = player.currentItem else { return }
			
			let endTime = CMTimeConvertScale(currentItem.asset.duration, player.currentTime().timescale, .roundHalfAwayFromZero)
			
			if CMTimeCompare(endTime, kCMTimeZero) != 0 {
				
				// Time progressed
				let timeProgressed: TimeInterval = CMTimeGetSeconds(player.currentTime())
				
				let formatter = DateComponentsFormatter()
				formatter.unitsStyle = .positional
				formatter.allowedUnits = [ .minute, .second ]
				formatter.zeroFormattingBehavior = [ .pad ]
				
				welf.videoScrubView.currentTimeLabel.text = formatter.string(from: timeProgressed)
				
				// End time
				if CMTimeCompare(kCMTimeZero, currentItem.duration) != 0 {
					let totalTime: TimeInterval = CMTimeGetSeconds(currentItem.duration)
					if !totalTime.isNaN {
						welf.videoScrubView.endTimeLabel.text = formatter.string(from: totalTime)
					}
				}
				welf.videoScrubView.videoProgressTracker.maximumValue = Float(CMTimeGetSeconds(currentItem.asset.duration))
				welf.videoScrubView.videoProgressTracker.value = Float(timeProgressed)
			}
		})
	}
	
	private func loadYouTubeVideo(for link: StormLink) {
		
		guard let url = link.url else {
			dismissAnimated()
			print("[MultiVideoPlayerViewController] No url present on YouTube link!")
			return
		}
		
		YouTubeController.loadVideo(for: url) { [weak self] (youtubeURL, error) in
			
			guard let strongSelf = self else { return }
			
			guard let youtubeURL = youtubeURL else {
				
				if let controllerError = error as? YouTubeControllerError {
					
					switch controllerError {
					case .responseDataInvalid:
						fallthrough
					case .invalidURL:
						fallthrough
					case .failedCreatingURLComponents:
						fallthrough
					case .failedConstructingURL:
                        OperationQueue.main.addOperation {
                            strongSelf.dismissAnimated()
                        }
						return
					case .noStreamMapFound:
						fallthrough
					case .noValidQualityFound:
						fallthrough
					case .finalURLInvalid:
						fallthrough
					case .responseDataTooShort:
						
						strongSelf.retryYouTubeLink = link
						
						if strongSelf.dontReload {
                            OperationQueue.main.addOperation {
                                strongSelf.showRetryAlert()
                            }
						} else {
							strongSelf.loadYouTubeVideo(for: link)
						}
						
						return
					}
					
				} else {
					
					strongSelf.retryYouTubeLink = link
					
					if strongSelf.dontReload {
                        OperationQueue.main.addOperation {
                            strongSelf.showRetryAlert()
                        }
					} else {
						strongSelf.loadYouTubeVideo(for: link)
					}
				}
				
				return
			}
			
			OperationQueue.main.addOperation {
				strongSelf.playVideo(at: youtubeURL)
			}
		}
	}
	
	private func showRetryAlert() {
		
		let unableToPlayAlert = UIAlertController(
			title: "An error has occured".localised(with: "_STORM_VIDEOPLAYER_ERROR_TITLE"),
			message: "Sorry, we are unable to play this video. Please try again".localised(with: "_STORM_VIDEOPLAYER_ERROR_MESSAGE"),
			preferredStyle: .alert
		)
		
		unableToPlayAlert.addAction(UIAlertAction(
			title: "Okay".localised(with: "_STORM_VIDEOPLAYER_ERROR_BUTTON_OKAY"),
			style: .cancel,
			handler: nil)
		)
		
		unableToPlayAlert.addAction(UIAlertAction(
			title: "Retry".localised(with: "_STORM_VIDEOPLAYER_ERROR_BUTTON_RETRY"),
			style: .default,
			handler: { (action) in
				
				Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.timeoutVideoLoad), userInfo: nil, repeats: false)
				guard let retryLink = self.retryYouTubeLink else {
					return
				}
				self.loadYouTubeVideo(for: retryLink)
			}
		))
		
		present(unableToPlayAlert, animated: true, completion: nil)
	}
	
	//MARK: -
	//MARK: Action Handlers
	//MARK: -
	@objc private func finishVideo() {
		player?.pause()
		dismissAnimated()
	}
	
	@objc private func playPause(sender: UIButton) {
		
		guard let player = player else { return }
		
		let bundle = Bundle(for: MultiVideoPlayerViewController.self)
		
		if player.rate == 0 {
			let image = UIImage(named: "mediaPauseButton", in: bundle, compatibleWith: nil)
			sender.setImage(image, for: .normal)
			player.play()
		} else {
			let image = UIImage(named: "mediaPlayButton", in: bundle, compatibleWith: nil)
			sender.setImage(image, for: .normal)
			player.pause()
		}
	}
	
	@objc private func changeLanguage(sender: UIButton) {
		
		let selectLanguageViewController = VideoLanguageSelectionViewController(videos: videos)
		selectLanguageViewController.videoSelectionDelegate = self
		
		let navController = UINavigationController(rootViewController: selectLanguageViewController)
		present(navController, animated: true, completion: nil)
	}
	
	@objc private func toggleBars() {
		
		guard let navController = navigationController else { return }
		
		let barHidden = navController.isNavigationBarHidden
		navController.setNavigationBarHidden(!barHidden, animated: true)
		playerControlsView.isHidden = !barHidden
	}
	
	@objc private func progressSliderChanged(sender: UISlider) {
		player?.seek(to: CMTimeMake(Int64(sender.value), 1))
	}
}


//MARK: -
//MARK: VideoLanguageSelectionViewControllerDelegate
//MARK: -
extension MultiVideoPlayerViewController: VideoLanguageSelectionViewControllerDelegate {
	
	public func selectionViewController(viewController: VideoLanguageSelectionViewController, didSelect video: Video) {
		
		languageSwitched = true
		dontReload = false
		player?.pause()
		viewController.dismissAnimated()
		play(video: video)
	}
}
