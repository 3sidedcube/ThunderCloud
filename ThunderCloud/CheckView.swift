//
//  CheckView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 07/08/2017.
//  Copyright © 2017 3sidedcube. All rights reserved.
//

import UIKit
import ThunderTable

@IBDesignable
class CheckView: UIControl {
	
	/// The corner radius of the view
	@IBInspectable public var borderRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			innerView?.cornerRadius = newValue
		}
	}
	
	/// The identifier for the check view.
	///
	/// This is used when saving the `CheckView`'s state to `UserDefaults` using `setOn:animated:saveState` so make sure if you do want to save the state you always provide the same identifier
	public var checkIdentifier: Int? {
		didSet {
			guard let identifier = checkIdentifier else { return }
			let isOn = UserDefaults.standard.bool(forKey: "TSCCheckItem\(identifier)")
			set(on: isOn, animated: false, saveState: false)
		}
	}

	/// The view displayed when the `CheckView`'s state is 'on'
	private var innerView: UIView?
	
	/// The container view for the `CheckView`
	/// By default this is a transparent circular view with a border
	private var outerView: UIView?
	
	/// The colour of the innerView, determines the fill colour of the innerView when the `CheckView`'s state is 'on'
	@objc dynamic var onTintColor: UIColor? {
		get {
			return _onTintColor
		}
		set {
			if _isOn {
				outerView?.backgroundColor = newValue
			}
			_onTintColor = newValue
		}
	}
	
	@objc dynamic override var tintColor: UIColor! {
		get {
			return _tintColor
		}
		set {
			if !isOn {
				outerView?.backgroundColor = newValue
			}
			_tintColor = newValue
		}
	}
	
	/// Keep track of this because we need it in the animation
	private var _tintColor: UIColor?
	
	/// Keep track of this because we need it in the animation
	private var _onTintColor: UIColor?
	
	private var _isOn: Bool = false
	
	/// Whether the `CheckView` is currently 'ticked' or 'toggled to on'
	var isOn: Bool {
		set {
			set(on: newValue, animated: false)
		}
		get {
			return _isOn
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		
		guard innerView == nil else { return }
		
		outerView = UIView(frame: bounds)
		outerView?.cornerRadius = borderRadius
		addSubview(outerView!)
		
		innerView = UIView(frame: bounds.insetBy(dx: 1.5, dy: 1.5))
		innerView?.cornerRadius = borderRadius - 3
		innerView?.backgroundColor = .white
		addSubview(innerView!)
		
		onTintColor = ThemeManager.shared.theme.mainColor
		if tintColor == nil {
			tintColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0)
		}
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
		addGestureRecognizer(tapGesture)
		
		set(on: false, animated: false)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
	}
	
	@objc func handleTap(sender: UITapGestureRecognizer) {
		set(on: !_isOn, animated: true, saveState: true)
	}
	
	/// Used to change the state of the `CheckView`
	///
	/// - Parameters:
	///   - on: Whether the state of the view should be 'on' or 'off'
	///   - animated: Whether the change should visually animate or not
	///   - saveState: Whether the change of state should be saved to the `UserDefaults`
	func set(on: Bool, animated: Bool, saveState: Bool = true) {
		
		guard on != _isOn else {
			return
		}
		
		_isOn = on
		let duration: TimeInterval = 0.25
		
		if !on {
			
			if animated {
				UIView.animate(withDuration: duration, animations: {
					self.outerView?.backgroundColor = self.tintColor
					self.innerView?.transform = .identity
				})
			} else {
				self.outerView?.backgroundColor = self.tintColor
				innerView?.transform = .identity
			}
			sendActions(for: .valueChanged)
			
		} else {
			
			if animated {
				UIView.animate(withDuration: duration * 2, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
					self.outerView?.backgroundColor = self.onTintColor
					self.innerView?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
				})
			} else {
				self.outerView?.backgroundColor = self.onTintColor
				innerView?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
			}
			
			sendActions(for: .valueChanged)
		}
		
		guard let checkIdentifier = checkIdentifier, saveState else { return }
		UserDefaults.standard.set(on, forKey: "TSCCheckItem\(checkIdentifier)")
	}
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		if isUserInteractionEnabled {
			return super.point(inside: point, with: event)
		} else {
			return false
		}
	}
}
