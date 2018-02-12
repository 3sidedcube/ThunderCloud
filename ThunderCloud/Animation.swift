//
//  Animation.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import Foundation

/// A representation of an animated image
///
/// Contains info about the frames and whether or not the animagion is looped
public struct Animation {
	
	/// Single frame of an animation
	public struct Frame {
		
		/// Delay in seconds before the next frame
		public let delay: TimeInterval
		
		/// The image to display for this frame
		public let image: UIImage?
		
		/// Creates a frame from a storm dictionary
		///
		/// - Parameter dictionary: Dictionary representation of the frame
		init(dictionary: [AnyHashable : Any]) {
			
			delay = dictionary["delay"] as? TimeInterval ?? 1
			image = StormGenerator.image(fromJSON: dictionary["image"])
		}
	}
	
	/// The array of frames that compose the animation
	public let frames: [Animation.Frame]
	
	/// Whether the animation should loop
	public let looped: Bool
	
	/// Creates a new instance using a storm dictionary object
	///
	/// - Parameter dictionary: A storm dictionary with animation information
	public init?(dictionary: [AnyHashable : Any]) {
		
		guard let framesArray = (dictionary["frames"] as? [[AnyHashable : Any]]) else { return nil }
		
		frames = framesArray.map({
			return Animation.Frame(dictionary: $0)
		})
		looped = dictionary["looped"] as? Bool ?? false
	}
}
