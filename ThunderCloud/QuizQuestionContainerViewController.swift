//
//  QuizQuestionContainerViewController.swift
//  GNAH
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
		guard let questions = questions, currentIndex < questions.count else { return nil }
		return questions[currentIndex]
	}
}

class QuizQuestionContainerViewController: UIViewController {
	
	/// The quiz that is being answered
	var quiz: Quiz?
	
	@IBOutlet weak var bottomConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var hintLabel: UILabel!
	
	/// Reads QUESTION X OF Y
	@IBOutlet weak var progressLabel: UILabel!
	
	@IBOutlet weak var progressView: UIProgressView!
	
	@IBOutlet weak var questionLabel: UILabel!
	
	@IBOutlet weak var embeddedView: UIView!
	
	var childView: UIView? {
		didSet {
			guard let childView = childView else { return }
			childView.layoutAttachAll(to: embeddedView)
		}
	}
	
	var areaSelectionViewController: QuizAreaSelectionViewController? {
		return childViewControllers.first as? QuizAreaSelectionViewController
	}
	
	var textSelectionViewController: QuizTextSelectionViewController? {
		return childViewControllers.first as? QuizTextSelectionViewController
	}
	
	var sliderViewController: QuizSliderViewController? {
		return childViewControllers.first as? QuizSliderViewController
	}
	
	var imageSelectionViewController: QuizImageSelectionViewController? {
		return childViewControllers.first as? QuizImageSelectionViewController
	}
	
	var question: QuizQuestion? {
		didSet {
			
			if let childViewController = childViewControllers.first {
				
				childViewController.willMove(toParentViewController: nil)
				childViewController.removeFromParentViewController()
				childView?.removeFromSuperview()
				childViewController.didMove(toParentViewController: nil)
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
				textSelectionViewController?.screenName = screenName
				viewController = textSelectionViewController
				
			} else if let imageSelectionQuestion = question as? ImageSelectionQuestion {
				
				let imageSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "imageSelection") as? QuizImageSelectionViewController
				imageSelectionViewController?.question = imageSelectionQuestion
				imageSelectionViewController?.screenName = screenName
				viewController = imageSelectionViewController
				
			} else if let areaSelectionQuestion = question as? AreaSelectionQuestion {
				
				let areaSelectionViewController = storyboard?.instantiateViewController(withIdentifier: "areaSelection") as? QuizAreaSelectionViewController
				areaSelectionViewController?.question = areaSelectionQuestion
				viewController = areaSelectionViewController
			}
			
			let isScrollView = (question is ImageSelectionQuestion || question is TextSelectionQuestion)
			
			bottomConstraint.priority = UILayoutPriority(rawValue: UILayoutPriority.RawValue(isScrollView ? 999 : 500))
			nextButtonContainer.backgroundColor = ThemeManager.shared.theme.darkBlueColor.withAlphaComponent(0.69)
			
			if let viewController = viewController {
				
				viewController.willMove(toParentViewController: self)
				addChildViewController(viewController)
				embeddedView.addSubview(viewController.view)
				
				viewController.view.translatesAutoresizingMaskIntoConstraints = false
				childView = viewController.view
				viewController.didMove(toParentViewController: self)
				
				redraw()
			}
		}
	}

	@IBOutlet weak var imageView: UIImageView!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		if let planItem = planItem {
			
			imageView.image = planItem.image
			
		} else {
			
			imageView.image = (quiz?.questions?.first(where: { question -> Bool in
				return question is ImageSliderQuestion
			}) as? ImageSliderQuestion)?.image
		}
		
		// Make sure we're not past the last question in the quiz
		guard let quiz = quiz, let questions = quiz.questions, quiz.currentIndex < questions.count else { return }
		
		question = questions[quiz.currentIndex]
		
		hintLabel.isHidden = question?.hint == nil
		hintLabel.text = question?.hint
		
		progressView.progressTintColor = ThemeManager.shared.theme.orangeColor
		
		QuizQuestion.addObserver(observer: self, selector: #selector(redrawButtons), notification: .answerChanged)
		TextSelectionQuestion.addObserver(observer: self, selector: #selector(redrawButtons), notification: .answerChanged)
		ImageSliderQuestion.addObserver(observer: self, selector: #selector(redrawButtons), notification: .answerChanged)
		ImageSelectionQuestion.addObserver(observer: self, selector: #selector(redrawButtons), notification: .answerChanged)
		AreaSelectionQuestion.addObserver(observer: self, selector: #selector(redrawButtons), notification: .answerChanged)
		
		if UserController.shared.currentUser == nil {
			screenName = "On Boarding Story - Quiz Question"
		} else if let planItem = planItem, let itemType = planItem.type {
			
			switch itemType {
			case .content:
				screenName = "Learn - Quiz Question"
				break
			case .story:
				screenName = "Story - Quiz Question"
				break
			default:
				break
			}
			
		} else {
			screenName = "Quiz Question"
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
//		childView?.frame = embeddedView.frame
	}
	
	private func redraw() {
		
		guard let quiz = quiz, let question = question else { return }
		redrawButtons()
		
		progressLabel.text = "QUESTION {INDEX} OF {LENGTH}".localised(with: "_QUIZ_LABEL_PROGRESS", paramDictionary: ["INDEX": quiz.currentIndex+1, "LENGTH": quiz.questions?.count ?? 1])
		questionLabel.text = question.question
		progressView.progress = Float(quiz.currentIndex+1) / Float(quiz.questions?.count ?? 1)
	}
	
	@objc private func redrawButtons() {
		
		guard let question = question else { return }
		
		nextButton.isEnabled = question.answered
		nextButton.alpha = question.answered ? 1.0 : 0.4
	}
	
	@IBAction func handlePrevious(_ sender: Any) {
		
		guard let quiz = quiz else { return }
		
		if quiz.currentIndex > 0 {
			
			guard popToLastViewController(of: QuizQuestionContainerViewController.self) else { return }
			quiz.currentIndex = quiz.currentIndex - 1
			
		} else {
			
			navigationController?.popViewController(animated: true)
			// Already popped, so check the last item
			guard let viewControllers = navigationController?.viewControllers, viewControllers.count > 1, viewControllers[viewControllers.count-1] as? RSPBQuizCompletionViewController == nil else { return }
			navigationController?.setNavigationBarHidden(false, animated: true)
		}
	}
	
	@IBAction func handleNext(_ sender: Any) {
		NotificationCenter.default.sendStatEventNotification(category: screenName ?? "Quiz Question", action: "Next", label: quiz?.currentQuestion?.question, value: nil, object: nil)
		performSegue(withIdentifier: "questionAnswer", sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		guard let identifier = segue.identifier else { return }
		
		switch identifier {
		case "questionAnswer":
			
			guard let answerViewController = segue.destination as? QuizQuestionAnswerViewController else { return }
			answerViewController.quiz = quiz
			answerViewController.planItem = planItem
			
			break
		default:
			break
		}
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
	
	@IBAction func handleQuitQuiz(_ sender: Any) {
		
		quiz?.restart()
		
		// Order is important here! And if we're in onboarding then don't show navigation bar!
		if UserController.shared.currentUser != nil {
			self.navigationController?.setNavigationBarHidden(false, animated: true)
		}
		
		_ = popToLastViewController(excluding: [
			QuizQuestionContainerViewController.self,
			QuizQuestionAnswerViewController.self,
			RSPBQuizCompletionViewController.self,
			StoryLandingViewController.self
		])
	}
}
