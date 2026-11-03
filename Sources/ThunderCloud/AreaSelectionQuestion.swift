//
//  AreaSelectionQuestion.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/09/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit

/// A cartesian coordinate in the x,y,z plans
public struct Coordinate {
    
    /// The x coordinate
    public let x: Double
    
    /// The y coordinate
    public let y: Double
    
    /// The z coordinate
    public let z: Double
    
    /// A 2D representation of the coordinate in the x-y plane
    public var point: CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    /// Initialises a new coordinate from a dictionary representation
    ///
    /// - Parameter dictionary: The dictionary representation of the coordinate
    init(dictionary: [AnyHashable : Any]) {
        
        if let x = dictionary["x"] as? Double {
            self.x = x
        } else if let x = dictionary["x"] as? Int {
            self.x = Double(x)
        } else {
            x = 0
        }
        
        if let y = dictionary["y"] as? Double {
            self.y = y
        } else if let y = dictionary["y"] as? Int {
            self.y = Double(y)
        } else {
            y = 0
        }
        
        if let z = dictionary["z"] as? Double {
            self.z = z
        } else if let z = dictionary["z"] as? Int {
            self.z = Double(z)
        } else {
            z = 0
        }
    }
    
    /// Initialises a coordinage from a 2D CGPoint
    ///
    /// - Parameter point: the point to construct the coordinate from
    public init(point: CGPoint) {
        
        x = Double(point.x)
        y = Double(point.y)
        z = 0
    }
}

public func ==(lhs: Coordinate?, rhs: Coordinate?) -> Bool {
    guard let _lhs = lhs, let _rhs = rhs else {
        // Have to use this syntax otherwise we get a recurssion loop
        // If one of them is non-nil then they're not equal
        if let _ = lhs {
            return false
        }
        if let _ = rhs {
            return false
        }
        return true
    }
    return _lhs.x == _rhs.x && _lhs.y == _rhs.y && _lhs.z == _rhs.z
}

/// A zone to be used with AreaSelectionQuestion represented by a collection of points
public struct Zone {
    
    /// The bounding coordinates for the zone
    public let coordinates: [Coordinate]
    
    init?(dictionary: [AnyHashable : Any]) {
        
        guard let coordinates = dictionary["coordinates"] as? [[AnyHashable : Any]] else { return nil }
        self.coordinates = coordinates.map({ (coordinateDict) -> Coordinate in
            return Coordinate(dictionary: coordinateDict)
        })
    }
    
    /// Returns whether the zone contains a point
    ///
    /// - Parameter point: The point to test against
    /// - Returns: A bool as to whether the point lies within the zone
    public func contains(point: CGPoint) -> Bool {
        
        guard let firstCoordinate = coordinates.first else {
            return false
        }
        
        guard coordinates.count > 1 else {
            return Coordinate(point: point) == coordinates.first
        }
        
        let path = UIBezierPath()
        
        path.move(to: firstCoordinate.point)
        for index in 1...coordinates.count-1 {
            path.addLine(to: coordinates[index].point)
        }
        path.close()
        
        return path.contains(point)
    }
}

/// The user is presented with an image and must click on the correct location in the image
public class AreaSelectionQuestion: QuizQuestion {
    
    /// The image that the user should select an area on (Cannot be called `image` due to Row conformance)
    public let selectionImage: StormImage
    
    /// A zone representing an area in which the user can tap and be marked as correct
    public let correctAnswer: Zone
    
    public var answer: CGPoint? {
        didSet {
            postNotification(notification: .answerChanged, object: self)
        }
    }
    
    override public var isCorrect: Bool {
        get {
            guard let answer = answer else { return false }
            return correctAnswer.contains(point: answer)
        }
        set {}
    }
    
    override public var answered: Bool {
        get {
            return answer != nil
        }
        set {}
    }
    
    override init?(dictionary: [AnyHashable : Any]) {
        
        guard let imageObject = dictionary["image"] else { return nil }
        
        guard let image = StormGenerator.image(fromJSON: imageObject) else { return nil }
        
        selectionImage = image
        
        guard let zoneObjects = dictionary["answer"] as? [[AnyHashable : Any]], let firstZone = zoneObjects.first else { return nil }
        guard let answer = Zone(dictionary: firstZone) else { return nil }
        
        correctAnswer = answer
        
        super.init(dictionary: dictionary)
        
        isAnswerableWithVoiceOverOn = false
    }
    
    override public func reset() {
        answer = nil
    }
    
    override func answerCorrectly() {
        answer = correctAnswer.coordinates.first?.point
    }
    
    override func answerRandomly() {
        answer = CGPoint(x: CGFloat(Float(arc4random()) / Float(UINT32_MAX)), y: CGFloat(Float(arc4random()) / Float(UINT32_MAX)))
    }
}
