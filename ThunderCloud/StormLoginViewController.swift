//
//  StormLoginViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 15/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import UIKit
import ThunderBasics

/// A view controller which provides the user with an interface to login to their storm CMS account
class StormLoginViewController: UIViewController {
    
    /// Closure called when the user interacts with login
    typealias LoginCompletion = (_ sucessful: Bool, _ cancelled: Bool, _ error: Error?) -> Void
    
    /// A closure to be called when the user has made an attempt to log in or cancelled
    var completion: LoginCompletion?
    
    /// The reason for requesting a storm login, will be displayed on the login UI
    var loginReason: String?
    
    /// A view controller which will be shown inside the small white container view controller upon
    /// sucessful login
    var successViewController: UIViewController?
    
    /// Title label, displayed at the top of the container.
    @IBOutlet weak private var titleLabel: UILabel!
    
    /// Label which displays `loginReason` below the title label.
    @IBOutlet weak private var reasonLabel: UILabel!
    
    /// Input field for the user's username.
    @IBOutlet weak private var usernameField: TSCTextField!
    
    /// Input field for the user's password.
    @IBOutlet weak private var passwordField: TSCTextField!
    
    /// Button to login the user to the CMS.
    @IBOutlet weak private var loginButton: TSCButton!
    
    /// Button to activate 1Password extension to fill in user's details.
    @IBOutlet weak private var onePasswordButton: UIButton!
    
    /// A dark visual effect view which covers over the app underneath.
    @IBOutlet weak private var backgroundView: UIVisualEffectView!
    
