//
//  QuizQuestionContainerViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 10/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderBasics
import ThunderTable

extension Quiz {
    
    var answeredAllQuestions: Bool {
        guard let questions = questions else { return true }
        return questions.filter({$0.answered}).count == questions.count
    }
    
    var nextQuestion: QuizQuestion? {
        guard let questions = questions, (currentIndex + 1) < questions.count else { return nil }
        return questions[currentIndex+1]
    }
    
    var currentQuestion: QuizQuestion? {
        guard let questions = questions, currentIndex < questions.count, currentIndex > 0 else { return nil }
        return questions[currentIndex]
    }
}

protocol QuizQuestionViewControllerDelegate {
    
    func quizQuestionViewController(_ questionViewController: QuizQuestionViewController, didChangeAnswerFor question: QuizQuestion)
}

protocol QuizQuestionViewController {
    
    var delegate: QuizQuestionViewControllerDelegate? { get set }
}

open class QuizQuestionContainerViewController: AccessibilityRefreshingViewController {
    
    /// The quiz that is being answered
    public var quiz: Quiz?
    
    @IBOutlet open weak var headerScrollView: UIScrollView!
    
    @IBOutlet open weak var hintLabel: UILabel!
    
    @IBOutlet open weak var questionLabel: UILabel!
    
    @IBOutlet open weak var embeddedView: UIView!
    
    @IBOutlet open weak var selectedLabel: UILabel!
    
    @IBOutlet open weak var continueButton: AccessibleButton!
    
    var childView: UIView? {
        didSet {
            guard let childView = childView else { return }
            childView.attachEdges(to: embeddedView)
        }
    }
    
    var areaSelectionViewController: QuizAreaSelectionViewController? {
        return children.first as? QuizAreaSelectionViewController
    }
    
    var textSelectionViewController: QuizTextSelectionViewController? {
        return children.first as? QuizTextSelectionViewController
    }
    
    var sliderViewController: QuizSliderViewController? {
        return children.first as? QuizSliderViewController
    }
    
    var imageSelectionViewController: QuizImageSelectionViewController? {
        return children.first as? QuizImageSelectionViewController
    }
    
