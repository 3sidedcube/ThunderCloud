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
public class CheckView: UIControl {
	
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
    
    /// The image view used to display the actual check contents
    private var imageView: UIImageView?
	
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
	
    public override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}
	
	private func setup() {
		
        let imageView = UIImageView(image: (#imageLiteral(resourceName: "check-off") as StormImageLiteral).image)
        self.imageView = imageView
		addSubview(imageView)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
		addGestureRecognizer(tapGesture)
		
		set(on: false, animated: false)
	}
	
    public override func layoutSubviews() {
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
        
        if animated {
            UIView.animate(withDuration: duration, animations: {
                self.imageView?.image = ((on ? #imageLiteral(resourceName: "check-on"): #imageLiteral(resourceName: "check-off")) as StormImageLiteral).image
            })
        } else {
            imageView?.image = ((on ? #imageLiteral(resourceName: "check-on"): #imageLiteral(resourceName: "check-off")) as StormImageLiteral).image
        }
        
        sendActions(for: .valueChanged)
        
		guard let checkIdentifier = checkIdentifier, saveState else { return }
		UserDefaults.standard.set(on, forKey: "TSCCheckItem\(checkIdentifier)")
	}
	
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		if isUserInteractionEnabled {
			return super.point(inside: point, with: event)
		} else {
			return false
		}
	}
}