    /// The white central container view which all UI is shown within.
    @IBOutlet weak private var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 4
            containerView.layer.masksToBounds = true
        }
    }
    
    /// Constraint from the bottom of container view to the bottom of the screen.
    /// Used to adjust the container view when keyboard shows/hides.
    @IBOutlet weak private var bottomConstraint: NSLayoutConstraint!
    
    private let authenticationController = AuthenticationController()
    
    /// Whether the user has been logged in
    private var isLoggedIn: Bool = false
    
    var keyboardObservers: [Any] = []
    
    deinit {
        keyboardObservers.forEach({
            NotificationCenter.default.removeObserver($0)
        })
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        reasonLabel.text = loginReason ?? "Log into your Storm account"
        reasonLabel.textColor = UIColor(hexString: "818181")
        
        configure(textField: usernameField)
        configure(textField: passwordField)
        
        let keyboardObserverNames: [NSNotification.Name] = [
            UIResponder.keyboardWillShowNotification,
            UIResponder.keyboardWillHideNotification,
            UIResponder.keyboardWillChangeFrameNotification
        ]
        
        keyboardObservers = keyboardObserverNames.map({
            NotificationCenter.default.addObserver(forName: $0, object: nil, queue: .main, using: { [weak self] (notification) in
                self?.updateBottomConstraint(with: notification)
            })
        })
        
        guard !OnePasswordExtension.shared().isAppExtensionAvailable() else {
            return
        }
        
        onePasswordButton.isHidden = true
        passwordField.rightInset = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.backgroundView.alpha = 1.0
            self.containerView.alpha = 1.0
            
        }, completion: nil)
    }
    
    /// Configure UI of the given `textField`
    ///
    /// - Parameter textField: `UITextField`
    private func configure(textField: UITextField) {
        textField.layer.borderColor = UIColor.stormBlue?.cgColor
        textField.layer.borderWidth = 1.0/UIScreen.main.scale
        textField.layer.cornerRadius = 4
        textField.layer.masksToBounds = true
        // Insets are set in storyboard (runtime attributes)
    }
    
    /// Updates bottom constraint (Moving inputs up and down) for a keyboard notification
    ///
    /// - Parameter keyboardNotification: The notification which should be used to update the constraint
    private func updateBottomConstraint(with keyboardNotification: Notification) {
        
        let hidden = keyboardNotification.name == UIResponder.keyboardWillHideNotification
        
        // Get information out of the notification
        guard let endFrameValue = keyboardNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let duration = keyboardNotification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        guard let curveValue = keyboardNotification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {  return }
        let curveOptions = UIView.AnimationOptions(rawValue: curveValue << 16)
        
        // Update the bottom constraint
        self.bottomConstraint.constant = hidden ? 12 : endFrameValue.height + 12
        
        // Animates the constraint change
        UIView.animate(withDuration: duration, delay: 0, options: curveOptions, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    /// Handles when the user has sucessfully logged in
    private func handleLoggedIn() {
        
        // Just in-case!
        loginError = nil
        
        // If we don't have a success view controller, simply dismiss calling completion
        guard let sucessViewController = successViewController else {
            dismissCallingCompletion()
            return
        }
        
        // If success VC doesn't have a view we should probably just dismiss,
        // otherwise we'll get a broken UI
        guard let childView = sucessViewController.view else {
            dismissCallingCompletion()
            return
        }
        
        childView.alpha = 0.0
        addChild(sucessViewController)
        containerView.addSubview(childView)
        
        if let gestureRecognizer = backgroundView.gestureRecognizers?.first {
            backgroundView.removeGestureRecognizer(gestureRecognizer)
        }
        
        // Constrain the success view controller to our container view
        childView.attachEdges(to: containerView)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            
            self.titleLabel.alpha = 0.0
            self.reasonLabel.alpha = 0.0
            self.passwordField.alpha = 0.0
            self.usernameField.alpha = 0.0
            self.loginButton.alpha = 0.0
            childView.alpha = 1.0
            
        }) { (complete) in
            
            guard complete else { return }
            
            self.titleLabel.removeFromSuperview()
            self.reasonLabel.removeFromSuperview()
            self.passwordField.removeFromSuperview()
            self.usernameField.removeFromSuperview()
            self.loginButton.removeFromSuperview()
            
            // Haven't been cancelled because this is the handleLogin function!
            self.completion?(self.isLoggedIn, false, self.loginError)
        }
    }
    
    /// Dismisses the login UI and calls the completion closure
    private func dismissCallingCompletion() {
        
        // Animate out ourselves, then call the completion block
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.backgroundView.alpha = 0.0
            self.containerView.alpha = 0.0
        }) { (complete) in
            guard complete else { return }
            // If we're not logged in, then user must have cancelled the login by tapping the background view
            self.completion?(self.isLoggedIn, !self.isLoggedIn, self.loginError)
        }
    }
    
    /// Resigns password field and username field as first responders
    private func resignResponsers() {
        
        if passwordField.isFirstResponder {
            passwordField.resignFirstResponder()
        }
        
        if usernameField.isFirstResponder {
            usernameField.resignFirstResponder()
        }
    }
    
    //MARK: - Action Handlers -
    
    /// Action handler for showing onepassword UI for filling in login details
    ///
    /// - Parameter sender: The button that triggered this action
    @IBAction func handle1Password(_ sender: UIButton) {
        
        var urlString = "app://\(Bundle.main.bundleIdentifier ?? "")"
        
        if let loginURLString = Bundle.main.object(forInfoDictionaryKey: "TSCStormLoginURL") as? String {
            urlString = loginURLString
        }
        
        OnePasswordExtension.shared().findLogin(forURLString: urlString, for: self, sender: sender) { (loginDictionary, error) in
            
            guard let loginDictionary = loginDictionary else { return }
            
            if let password = loginDictionary[AppExtensionPasswordKey] as? String {
                self.passwordField.text = password
            }
            
            if let username = loginDictionary[AppExtensionUsernameKey] as? String {
                self.usernameField.text = username
            }
        }
    }
    
    /// Any error which occured when logging the user in
    private var loginError: Error?
    
    /// Action handler for the login button
    ///
    /// - Parameter sender: The action creator
    @IBAction private func handleLogin(_ sender: TSCButton) {
        
        loginButton.isEnabled = false
        loginButton.alpha = 0.5
        
        guard let username = usernameField.text, let password = passwordField.text else {
            
            usernameField.layer.borderColor = usernameField.text == nil || usernameField.text!.isEmpty ? UIColor.stormRed?.cgColor : UIColor.stormBlue?.cgColor
            passwordField.layer.borderColor = passwordField.text == nil || passwordField.text!.isEmpty ? UIColor.stormRed?.cgColor : UIColor.stormBlue?.cgColor
            
            return
        }
        
        authenticationController.authenticateWith(username: username, password: password) { [weak self] (authorization, error) in
            
            guard let strongSelf = self else { return }
            
            strongSelf.loginError = error
            strongSelf.isLoggedIn = authorization != nil
            
            strongSelf.usernameField.layer.borderColor = strongSelf.isLoggedIn ? UIColor.stormGreen?.cgColor : UIColor.stormRed?.cgColor
            strongSelf.passwordField.layer.borderColor = strongSelf.isLoggedIn ? UIColor.stormGreen?.cgColor : UIColor.stormRed?.cgColor
            
            strongSelf.loginButton.isEnabled = true
            strongSelf.loginButton.alpha = 1.0
            
            strongSelf.resignResponsers()
            
            if strongSelf.isLoggedIn {
                strongSelf.handleLoggedIn()
            } else {
                // Call completion for the sake of user maybe wanting to handle this situation
                strongSelf.completion?(false, false, error)
            }
        }
    }
    
    /// Gesture recognizer handler for dismissing UI
    ///
    /// - Parameter sender: the tap gesture recognizer that triggered dismissal
    @IBAction private func handleDismissTap(_ sender: UITapGestureRecognizer) {
        
        resignResponsers()
        dismissCallingCompletion()
    }
}

// MARK: - UIColor + Extensions

extension UIColor {
    
    /// Storm blue color
    static let stormBlue = UIColor(hexString: "4A90E2")
    
    /// Storm green color
    static let stormGreen = UIColor(hexString: "72D33B")
    
    /// Storm red color
    static let stormRed = UIColor(hexString: "FF3B39")
}
