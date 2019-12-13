//
//  QuizCompletion.swift
//  ThunderCloud
//
//  Created by Ben Shutt on 12/12/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import Foundation


extension QuizCompletion {
    
    /// Drive `PopupView` UI
    var popupConfig: PopupViewConfig {
        return PopupViewConfig(
            image: .tick,
            title: "Well done!".localised(with: "_QUIZ_COMPLETION_TITLE"),
            subtitle: "You have completed all of the tests.".localised(with: "_QUIZ_COMPLETION_HEADING"),
            detail: popup.contentValue ?? "",
            confirmText: cta.contentValue ?? "",
            cancelText: "Close".localised(with: "_QUIZ_COMPLETION_BUTTON_CLOSE"))
    }
}

/// Static helper class for getting `QuizCompletion` from Storm
public final class QuizCompletionManager {
    
    /// `StormFile` to drive content
    private static var quizCompletionFile: StormFile {
        return StormFile(
            resourceName: "quizcompletion",
            extension: "json",
            directory: .data)
    }
    
    /// Read the `QuizCompletion` json from the Storm bundle
    public static func quizCompletion() throws -> [QuizCompletion] {
        return [
            QuizCompletion(
                id: 1,
                popup: Text(content: "Test Popup"),
                cta: Text(content: "Test CTA"),
                destination: PageDescriptor(
                    name: "QuizCompletion",
                    src: "cache://pages/23345.json",
                    startPage: false,
                    type: "ListPage"))
        ]
        //return try ContentController.shared.jsonDecode(file: quizCompletionFile)
    }
    
    /// Check to see if all the quizes are complete. Is so present `AllQuizzesCompleteViewController`
    public static func checkAllQuizzesComplete(quizzes: [Quiz]) {
        let quizBadgeIds = Set(quizzes.compactMap({ $0.badge?.id }))
        let earnedIds = Set(BadgeController.shared.earnedBadges?.compactMap({ $0.id }) ?? [])
        
        if quizBadgeIds.count > 0 && quizBadgeIds.isSubset(of: earnedIds) {
            self.allQuizzesComplete()
        }
    }
    
    /// present `AllQuizzesCompleteViewController` on the `UIApplication.visibleViewController`
    private static func allQuizzesComplete() {
        let quizCompletions = try? quizCompletion()
        guard let quizCompletion = quizCompletions?.first else {
            return
        }
        
        let viewController = AllQuizzesCompleteViewController(quizCompletion: quizCompletion)
        let visibleViewController = UIApplication.visibleViewController
        visibleViewController?.present(viewController, animated: true)
    }
}

/// `UIViewController` with UI driven from corresponding`QuizCompletion` model
open class AllQuizzesCompleteViewController: UIViewController {
    
    /// `QuizCompletion` to drive content
    public let quizCompletion: QuizCompletion
    
    /// View behind `popupView` to dismiss this viewController
    private lazy var dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addGestureRecognizer(
            UITapGestureRecognizer.init(target: self, action: #selector(dimViewTapped)))
        return view
    }()
    
    /// View driven by `PopupView`
    private lazy var popupView: PopupView = {
        let view = PopupView()
        view.config = quizCompletion.popupConfig
        view.delegate = self
        return view
    }()
    
    /// `transitioningDelegate` to manage presentation
    private lazy var presentationManager = PresentationManager()
    
    // MARK: - Init
    
    public init (quizCompletion: QuizCompletion) {
        self.quizCompletion = quizCompletion
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        modalPresentationStyle = .custom
        transitioningDelegate = presentationManager
    }
    
    // MARK: - ViewController lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        constrain()
    }
    
    private func addSubviews() {
        view.addSubview(dimView)
        view.addSubview(popupView)
    }
    
    private func constrain() {
        dimView.translatesAutoresizingMaskIntoConstraints = false
        popupView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            popupView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            popupView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.9),
        ])
    }
    
    // MARK: - UIControlEvent
    
    @objc func dimViewTapped(_ sender: UITapGestureRecognizer) {
        presentingViewController?.dismiss(animated: true)
    }
}


// MARK: - PopupViewDelegate

extension AllQuizzesCompleteViewController : PopupViewDelegate {
    
    /// Confirm button click event
    func popupView(_ view: PopupView, confirmButtonTouchUpInside sender: UIButton) {
        presentingViewController?.dismiss(animated: true)
        
        // TODO: Storm link
        //quizCompletion.destination
    }
    
    /// Cancel button click event
    func popupView(_ view: PopupView, cancelButtonTouchUpInside sender: UIButton) {
        presentingViewController?.dismiss(animated: true)
    }
}
