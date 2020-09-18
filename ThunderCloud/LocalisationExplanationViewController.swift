//
//  LocalisationExplanationViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 13/11/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics

/// A view controller which explains to the user what is going on when they enter 'edit localisation' mode
class LocalisationExplanationViewController: UIViewController {
    
    let moreButton: UIButton = UIButton()
    
    var backgroundView: UIVisualEffectView?
    
    let titleLabel: UILabel = UILabel()
    
    let greenLabel: UILabel = UILabel()
    let greenImageView: UIImageView = UIImageView(image: UIImage(named: "localisations-green-light", in: Bundle(for: LocalisationExplanationViewController.self), compatibleWith: nil))
    
    let amberLabel: UILabel = UILabel()
    let amberImageView: UIImageView = UIImageView(image: UIImage(named: "localisations-amber-light", in: Bundle(for: LocalisationExplanationViewController.self), compatibleWith: nil))
    
    let redLabel: UILabel = UILabel()
    let redImageView: UIImageView = UIImageView(image: UIImage(named: "localisations-red-light", in: Bundle(for: LocalisationExplanationViewController.self), compatibleWith: nil))
    
    let otherLabel: UILabel = UILabel()
    let otherButton: UIButton = UIButton()
    
    let containerView: UIView = UIView()
    
    var viewHasAppeared: Bool = false
    
    /// A closure which is called when the view controller wants to dismiss itself
    var dismissHandler: (() -> Void)?
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        backgroundView?.alpha = 0.0
        view.addSubview(backgroundView!)
        
        containerView.alpha = 0.0
        view.addSubview(containerView)
        
        moreButton.setImage(UIImage(named: "localisations-morebutton", in: Bundle(for: LocalisationExplanationViewController.self), compatibleWith: nil), for: .normal)
        moreButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        
        titleLabel.text = "Tap a highlighted localisation to get editing!"
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        containerView.addSubview(titleLabel)
        
        greenLabel.text = "A localisation is highlighted green if it's up to date with the value in the CMS."
        greenLabel.numberOfLines = 0
        greenLabel.font = UIFont.boldSystemFont(ofSize: 14)
        greenLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        containerView.addSubview(greenLabel)
        
        greenImageView.alpha = 0.0
        view.addSubview(greenImageView)
        
        amberLabel.text = "A localisation is highlighted amber if the localisation in the app isn't the same as the one in the CMS."
        amberLabel.numberOfLines = 0
        amberLabel.font = UIFont.boldSystemFont(ofSize: 14)
        amberLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        containerView.addSubview(amberLabel)
        
        amberImageView.alpha = 0.0
        view.addSubview(amberImageView)
        
        redLabel.text = "A localisation is highlighted red if it hasn't yet been added to the CMS yet."
        redLabel.numberOfLines = 0
        redLabel.font = UIFont.boldSystemFont(ofSize: 14)
        redLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        containerView.addSubview(redLabel)
        
        redImageView.alpha = 0.0
        view.addSubview(redImageView)
        
        otherButton.setTitle("Other Localisations", for: .normal)
        otherButton.layer.backgroundColor = (UIColor(hexString: "3892DF") ?? .blue).cgColor
        otherButton.layer.cornerRadius = 4.0
        otherButton.layer.borderColor = UIColor.white.cgColor
        otherButton.layer.borderWidth = 2.0
        otherButton.addTarget(self, action: #selector(handleAdditionalStrings), for: .touchUpInside)
        
        view.addSubview(otherButton)
        
        containerView.isUserInteractionEnabled = true
        
        otherLabel.font = UIFont.boldSystemFont(ofSize: 14)
        otherLabel.text = "View any localisations we didn't manage to highlight for you here"
        otherLabel.textAlignment = .center
        otherLabel.numberOfLines = 0
        otherLabel.lineBreakMode = .byWordWrapping
        otherLabel.textColor = UIColor(white: 1.0, alpha: 0.8)
        containerView.addSubview(otherLabel)
        
        view.addSubview(moreButton)
        otherButton.alpha = 0.0
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        moreButton.frame = CGRect(x: 8, y: UIApplication.shared.statusBarFrame.height + 6, width: 44, height: 44)
        
        let titleX = moreButton.frame.maxX + 8
        
        let constrainedSize = CGSize(width: view.bounds.width - titleX - 20, height: .greatestFiniteMagnitude)
        
        let titleSize = titleLabel.sizeThatFits(constrainedSize)
        titleLabel.frame = CGRect(x: titleX, y: 0, width: titleSize.width, height: titleSize.height)
        titleLabel.set(centerY: moreButton.center.y)
        
        let greenLabelSize = greenLabel.sizeThatFits(constrainedSize)
        greenLabel.frame = CGRect(x: titleX, y: moreButton.frame.maxY + 12, width: greenLabelSize.width, height: greenLabelSize.height)
        greenImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        greenImageView.center = CGPoint(x: moreButton.center.x, y: greenLabel.center.y)
        
        let amberLabelSize = amberLabel.sizeThatFits(constrainedSize)
        amberLabel.frame = CGRect(x: titleX, y: greenLabel.frame.maxY + 20, width: amberLabelSize.width, height: amberLabelSize.height)
        amberImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        amberImageView.center = CGPoint(x: moreButton.center.x, y: amberLabel.center.y)
        
        let redLabelSize = redLabel.sizeThatFits(constrainedSize)
        redLabel.frame = CGRect(x: titleX, y: amberLabel.frame.maxY + 20, width: redLabelSize.width, height: redLabelSize.height)
        redImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        redImageView.center = CGPoint(x: moreButton.center.x, y: redLabel.center.y)
        
        otherButton.frame = CGRect(x: redImageView.frame.minX, y: redLabel.frame.maxY + 20, width: view.bounds.width - redImageView.frame.minX * 2, height: 44)
        
        let otherLabelSize = otherLabel.sizeThatFits(CGSize(width: otherButton.frame.width - 44, height: .greatestFiniteMagnitude))
        otherLabel.frame = CGRect(x: otherButton.frame.minX + 22, y: otherButton.frame.maxY + 12, width: otherButton.frame.width - 44, height: otherLabelSize.height)
        
        backgroundView?.frame = view.bounds
    }

