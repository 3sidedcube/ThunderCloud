//
//  YouTubeController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 11/10/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

public typealias YouTubeLoadCompletion = (_ url: URL?, _ error: Error?) -> Void

public struct YouTubeController {
	
	public static func loadVideo(for url: URL, with completion: YouTubeLoadCompletion?) {
		
		guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
			completion?(nil, YouTubeControllerError.failedCreatingURLComponents)
			return
		}
		
		// Extract youtube video id
		guard let youtubeId = urlComponents.queryItems?.first(where: { (queryItem) -> Bool in
			return queryItem.name == "v"
		})?.value else {
			completion?(nil, YouTubeControllerError.invalidURL)
			return
		}
		
		var youtubeURLComponents = URLComponents()
		youtubeURLComponents.scheme = "https"
		youtubeURLComponents.host = "www.youtube.com"
		youtubeURLComponents.path = "/get_video_info"
		
		let videoQuery = URLQueryItem(name: "video_id", value: youtubeId)
		youtubeURLComponents.queryItems = [videoQuery]
		
		guard let youtubeURL = youtubeURLComponents.url else {
			completion?(nil, YouTubeControllerError.failedConstructingURL)
			return
		}
		
		let downloadRequest = URLRequest(url: youtubeURL, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
		let session = URLSession.shared
		let dataTask = session.dataTask(with: downloadRequest) { (data, response, error) in
			
			if let error = error {
				completion?(nil, error)
				return
			}
			
			guard let data = data, data.count >= 200 else {
				completion?(nil, YouTubeControllerError.responseDataTooShort)
				return
			}
			
			// Convert response to string
			guard let responseString = String(data: data, encoding: .utf8) else {
				completion?(nil, YouTubeControllerError.responseDataInvalid)
				return
			}
			
			// Break the response into an array by ampersand
			let stringParts = responseString.components(separatedBy: "&")
			
			// Find the part that contains video info
			let streamMapPart = stringParts.first(where: { (part) -> Bool in
				return part.contains("url_encoded_fmt_stream_map")
			})
			
			// Break that part by comma to find video urls
			guard let streamParts = streamMapPart?.removingPercentEncoding?.replacingOccurrences(of: "url_encoded_fmt_stream_map", with: "").components(separatedBy: ",") else {
				
				completion?(nil, YouTubeControllerError.noStreamMapFound)
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
			let videoDictionary = streamParts.reduce([AnyHashable : [AnyHashable : Any]](), { (previousVideos, streamPart) -> [AnyHashable : [AnyHashable : Any]] in
				
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
				if dictionaryForQuality["sig"] == nil && dictionaryForQuality["signature"] == nil, let decodedStreamPart = streamPart.removingPercentEncoding {
					
					let decodedUrlParts = decodedStreamPart.components(separatedBy: "&")
					for part in decodedUrlParts {
						let keyArray = part.components(separatedBy: "=")
						guard keyArray.count > 1, keyArray[0] == "sig" || keyArray[0] == "signature" else {
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
			
			guard let quality = streamQuality else {
				completion?(nil, YouTubeControllerError.noValidQualityFound)
				return
			}
			
			guard let video = videoDictionary[quality], let url = video["url"] as? String, let sig = (video["sig"] as? String ?? video["signature"] as? String), let videoString = "\(url)&signature=\(sig)".removingPercentEncoding, let videoURL = URL(string: videoString) else {
				
				completion?(nil, YouTubeControllerError.finalURLInvalid)
				return
			}
			
			completion?(videoURL, nil)
		}
		
		dataTask.resume()
	}
}

public enum YouTubeControllerError: Error {
	case failedCreatingURLComponents
	case failedConstructingURL
	case invalidURL
	case responseDataTooShort
	case responseDataInvalid
	case noStreamMapFound
	case noValidQualityFound
	case finalURLInvalid
}