    var question: QuizQuestion? {
        didSet {
            
            if let childViewController = children.first {
                
                childViewController.willMove(toParent: nil)
                childViewController.removeFromParent()
                childView?.removeFromSuperview()
                childViewController.didMove(toParent: nil)
                childView = nil
            }
            
            guard let question = question else { return }
            
            var viewController: UIViewController?
            
            if let sliderQuestion = question as? ImageSliderQuestion {
                
                let imageSliderViewController = storyboard?.instantiateViewController(withIdentifier: "slider") as? QuizSliderViewController
                imageSliderViewController?.question = sliderQuestion
                viewController = imageSliderViewController
                selectedLabel.isHidden = true
                
            } else if let textSelectionQuestion = question as? TextSelectionQuestion {
                
                let textSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "textSelection") as? QuizTextSelectionViewController
                textSelectionViewController?.question = textSelectionQuestion
                textSelectionViewController?.quiz = quiz
                viewController = textSelectionViewController
                selectedLabel.isHidden = false
                
            } else if let imageSelectionQuestion = question as? ImageSelectionQuestion {
                
                let imageSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "imageSelection") as? QuizImageSelectionViewController
                imageSelectionViewController?.question = imageSelectionQuestion
                imageSelectionViewController?.quiz = quiz
                viewController = imageSelectionViewController
                selectedLabel.isHidden = false
                
            } else if let areaSelectionQuestion = question as? AreaSelectionQuestion {
                
                let areaSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "areaSelection") as? QuizAreaSelectionViewController
                areaSelectionViewController?.question = areaSelectionQuestion
                viewController = areaSelectionViewController
                selectedLabel.isHidden = true
            }
            
            guard let _viewController = viewController else { return }
                
            _viewController.willMove(toParent: self)
            addChild(_viewController)
            embeddedView.addSubview(_viewController.view)
            
            _viewController.view.translatesAutoresizingMaskIntoConstraints = false
            childView = _viewController.view
            _viewController.didMove(toParent: self)
            
            redraw()
            
            guard var quizViewController = viewController as? QuizQuestionViewController else { return }
            quizViewController.delegate = self
        }
    }
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()

        // If we're being presented or we're not the first view controller
        if presentingViewController != nil || self != navigationController?.viewControllers.first {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: (#imageLiteral(resourceName: "quiz-dismiss") as StormImageLiteral).image, style: .plain, target: self, action: #selector(handleQuitQuiz(_:)))
            navigationItem.rightBarButtonItem?.accessibilityLabel = "Quit Quiz".localised(with: "_QUIZ_BUTTON_QUIT")
        }
        
        continueButton.setTitle("Continue".localised(with: "_QUIZ_BUTTON_NEXT"), for: .normal)
        continueButton.layer.cornerRadius = 6.0
        continueButton.layer.masksToBounds = true
        
        selectedLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 11, textStyle: .footnote, weight: .medium)
        selectedLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        hintLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        
        headerScrollView.alwaysBounceVertical = false
        
        // Make sure we're not past the last question in the quiz
        guard let quiz = quiz, let questions = quiz.questions, quiz.currentIndex < questions.count else { return }
        
        question = questions[quiz.currentIndex]
        
        hintLabel.isHidden = question?.hint == nil
        hintLabel.text = question?.hint
        redrawContinueButton()
        redrawSelectedLabel()
        
        guard UIAccessibility.isVoiceOverRunning, question?.isAnswerableWithVoiceOverOn == false else { return }
        
        hintLabel.text = nil
        hintLabel.isHidden = true
        
        questionLabel.text = "This question cannot be completed with VoiceOver enabled, please navigate to the next question".localised(with: "_VOICEOVER_AREA_QUIZ_QUESTION_MESSAGE")
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Set this back to nil so we don't break swipe back on other screens
        navigationController?.interactivePopGestureRecognizer?.delegate = nil;
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Intercept the interactivePopGestureRecognizer delegate so we can disable swipe back if happened in the region of a quiz slider
        navigationController?.interactivePopGestureRecognizer?.delegate = self;
        
        NotificationCenter.default.sendAnalyticsScreenView(
            Analytics.ScreenView(
                screenName: "quiz_question",
                navigationController: navigationController
            )
        )
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // check if the back button was pressed
        guard isMovingFromParent, let quiz = quiz else { return }
        quiz.currentQuestion?.reset()
        self.quiz?.currentIndex = quiz.currentIndex - 1
    }
    
    private func redraw() {
        
        guard let question = question else { return }
        
        if UIAccessibility.isVoiceOverRunning, !question.isAnswerableWithVoiceOverOn {
            questionLabel.text = "This question cannot be completed with VoiceOver enabled, please navigate to the next question".localised(with: "_VOICEOVER_AREA_QUIZ_QUESTION_MESSAGE")
        } else {
            questionLabel.text = question.question
        }
        
        questionLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 17, textStyle: .body, weight: .bold)
        
        hintLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 16, textStyle: .callout)
        embeddedView.backgroundColor = ThemeManager.shared.theme.backgroundColor
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        navigationItem.titleView = titleView()
    }
    
    private func redrawSelectedLabel() {
        
        var selected: String?
        var total: String?
        
        switch question {
        case let imageSelectionQuestion as ImageSelectionQuestion:
            selected = "\(imageSelectionQuestion.answer.count)"
            total = "\(imageSelectionQuestion.correctAnswer.count)"
        case let textSelectionQuestion as TextSelectionQuestion:
            selected = "\(textSelectionQuestion.answer.count)"
            total = "\(textSelectionQuestion.correctAnswer.count)"
        default:
            break
        }
        
        guard let _selected = selected, let _total = total else { return }
        
        let params = [
            "SELECTED": _selected,
            "TOTAL": _total
        ]
        selectedLabel.text = "{SELECTED} of {TOTAL} selected".localised(
            with: "_QUIZ_LABEL_SELECTED",
            paramDictionary: params
        )
        selectedLabel.accessibilityLabel = "{SELECTED} out of {TOTAL} possible answers selected".localised(
            with: "_QUIZ_VOICEOVER_LABEL_SELECTED",
            paramDictionary: params
        )
    }
    
    open func redrawContinueButton() {
        guard let question = question else { return }
        
        let requireAnswer = QuizConfiguration.shared.requireAnswer
        let answered = requireAnswer ? question.answered : true
        redrawContinueButton(answered: answered)
    }
    
    open func redrawContinueButton(answered: Bool) {
        continueButton.titleLabel?.font = ThemeManager.shared.theme.dynamicFont(ofSize: 15, textStyle: .body)
        continueButton.isEnabled = answered
        continueButton.accessibilityTraits = answered ? [.button] : [.button, .notEnabled]
        continueButton.solidMode = answered
        continueButton.useBorderColor = !answered
        continueButton.layer.borderColor = ThemeManager.shared.theme.lightGrayColor.cgColor
        continueButton.primaryColor = answered ? ThemeManager.shared.theme.mainColor : ThemeManager.shared.theme.darkGrayColor
        continueButton.secondaryColor = answered ? ThemeManager.shared.theme.whiteColor : ThemeManager.shared.theme.darkGrayColor
    }
    
    open func titleView() -> UIView? {
        
        guard let quiz = quiz, let questions = quiz.questions else { return nil }
        
        // UIView to contain multiple elements for navigation bar
        let progressContainer = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 44))
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 3, width: progressContainer.bounds.width, height: 26))
        titleLabel.textAlignment = .center
        titleLabel.clipsToBounds = false
        let font = ThemeManager.shared.theme.dynamicFont(ofSize: 16, textStyle: .body, weight: .bold)
        titleLabel.font = font.withSize(min(font.pointSize, 26))
        titleLabel.textColor = navigationController?.navigationBar.tintColor
        titleLabel.backgroundColor = .clear
        
        titleLabel.accessibilityLabel = "{QUIZ_NAME} quiz".localised(
            with: "_QUIZ_TITLE_ACCESSIBILITYLABEL",
            paramDictionary: [
                "QUIZ_NAME": quiz.title ?? ""
            ]
        )
        
        if StormLanguageController.shared.isRightToLeft {
            titleLabel.text = "\(questions.count) \("of".localised(with: "_QUIZ_OF")) \(quiz.currentIndex + 1)"
        } else {
            titleLabel.text = "\(quiz.currentIndex + 1) \("of".localised(with: "_QUIZ_OF")) \(questions.count)"
        }
        
        progressContainer.addSubview(titleLabel)
        
        let progress = Float(quiz.currentIndex) / Float(max(questions.count, 1))
        let progressPercent = Int(round(progress * 100))
        
        let progressView = UIProgressView(frame: CGRect(x: 0, y: 22, width: progressContainer.bounds.width, height: 22))
        progressView.progressTintColor = ThemeManager.shared.theme.progressTintColour
        progressView.trackTintColor = ThemeManager.shared.theme.progressTrackTintColour
        progressView.progress = 0
        progressView.accessibilityLabel = "Progress, {PROGRESS}%".localised(
            with: "_QUIZ_PROGRESS_ACCESSIBILITYLABEL",
            paramDictionary: [
                "PROGRESS": "\(progressPercent)"
            ]
        )
        progressView.accessibilityValue = "Question {QUESTION} of {NO_QUESTIONS}".localised(
            with: "_QUIZ_PROGRESS_ACCESSIBILITYVALUE",
            paramDictionary: [
                "QUESTION": "\(quiz.currentIndex + 1)",
                "NO_QUESTIONS": "\(questions.count)"
            ]
        )
        
        if StormLanguageController.shared.isRightToLeft {
            let transform = CGAffineTransform(rotationAngle: .pi)
            progressView.transform = transform
        }
        
        progressView.progress = Float(quiz.currentIndex) / Float(questions.count)
        progressView.set(minY: progressView.frame.minY + 10)
        
        let progressViewHeight: CGFloat = 6
        // This is according to Stack Overflow the best way to give `UIProgressView` a custom height.
        // we're not hard-coding the denominator here, as in iOS 14 Apple changed the standard height.
        // frame may be set to 22 above, but something in `UIProgressView`'s init method, manually sets
        // it to the correct system default value!
        let yTransform = progressViewHeight/progressView.bounds.height
        progressView.transform = progressView.transform.concatenating(CGAffineTransform(scaleX: 1.0, y: yTransform))
        
        progressContainer.addSubview(progressView)
        
        let progressStartCap = UIView(
            frame: CGRect(
                x: progressView.frame.minX - 2,
                y: progressView.frame.minY,
                width: progressViewHeight,
                height: progressViewHeight
            )
        )
        progressStartCap.layer.cornerRadius = progressViewHeight/2
        progressStartCap.layer.masksToBounds = true
        progressStartCap.backgroundColor = progressView.progressTintColor
        progressContainer.addSubview(progressStartCap)
        
        let progressEndCap = UIView(
            frame: CGRect(
                x: progressView.frame.maxX - 4,
                y: progressView.frame.minY,
                width: progressViewHeight,
                height: progressViewHeight
            )
        )
        progressEndCap.layer.cornerRadius = progressViewHeight/2
        progressEndCap.layer.masksToBounds = true
        progressEndCap.backgroundColor = progressView.trackTintColor
        progressContainer.addSubview(progressEndCap)
        
        return progressContainer
    }
    
    @IBAction func handlePrevious(_ sender: Any) {
        
        guard let quiz = quiz else { return }
        
        if quiz.currentIndex > 0 {
            
            guard popToLastViewController(of: QuizQuestionContainerViewController.self) else { return }
            quiz.currentIndex = quiz.currentIndex - 1
            
        } else {
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func handleNext(_ sender: Any) {
        guard let quiz = quiz else {
            return
        }
        
        if quiz.nextQuestion != nil {
            
            quiz.currentIndex = quiz.currentIndex + 1
            guard let questionViewController = quiz.questionViewController() as? QuizQuestionContainerViewController else { return }
            questionViewController.quiz = quiz
            questionViewController.hidesBottomBarWhenPushed =
                navigationController?.shouldHideBottomBarWhenPushed() ?? false
            navigationController?.pushViewController(questionViewController, animated: true)
            
        } else {
            
            guard let quizCompletionViewcontrollerClass = StormObjectFactory.shared.class(for: NSStringFromClass(QuizCompletionViewController.self)) as? QuizCompletionViewController.Type else {
                print("[TabbedPageCollection] Please make sure your override for QuizCompletionViewController subclasses from QuizCompletionViewController")
                return
            }
            
            let quizCompletionViewController = quizCompletionViewcontrollerClass.init(quiz: quiz)
            navigationController?.pushViewController(quizCompletionViewController, animated: true)
        }
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.theme.statusBarStyle
    }
    
    @IBAction func handleQuitQuiz(_ sender: Any) {
        
        quiz?.restart()
        
        if presentingViewController != nil {
            dismissAnimated()
        } else {
            
            let quizCompletionClass: AnyClass = StormObjectFactory.shared.class(for: String(describing: QuizCompletionViewController.self)) ?? QuizCompletionViewController.self
            var questionContainerClass: AnyClass?
            if let questionVC = quiz?.questionViewController() {
                questionContainerClass = type(of: questionVC)
            }
            
            // If we couldn't pop, and we're on iPad...
            guard !popToLastViewController(excluding: [
                questionContainerClass ?? QuizQuestionContainerViewController.self,
                quizCompletionClass
            ]), UI_USER_INTERFACE_IDIOM() == .pad else {
                return
            }
            
            // Set view controllers rather than popping otherwise first VC doesn't reset and we end up answering
            // the first question twice!
            navigationController?.setViewControllers([quiz?.questionViewController()].compactMap({ $0 }), animated: false)
        }
    }
    
    open override func accessibilitySettingsDidChange() {
        
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.theme.navigationBarBackgroundColor
        navigationController?.navigationBar.tintColor = ThemeManager.shared.theme.navigationBarTintColor
        
        redraw()
        redrawContinueButton()
        
        selectedLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 11, textStyle: .footnote, weight: .medium)
        selectedLabel.textColor = ThemeManager.shared.theme.darkGrayColor
        hintLabel.textColor = ThemeManager.shared.theme.darkGrayColor
    }
}

