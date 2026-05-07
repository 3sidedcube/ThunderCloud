//
//  PlaceholderViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A placeholder `UIViewController` which is shown in the detail of a `AccordionTabBarViewController` when there is nothing else to show in the detail view
open class PlaceholderViewController: UIViewController {
    
    private let titleLabel = UILabel()
    
    private let descriptionLabel = UILabel()
    
    private let imageView = UIImageView()
    
    init(placeholder: Placeholder) {
        
        super.init(nibName: nil, bundle: nil)
        self.placeholder = placeholder
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var placeholder: Placeholder? {
        didSet {
            
            titleLabel.text = placeholder?.title
            title = placeholder?.title
            
            navigationController?.navigationBar.setNeedsDisplay()
            
            descriptionLabel.text = placeholder?.description
            imageView.image = placeholder?.image?.image
            imageView.accessibilityLabel = placeholder?.image?.accessibilityLabel
            imageView.isAccessibilityElement = placeholder?.image?.accessibilityLabel != nil
            
            if isViewLoaded {
                view.setNeedsLayout()
            }
        }
    }
    
    open override func viewDidLoad() {
        
        super.viewDidLoad()
        
        title = placeholder?.title
        
        titleLabel.text = placeholder?.title
        titleLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 36, textStyle: .title1)
        titleLabel.textColor = UIColor(hexString: "4b4949")
        titleLabel.textAlignment = .center
        titleLabel.backgroundColor = .clear
        
        view.addSubview(titleLabel)
        
        descriptionLabel.text = placeholder?.description
        descriptionLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 20, textStyle: .subheadline)
        descriptionLabel.textColor = UIColor(hexString: "7b7b7f")
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.backgroundColor = .clear
        
        view.addSubview(descriptionLabel)
        
        imageView.image = placeholder?.image?.image
        imageView.accessibilityLabel = placeholder?.image?.accessibilityLabel
        imageView.isAccessibilityElement = placeholder?.image?.accessibilityLabel != nil
        imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        imageView.contentMode = .scaleAspectFill
        
        view.addSubview(imageView)
        
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
    }
    
    open override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        
        imageView.center = CGPoint(x: view.frame.width/2, y: view.frame.height/2 - imageView.frame.height/2)
        
        let width = view.frame.width/2
        
        titleLabel.frame = CGRect(x: width/2, y: view.frame.height/2, width: width, height: 50)
        
        let constrainedSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        let descriptionLabelSize = descriptionLabel.sizeThatFits(constrainedSize)
        
        descriptionLabel.frame = CGRect(x: (view.frame.width - descriptionLabelSize.width) / 2, y: titleLabel.frame.maxY + 15, width: descriptionLabelSize.width, height: descriptionLabelSize.height)
    }
}
