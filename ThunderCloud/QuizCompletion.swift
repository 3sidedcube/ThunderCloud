//
//  QuizCompletion.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 12/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation

/// Base class for quiz-completion plugin
/// data/quizcompletion.json
public struct QuizCompletion: Codable {
    
    /// {TEXT}
    /// Title of popup view
    /// Example: "Congrats you've earned all badges"
    public var popup: String
    
    /// {TEXT}
    /// Title of destination button
    /// Example: "Go to course page"
    public var cta: String
    
    /// {PageDescriptor}
    /// Destination page to navigate to
    public var destination: String
}

/// Static helper class for getting `QuizCompletion` from Storm
public final class QuizCompletionManager {
    
    /// `StormFile` to drive content
    private static let quizCompletionFile = StormFile(
        resourceName: "quizcompletion",
        extension: "json",
        directory: .data)
    
    /// Read the `QuizCompletion` json from the Storm bundle
    public static func quizCompletion() throws -> QuizCompletion {
        return try ContentController.shared.jsonDecode(file: quizCompletionFile)
    }
}

/// `UIViewController` with UI driven from corresponding`QuizCompletion` model
open class AllQuizzesCompleteViewController: UIViewController {
    
    /// `QuizCompletion` to drive content
    public let quizCompletion: QuizCompletion
    
    // MARK: - Init
    
    public init (quizCompletion: QuizCompletion) {
        self.quizCompletion = quizCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController lifecycle
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        
        stackView.addArrangedSubview(topLabel)
        stackView.addArrangedSubview(middleLabel)
        stackView.addArrangedSubview(bottomLabel)
        
        return stackView
    }()
    
    lazy var topLabel: UILabel = {
        let label = UILabel()
        
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var middleLabel: UILabel = {
        let label = UILabel()
        
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        
        return label
    }()
    
    lazy var bottomLabel: UILabel = {
        let label = UILabel()
        
        label.text = ""
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        
        return label
    }()
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(stackView)
        
        topLabel.text = quizCompletion.popup
        middleLabel.text = quizCompletion.cta
        bottomLabel.text = quizCompletion.destination
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        stackView.center = view.center
    }
    
    
}
