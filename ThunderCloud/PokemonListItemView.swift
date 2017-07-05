//
//  PokemonListItemView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit

class PokemonListItemView: TitleListItem {

	let items: [PokemonListItem] = {
		
		var currentAppURLScheme: String?
		if let bundleURLTypes = Bundle.main.infoDictionary["CFBundleURLTypes"] as? [[AnyHashable : Any]], let bundleURLSchemes = bundleURLTypes["CFBundleURLSchemes"] as? [String] {
			currentAppURLScheme = bundleURLTypes.first
		}
		
		var localItems: [PokemonListItem] = []
		let bundle = Bundle(for: self.self)
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCPFA://",
			"name": "Pet",
			"image": UIImage(named: "pet_first_aid_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://669579655"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCTRC://",
			"name": "Team",
			"image": UIImage(named: "team_red_cross_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://669579655"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCFA://",
			"name": "First Aid",
			"image": UIImage(named: "first_aid_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://529160691"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCWSWIM://",
			"name": "Swim",
			"image": UIImage(named: "swim_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://785356681"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCTOR://",
			"name": "Tornado",
			"image": UIImage(named: "tornado_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://602724318"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCHUR://",
			"name": "Hurricane",
			"image": UIImage(named: "hurricane_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://545689128"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCHEQ://",
			"name": "Earthquake",
			"image": UIImage(named: "earthquake_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://557946227"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCWIL://",
			"name": "Wildfire",
			"image": UIImage(named: "wildfire_icon.png", in: bundle, compatibleWith: nil),
			"appStoreLink": "itunes://566584692"
		]))
		
		if let currentLink = currentAppURLScheme {
			return localItems.filter({ (item) -> Bool in
				return item.localLink.absoluteString !== currentLink+"://"
			})
		} else {
			return localItems
		}
	}()
	
	required init(dictionary: [AnyHashable : Any], parentObject: StormObjectProtocol?) {
		super.init(dictionary: dictionary, parentObject: parentObject)
		
		title = "This was a triumph"
	}
	
	override var cellClass: AnyClass? {
		return PokemonTableViewCell.self
	}
}
