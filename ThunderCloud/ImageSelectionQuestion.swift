//
//  ImageSelectionQuestion.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/09/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit

/// An image selection option for an ImageSelectionQuestion
public struct ImageOption {
    
    /// The title for the image option
    public let title: String?
    
    /// The image to display to the user
    public let image: StormImage?
}


/// The user is presented with a selection of images to choose from
public class ImageSelectionQuestion: QuizQuestion {
    
    public let options: [ImageOption]
    
    public let correctAnswer: [Int]
    
    public var limit: Int {
        return correctAnswer.count
    }
    
    public var answer: [Int] = [] {
        didSet {
            postNotification(notification: .answerChanged, object: self)
        }
    }
    
    override init?(dictionary: [AnyHashable : Any]) {
        
        guard let imageDictionaries = dictionary["images"] as? [Any] else { return nil }
        guard let options = dictionary["options"] as? [[AnyHashable : Any]] else { return nil }
        
        guard options.count == imageDictionaries.count, options.count > 0 else { return nil }
        
        self.options = options.enumerated().map({ (index, option) -> ImageOption in
            
            let imageDict = imageDictionaries[index]
            let image: StormImage? = StormGenerator.image(fromJSON: imageDict)
            return ImageOption(title: StormLanguageController.shared.string(for: option), image: image)
        })
        
        
        guard let answer = dictionary["answer"] as? [Int] else { return nil }
        correctAnswer = answer
        
        super.init(dictionary: dictionary)
    }
    
    override public var isCorrect: Bool {
        get {
            return correctAnswer.sorted(by: {$0>$1}) == answer.sorted(by: {$0>$1})
        }
        set {}
    }
    
    override public var answered: Bool {
        get {
            return limit > 0 ? (answer.count == limit) : (answer.count > 0)
        }
        set {}
    }
    
    override public func reset() {
        answer = []
    }
    
    override func answerCorrectly() {
        answer = correctAnswer
    }
    
    override func answerRandomly() {
        while answer.count < limit {
            let answerOption = Int(arc4random_uniform(UInt32(options.count)))
            if !answer.contains(answerOption) {
                answer.append(answerOption)
            }
        }
    }
}