    @objc private func handleDismiss() {
        
        let quarterTurnAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        quarterTurnAnimation.values = [Double.pi/4, 0]
        quarterTurnAnimation.duration = 0.4
        quarterTurnAnimation.fillMode = .forwards
        quarterTurnAnimation.isRemovedOnCompletion = false
        quarterTurnAnimation.timingFunction = CAMediaTimingFunction.init(name: .easeInEaseOut)
        moreButton.layer.add(quarterTurnAnimation, forKey: "anim")
        
        UIView.animate(withDuration: 0.2, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.greenImageView.transform = CGAffineTransform(translationX: 0, y: self.moreButton.center.y - self.greenImageView.center.y)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.05, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.amberImageView.transform = CGAffineTransform(translationX: 0, y: self.moreButton.center.y - self.amberImageView.center.y)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.2, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.redImageView.transform = CGAffineTransform(translationX: 0, y: self.moreButton.center.y - self.redImageView.center.y)
        }, completion: nil)
        
        UIView.animate(withDuration: 0.9, delay: 0.1, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            
            self.backgroundView?.alpha = 0.0
            self.containerView.alpha = 0.0
            self.otherButton.alpha = 0.0
            
        }) { (complete) in
            
            guard complete else { return }
            self.dismissHandler?()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        guard !viewHasAppeared else { return }
        
        let quarterTurn = CAKeyframeAnimation(keyPath: "transform.rotation")
        quarterTurn.values = [0, 140.degreesToRadians, 225.degreesToRadians]
        quarterTurn.duration = 0.6
        quarterTurn.fillMode = .forwards
        quarterTurn.isRemovedOnCompletion = false
        quarterTurn.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        moreButton.layer.add(quarterTurn, forKey: "anim")
        
        otherButton.isUserInteractionEnabled = LocalisationController.shared.additionalLocalisedStrings?.isEmpty == false
        
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: {
            
            self.containerView.alpha = 1.0
            self.backgroundView?.alpha = 1.0
            
            if LocalisationController.shared.additionalLocalisedStrings?.isEmpty == false {
                self.otherButton.alpha = 1.0
            } else {
                self.otherButton.alpha = 0.2
            }
            
        }, completion: nil)
        
        greenImageView.transform = CGAffineTransform(translationX: 0, y: moreButton.center.y - greenImageView.center.y)
        amberImageView.transform = CGAffineTransform(translationX: 0, y: moreButton.center.y - amberImageView.center.y)
        redImageView.transform = CGAffineTransform(translationX: 0, y: moreButton.center.y - redImageView.center.y)
        
        greenImageView.alpha = 1.0
        amberImageView.alpha = 1.0
        redImageView.alpha = 1.0
        
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.redImageView.transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.2, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.amberImageView.transform = .identity
        }, completion: nil)
        
        UIView.animate(withDuration: 0.3, delay: 0.3, usingSpringWithDamping: 0.8, initialSpringVelocity: 1.0, options: .curveEaseOut, animations: {
            self.greenImageView.transform = .identity
        }, completion: nil)
        
        viewHasAppeared = true
    }
    
    @objc private func handleAdditionalStrings() {
        
        let additionalStringsAlert = UIAlertController(title: "Additional Localisations", message: nil, preferredStyle: .alert)
        
        LocalisationController.shared.additionalLocalisedStrings?.forEach({ (additionalString) in
            additionalStringsAlert.addAction(UIAlertAction(title: additionalString, style: .default, handler: { (_) in
                self.presentLocalisationEditViewControllerWith(localisation: additionalString)
            }))
        })
        
        additionalStringsAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(additionalStringsAlert, animated: true, completion: nil)
    }
    
    func presentLocalisationEditViewControllerWith(localisation: String) {
        
        let editViewController: LocalisationEditViewController
        if let localisation = LocalisationController.shared.CMSLocalisation(for: localisation) {
            editViewController = LocalisationEditViewController(withLocalisation: localisation)
        } else {
            editViewController = LocalisationEditViewController(withKey: localisation)
        }
        
        editViewController.delegate = self
        let navController = UINavigationController(rootViewController: editViewController)
        present(navController, animated: true, completion: nil)
    }
}

extension LocalisationExplanationViewController: LocalisationEditViewControllerDelegate {
    
    func editingCancelled(in viewController: LocalisationEditViewController) {
        
    }
    
    func editingSaved(in viewController: LocalisationEditViewController?) {
        LocalisationController.shared.editingSaved(in: nil)
    }
}
