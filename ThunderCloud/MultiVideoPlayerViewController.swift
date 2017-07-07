//
//  MultiVideoPlayerViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

/// The multi video player view controller is responsible for displaying new style videos in Storm.
///
/// Multi video players can take an array of videos and display the correct video for the current user's language.
///
/// Users also have the ability to change the language of their video manually
@objc(TSCMultiVideoPlayerViewController)
open class MultiVideoPlayerViewController: UIViewController {
	
	fileprivate var player: AVPlayer?
	
	private var videoPlayerLayer: AVPlayerLayer?
	
	private var retryYouTubeLink: TSCLink?
	
	private var dontReload = false
	
	fileprivate var languageSwitched = false
	
	private var originalBarTintColor: UIColor?
	
	private let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
	
	private let videos: [Video]
	
	private let playerControlsView: TSCVideoPlayerControlsView = TSCVideoPlayerControlsView()
	
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
		playerControlsView.languageButton.addTarget(self, action: #selector(changeLanguage(sender:)), for: .touchUpInside)
		
		videoScrubView.videoProgressTracker.addTarget(self, action: #selector(progressSliderChanged(sender:)), for: .valueChanged)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	//MARK: -
	//MARK: View Controller Lifecycle
	//MARK: -
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if languageSwitched {
			return
		}
		
		// Try and find a video with the correct locale, falling back to the first video
		let video = videos.first(where: { (video) -> Bool in
			
			guard let locale = video.videoLocale, let link = video.videoLink, locale == TSCStormLanguageController.shared().currentLocale()  else {
				return false
			}
			guard let videoLinkClass = link.linkClass else { return false }
			
			switch videoLinkClass {
				case "ExternalLink":
					return true
				case "InternalLink":
					return ContentController.shared.url(forCacheURL: link.url) != nil
				default:
					return false
			}
		}) ?? videos.first

		
		guard let _video = video else { return }
		play(video: _video)
	}
	
	open override func viewDidLoad() {
		
		super.viewDidLoad()
		
		view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleBars)))
		view.backgroundColor = .black
		view.addSubview(playerControlsView)
		
		activityIndicator.frame = CGRect(x: 200, y: 200, width: 20, height: 20)
		activityIndicator.center = view.center
		view.addSubview(activityIndicator)
		
		activityIndicator.startAnimating()
	}
	
	open override func viewWillLayoutSubviews() {
		
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
	
	open override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		UINavigationBar.appearance().barTintColor = originalBarTintColor
	}
	
	//MARK: -
	//MARK: Helper Functions
	//MARK: -
	
	@objc private func timeoutVideoLoad() {
		dontReload = true
	}
	
	fileprivate func play(video: Video) {
		
		guard let videoLink = video.videoLink, let videoLinkClass = videoLink.linkClass else {
			return
		}
		
		switch videoLinkClass {
			case "ExternalLink":
				loadYouTubeVideo(for: videoLink)
				NotificationCenter.default.sendStatEventNotification(category: "Video", action: "YouTube - \(videoLink.url?.absoluteString ?? "Unknown")", value: nil, object: self)
				break
			case "InternalLink":
				guard let path =  ContentController.shared.url(forCacheURL: videoLink.url) else {
					return
				}
				NotificationCenter.default.sendStatEventNotification(category: "Video", action: "Local - \(videoLink.title ?? "Unknown")", value: nil, object: self)
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
		videoPlayerLayer?.videoGravity = AVLayerVideoGravityResizeAspect
		
		view.layer.sublayers?.forEach({ (layer) in
			guard let playerLayer = layer as? AVPlayerLayer else { return }
			playerLayer.removeFromSuperlayer()
		})
		
		view.layer.addSublayer(videoPlayerLayer!)
		player?.play()
		
		let interval = CMTime(seconds: 33, preferredTimescale: 1000)
		
		player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
			
			guard let welf = self, let _player = welf.player, let currentItem = _player.currentItem else { return }
			
			let endTime = CMTimeConvertScale(currentItem.asset.duration, _player.currentTime().timescale, .roundHalfAwayFromZero)
			
			if CMTimeCompare(endTime, kCMTimeZero) != 0 {
				
				// Time progressed
				let timeProgressed: TimeInterval = CMTimeGetSeconds(_player.currentTime())
				
				let formatter = DateComponentsFormatter()
				formatter.unitsStyle = .positional
				formatter.allowedUnits = [ .minute, .second ]
				formatter.zeroFormattingBehavior = [ .pad ]
				
				welf.videoScrubView.currentTimeLabel.text = formatter.string(from: timeProgressed)
				
				// End time
				let totalTime: TimeInterval = CMTimeGetSeconds(currentItem.duration)
				welf.videoScrubView.endTimeLabel.text = formatter.string(from: totalTime)
				welf.videoScrubView.videoProgressTracker.maximumValue = Float(CMTimeGetSeconds(currentItem.asset.duration))
				welf.videoScrubView.videoProgressTracker.value = Float(timeProgressed)
			}
		})
	}
	
	private func loadYouTubeVideo(for link: TSCLink) {
		
		guard let url = link.url, let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			print("[MultiVideoPlayerViewController] No url present on YouTube link!")
			return
		}
		
		// Extract youtube video id
		guard let youtubeId = urlComponents.queryItems?.first(where: { (queryItem) -> Bool in
			return queryItem.name == "v"
		})?.value else {
			print("[MultiVideoPlayerViewController] No video id present on YouTube link!")
			return
		}
		
		var youtubeURLComponents = URLComponents()
		youtubeURLComponents.scheme = "https"
		youtubeURLComponents.host = "www.youtube.com"
		youtubeURLComponents.path = "/get_video_info"
		
		let videoQuery = URLQueryItem(name: "video_id", value: youtubeId)
		youtubeURLComponents.queryItems = [videoQuery]
		
		guard let youtubeURL = youtubeURLComponents.url else {
			print("[MultiVideoPlayerViewController] Couldn't construct link for YouTube video \(youtubeId)!")
			return
		}
		
		let downloadRequest = URLRequest(url: youtubeURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
		let session = URLSession.shared
		let dataTask = session.dataTask(with: downloadRequest) { [weak self] (data, response, error) in
			
			guard let welf = self else { return }
			guard let _data = data, _data.count >= 200 else {
				
				welf.retryYouTubeLink = link
				
				if welf.dontReload {
					welf.showRetryAlert()
				} else {
					welf.loadYouTubeVideo(for: link)
				}
				return
			}
			
			// Convert response to string
			guard let responseString = String(data: _data, encoding: .utf8) else {
				print("[MultiVideoPlayerViewController] YouTube video info not convertable to string")
				return
			}
			
			// Break the response into an array by ampersand
			let stringParts = responseString.components(separatedBy: "&")
			
			// Find the part that contains video info
			let streamMapPart = stringParts.first(where: { (part) -> Bool in
				return part.contains("url_encoded_fmt_stream_map")
			})
			
			// Break that part by comma to find video urls
			let streamParts = streamMapPart?.removingPercentEncoding?.replacingOccurrences(of: "url_encoded_fmt_stream_map", with: "").components(separatedBy: ",")
			
			guard let _streamParts = streamParts else {
				
				welf.retryYouTubeLink = link
				if welf.dontReload {
					welf.showRetryAlert()
				} else {
					welf.loadYouTubeVideo(for: link)
				}
				return
			}
			
			// For each stream part (Quality of video url)
			// Reduce the stream parts to a dictionary of quality to video information:
			//
			// [
			//    "medium": [
			//        "url": "www....",
			//        "sig": "signature"
			//    ]
			// ]
			let videoDictionary = _streamParts.reduce([AnyHashable : [AnyHashable : Any]](), { (previousVideos, streamPart) -> [AnyHashable : [AnyHashable : Any]] in
				
				// Map the streamparts components out like url parameters (&key=value&otherKey=otherValue) and convert to dictionary
				var dictionaryForQuality = streamPart.components(separatedBy: "&").reduce([AnyHashable : Any](), { (previous, videoPart) -> [AnyHashable : Any] in
					
					var next = previous
					let videoPartComponents = videoPart.components(separatedBy: "=")
					if videoPartComponents.count > 1 {
						next[videoPartComponents[0]] = videoPartComponents[1]
					}
					
					return next
				})
				
				// Seems the & before sig is sometimes URL encoded. If we haven't pulled it out already,
				// let's decode then pull it out
				if dictionaryForQuality["sig"] == nil, let decodedStreamPart = streamPart.removingPercentEncoding {
					
					let decodedUrlParts = decodedStreamPart.components(separatedBy: "&")
					for part in decodedUrlParts {
						let keyArray = part.components(separatedBy: "=")
						guard keyArray.count > 1, keyArray[0] == "sig" else {
							continue
						}
						dictionaryForQuality["sig"] = keyArray[1]
						break
					}
				}
				
				// If we have a quality then add it to the videos dictionary
				guard let quality = dictionaryForQuality["quality"] as? AnyHashable else {
					return previousVideos
				}
				
				var nextVideos = previousVideos
				nextVideos[quality] = dictionaryForQuality
				return nextVideos
			})
			
			// Check for video of certain quality
			var streamQuality: String?
			if videoDictionary["medium"] != nil {
				streamQuality = "medium"
			} else if videoDictionary["small"] != nil {
				streamQuality = "small"
			}
			
			guard let quality = streamQuality, let video = videoDictionary[quality], let url = video["url"] as? String, let sig = video["sig"] as? String, let videoString = "\(url)&signature=\(sig)".removingPercentEncoding, let videoURL = URL(string: videoString) else {
				
				welf.retryYouTubeLink = link
				if welf.dontReload {
					welf.showRetryAlert()
				} else {
					welf.loadYouTubeVideo(for: link)
				}
				return
			}
			
			welf.playVideo(at: videoURL)
		}
		
		dataTask.resume()
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
		
		guard let _player = player else { return }
		
		let bundle = Bundle(for: MultiVideoPlayerViewController.self)
		
		if _player.rate == 0 {
			let image = UIImage(named: "mediaPauseButton", in: bundle, compatibleWith: nil)
			sender.setImage(image, for: .normal)
			_player.play()
		} else {
			let image = UIImage(named: "mediaPlayButton", in: bundle, compatibleWith: nil)
			sender.setImage(image, for: .normal)
			_player.pause()
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
		player?.pause()
		viewController.dismissAnimated()
		play(video: video)
	}
}
