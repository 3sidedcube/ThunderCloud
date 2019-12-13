//
//  QuizCompletion.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 13/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// Base class for quiz-completion plugin
/// data/quizcompletion.json
public struct QuizCompletion: Codable {
    
    /// Id of the `QuizCompletion`
    public var id: Int
    
    /// Title of popup view
    /// Example: "Congrats you've earned all badges"
    public var popup: Text
    
    /// Title of destination button
    /// Example: "Go to course page"
    public var cta: Text
    
    /// Destination page to navigate to
    public var destination: PageDescriptor
}
