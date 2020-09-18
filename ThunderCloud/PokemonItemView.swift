//
//  PokemonItemView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 03/05/2019.
//  Copyright © 2019 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// `PokemonItemView` is a view which represents an app inside a `PokemonTableViewCell`
class PokemonItemView: UIView {

    static let ImageSize = CGSize(width: 57, height: 57)
    
    /// A button which gets laid out over the top of the view to handle selection
    let overlayButton: UIButton
    
    /// An image view that shows the app's icon
    let imageView: UIImageView
    
    /// A label that is used to display the name of the app
    let nameLabel: UILabel
    
    override init(frame: CGRect) {
        
        imageView = UIImageView(frame: .zero)
        overlayButton = UIButton(frame: .zero)
        nameLabel = UILabel(frame: .zero)
        
        super.init(frame: frame)
        
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 14
        addSubview(imageView)
        
        overlayButton.frame = bounds
        overlayButton.contentMode = .scaleAspectFit
        overlayButton.imageView?.isHidden = false
        addSubview(overlayButton)
        
        nameLabel.backgroundColor = .clear
        nameLabel.textAlignment = .center
        nameLabel.font = ThemeManager.shared.theme.dynamicFont(ofSize: 10, textStyle: .caption2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageView = UIImageView(frame: .zero)
        overlayButton = UIButton(frame: .zero)
        nameLabel = UILabel(frame: .zero)
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(origin: .zero, size: PokemonItemView.ImageSize)
        overlayButton.frame = CGRect(origin: .zero, size: PokemonItemView.ImageSize)
        nameLabel.frame = CGRect(x: 0, y: bounds.height - 12, width: bounds.width, height: 12)
    }
}