extension QuizQuestionContainerViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let slider = sliderViewController?.slider else {
            return true
        }
        return !slider.point(inside: touch.location(in: slider), with: nil)
    }
}

extension QuizQuestionContainerViewController: QuizQuestionViewControllerDelegate {
    
    func quizQuestionViewController(_ questionViewController: QuizQuestionViewController, didChangeAnswerFor question: QuizQuestion) {
        
        redrawSelectedLabel()
        redrawContinueButton()
        
        var selected: Int?
        var total: Int?
        
        switch question {
        case let imageSelectionQuestion as ImageSelectionQuestion:
            selected = imageSelectionQuestion.answer.count
            total = imageSelectionQuestion.correctAnswer.count
        case let textSelectionQuestion as TextSelectionQuestion:
            selected = textSelectionQuestion.answer.count
            total = textSelectionQuestion.correctAnswer.count
        default:
            break
        }
        
        guard let _selected = selected, let _total = total, _total > 0 else { return }
        
        let params = [
            "SELECTED": "\(_selected)",
            "TOTAL": "\(_total)"
        ]
        UIAccessibility.post(
            notification: .announcement,
            argument: "{SELECTED} out of {TOTAL} possible answers selected".localised(
                with: "_QUIZ_VOICEOVER_LABEL_SELECTED",
                paramDictionary: params
            )
        )
    }
}
