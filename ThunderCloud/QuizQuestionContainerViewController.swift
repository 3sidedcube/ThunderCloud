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
		return questions.filter({ (question) -> Bool in
			return question.answered
		}).count == questions.count
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

class QuizQuestionContainerViewController: UIViewController {
	
	/// The quiz that is being answered
	var quiz: Quiz?
	
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var hintLabel: UILabel!
	
	@IBOutlet weak var questionLabel: UILabel!
	
	@IBOutlet weak var embeddedView: UIView!
	
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
				
			} else if let textSelectionQuestion = question as? TextSelectionQuestion {
				
				let textSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "textSelection") as? QuizTextSelectionViewController
				textSelectionViewController?.question = textSelectionQuestion
				viewController = textSelectionViewController
				
			} else if let imageSelectionQuestion = question as? ImageSelectionQuestion {
				
				let imageSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "imageSelection") as? QuizImageSelectionViewController
				imageSelectionViewController?.question = imageSelectionQuestion
				viewController = imageSelectionViewController
				
			} else if let areaSelectionQuestion = question as? AreaSelectionQuestion {
				
				let areaSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "areaSelection") as? QuizAreaSelectionViewController
				areaSelectionViewController?.question = areaSelectionQuestion
				viewController = areaSelectionViewController
			}
			
			if let viewController = viewController {
				
                viewController.willMove(toParent: self)
                addChild(viewController)
				embeddedView.addSubview(viewController.view)
				
				viewController.view.translatesAutoresizingMaskIntoConstraints = false
				childView = viewController.view
                viewController.didMove(toParent: self)
				
				redraw()
			}
		}
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next".localised(with: "_QUIZ_BUTTON_NEXT"), style: .plain, target: self, action: #selector(handleNext(_:)))
		
		// Make sure we're not past the last question in the quiz
		guard let quiz = quiz, let questions = quiz.questions, quiz.currentIndex < questions.count else { return }
		
		question = questions[quiz.currentIndex]
		
		hintLabel.isHidden = question?.hint == nil
		hintLabel.text = question?.hint
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Set this back to nil so we don't break swipe back on other screens
        navigationController?.interactivePopGestureRecognizer?.delegate = nil;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Intercept the interactivePopGestureRecognizer delegate so we can disable swipe back if happened in the region of a quiz slider
        navigationController?.interactivePopGestureRecognizer?.delegate = self;
    }
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		// check if the back button was pressed
        guard isMovingFromParent, let quiz = quiz else { return }
		quiz.currentQuestion?.reset()
		self.quiz?.currentIndex = quiz.currentIndex - 1
	}
	
	private func redraw() {
		
		guard let question = question else { return }

		questionLabel.font = UIFont.preferredFont(forTextStyle: .body).withWeight(.bold)
		questionLabel.text = question.question
		
		hintLabel.font = UIFont.preferredFont(forTextStyle: .callout)
		embeddedView.backgroundColor = ThemeManager.shared.theme.backgroundColor
		view.backgroundColor = ThemeManager.shared.theme.backgroundColor
		
		navigationItem.titleView = titleView()
	}
	
	open func titleView() -> UIView? {
		
		guard let quiz = quiz, let questions = quiz.questions else { return nil }
		
		// UIView to contain multiple elements for navigation bar
		let progressContainer = UIView(frame: CGRect(x: 0, y: 0, width: 140, height: 44))
		
		let progressLabel = UILabel(frame: CGRect(x: 0, y: 3, width: progressContainer.bounds.width, height: 22))
		progressLabel.textAlignment = .center
		progressLabel.font = ThemeManager.shared.theme.boldFont(ofSize: 16)
		progressLabel.textColor = navigationController?.navigationBar.tintColor
		progressLabel.backgroundColor = .clear
		
		if StormLanguageController.shared.isRightToLeft {
			progressLabel.text = "\(questions.count) \("of".localised(with: "_QUIZ_OF")) \(quiz.currentIndex + 1)"
		} else {
			progressLabel.text = "\(quiz.currentIndex + 1) \("of".localised(with: "_QUIZ_OF")) \(questions.count)"
		}
		
		progressContainer.addSubview(progressLabel)
		
		let progressView = UIProgressView(frame: CGRect(x: 0, y: 22, width: progressContainer.bounds.width, height: 22))
		progressView.progressTintColor = ThemeManager.shared.theme.progressTintColour
		progressView.trackTintColor = ThemeManager.shared.theme.progressTrackTintColour
		progressView.progress = 0
		
		if StormLanguageController.shared.isRightToLeft {
			let transform = CGAffineTransform(rotationAngle: .pi)
			progressView.transform = transform
		}
			
		progressView.progress = Float(quiz.currentIndex) / Float(questions.count)
		progressView.setY(progressView.frame.minY + 10)
		progressView.transform = progressView.transform.concatenating(CGAffineTransform(scaleX: 1.0, y: 3.0))
		
		progressContainer.addSubview(progressView)
			
		let progressStartCap = UIView(frame: CGRect(x: progressView.frame.minX - 2, y: progressView.frame.minY, width: 6, height: 6))
		progressStartCap.cornerRadius = 3.0
		progressStartCap.backgroundColor = progressView.progressTintColor
		progressContainer.addSubview(progressStartCap)
		
		let progressEndCap = UIView(frame: CGRect(x: progressView.frame.maxX - 3, y: progressView.frame.minY, width: 6, height: 6))
		progressEndCap.cornerRadius = 3.0
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
		
		if let quiz = quiz, quiz.nextQuestion != nil {
			
			quiz.currentIndex = quiz.currentIndex + 1
			guard let questionViewController = quiz.questionViewController() as? QuizQuestionContainerViewController else { return }
			questionViewController.quiz = quiz
			navigationController?.pushViewController(questionViewController, animated: true)
			
		} else if let quiz = quiz {
			
			guard let quizCompletionViewcontrollerClass = StormObjectFactory.shared.class(for: NSStringFromClass(QuizCompletionViewController.self)) as? QuizCompletionViewController.Type else {
				print("[TabbedPageCollection] Please make sure your override for QuizCompletionViewController subclasses from QuizCompletionViewController")
				return
			}
			
			let quizCompletionViewController = quizCompletionViewcontrollerClass.init(quiz: quiz)
			navigationController?.pushViewController(quizCompletionViewController, animated: true)
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return ThemeManager.shared.theme.statusBarStyle
	}
	
	@IBAction func handleQuitQuiz(_ sender: Any) {
		
		quiz?.restart()
		
		let quizCompletionClass: AnyClass = StormObjectFactory.shared.class(for: String(describing: QuizCompletionViewController.self)) ?? QuizCompletionViewController.self
		var questionContainerClass: AnyClass?
		if let questionVC = quiz?.questionViewController() {
			questionContainerClass = type(of: questionVC)
		}
		
		popToLastViewController(excluding: [
			questionContainerClass ?? QuizQuestionContainerViewController.self,
			quizCompletionClass
		])
	}
}

extension QuizQuestionContainerViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let slider = sliderViewController?.slider else {
            return true
        }
        return !slider.point(inside: touch.location(in: slider), with: nil)
    }
}
