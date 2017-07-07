//
//  PokemonTableViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

protocol PokemonTableViewCellDelegate {
	
	func tableViewCell(cell: PokemonTableViewCell, didTapItem atIndex: Int)
}

/// Cell for PokemonListItemView
class PokemonTableViewCell: StormTableViewCell {

	var delegate: PokemonTableViewCellDelegate?
	
	var items: [PokemonListItem] = [] {
		didSet {
			setupContentSize()
			reloadData()
		}
	}
	
	@IBOutlet weak private var scrollView: UIScrollView!
	
	private var itemViews: [TSCPokemonItemView] = []
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setupContentSize()
	}
	
	private let pokemonCellSize = CGSize(width: 57, height: 70)
	
	private let pokemonCellSpacing: CGFloat = 16.0
	
	private func setupContentSize() {
		
		let width: CGFloat = ((pokemonCellSize.width + pokemonCellSpacing) * CGFloat(items.count)) + pokemonCellSpacing
		scrollView.contentSize = CGSize(width: width, height: pokemonCellSize.height)
	}
	
	func reloadData() {
		
		self.itemViews.forEach { (itemView) in
			itemView.removeFromSuperview()
		}
		
		itemViews = items.enumerated().map({ (item) -> TSCPokemonItemView in
			
			let view = TSCPokemonItemView()
			view.frame = CGRect(
				x: ((pokemonCellSize.width + pokemonCellSpacing) * CGFloat(item.offset)) + pokemonCellSpacing,
				y: pokemonCellSpacing,
				width: pokemonCellSize.width,
				height: pokemonCellSize.height)
			view.imageView.image = item.element.image
			view.imageView.frame = view.bounds
			view.label.text = item.element.name
			view.button.tag = item.offset
			
			view.imageView.alpha = item.element.isInstalled ? 1.0 : 0.5
			
			view.button.addTarget(self, action: #selector(handleCellTap(sender:)), for: .touchUpInside)
			scrollView.addSubview(view)
			return view
		})
	}
	
	func handleCellTap(sender: UIButton) {
		delegate?.tableViewCell(cell: self, didTapItem: sender.tag)
	}
}
