//
//  PokemonTableViewCell.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 05/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

protocol PokemonTableViewCellDelegate {
	
	func tableViewCell(cell: PokemonTableViewCell, didTap itemAtIndex: Int)
}

/// Cell for PokemonListItemView
class PokemonTableViewCell: TableViewCell {

	var delegate: PokemonTableViewCellDelegate?
	
	var items: [PokemonListItem]?
	
	func height(for numberOfItems: Int, with width: CGFloat) -> CGFloat {
		return 0.0
	}
	
	
}
