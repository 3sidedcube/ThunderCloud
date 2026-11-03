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
    
    /// Destination page to navigate to
    public var destination: PageDescriptor
}
