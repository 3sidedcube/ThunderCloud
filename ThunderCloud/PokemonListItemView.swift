//
//  PokemonListItemView.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

class PokemonListItemView: TitleListItem {

	let items: [PokemonListItem] = {
		
		var currentAppURLScheme: String?
		if let bundleURLTypes = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[AnyHashable : Any]], let bundleURLSchemes = bundleURLTypes.first?["CFBundleURLSchemes"] as? [String] {
			currentAppURLScheme = bundleURLSchemes.first
		}
		
		var localItems: [PokemonListItem] = []
		let bundle = Bundle(for: PokemonListItemView.self)
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCPFA://",
			"name": "Pet",
			"image": UIImage(named: "pet_first_aid_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://669579655"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCTRC://",
			"name": "Team",
			"image": UIImage(named: "team_red_cross_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://669579655"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCFA://",
			"name": "First Aid",
			"image": UIImage(named: "first_aid_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://529160691"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCWSWIM://",
			"name": "Swim",
			"image": UIImage(named: "swim_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://785356681"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCTOR://",
			"name": "Tornado",
			"image": UIImage(named: "tornado_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://602724318"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCHUR://",
			"name": "Hurricane",
			"image": UIImage(named: "hurricane_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://545689128"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCHEQ://",
			"name": "Earthquake",
			"image": UIImage(named: "earthquake_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://557946227"
		]))
		
		localItems.append(PokemonListItem(dictionary: [
			"localLink": "ARCWIL://",
			"name": "Wildfire",
			"image": UIImage(named: "wildfire_icon.png", in: bundle, compatibleWith: nil) ?? "",
			"appStoreLink": "itunes://566584692"
		]))
		
		if let currentLink = currentAppURLScheme {
			return localItems.filter({ (item) -> Bool in
				guard let localURL = item.localLink else { return false }
				return localURL.absoluteString != currentLink+"://"
			})
		} else {
			return localItems
		}
	}()
	
	required init(dictionary: [AnyHashable : Any]) {
		
		super.init(dictionary: dictionary)
		title = "This was a triumph"
	}
	
	override var cellClass: AnyClass? {
		return PokemonTableViewCell.self
	}
	
	override func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
		
		super.configure(cell: cell, at: indexPath, in: tableViewController)
	
		guard let pokemonCell = cell as? PokemonTableViewCell else { return }
		
		pokemonCell.items = items
		pokemonCell.delegate = self
	}
	
	override var accessoryType: UITableViewCellAccessoryType? {
		get {
			return UITableViewCellAccessoryType.none
		}
		set {}
	}
	
	override open var selectionStyle: UITableViewCellSelectionStyle? {
		get {
			return UITableViewCellSelectionStyle.none
		}
		set {}
	}
}

extension PokemonListItemView: PokemonTableViewCellDelegate {
	
	func tableViewCell(cell: PokemonTableViewCell, didTapItem atIndex: Int) {
		
		if atIndex < items.count {
			
			let item = items[atIndex]
			
			if item.isInstalled, let localLink = item.localLink {
				
				let alertViewController = UIAlertController(
					title: "Switching Apps".localised(with: "_COLLECTION_APP_CONFIRMATION_TITLE"),
					message: "You will now be taken to the app you have selected".localised(with: "_COLLECTION_APP_CONFIRMATION_MESSAGE"),
					preferredStyle: .alert)
				
				alertViewController.addAction(UIAlertAction(
					title: "Okay".localised(with: "_COLLECTION_APP_CONFIRMATION_OKAY"),
					style: .default,
					handler: { (action) in
						
						NotificationCenter.default.sendStatEventNotification(category: "Collect them all", action: "Open", label: nil, value: nil, object: self)
						UIApplication.shared.open(localLink, options: [:], completionHandler: nil)
					}
				))
				
				alertViewController.addAction(UIAlertAction(
					title: "Cancel".localised(with: "_COLLECTION_APP_CONFIRMATION_CANCEL"),
					style: .default,
					handler: nil))
				
				parentNavigationController?.present(alertViewController, animated: true, completion: nil)
				
			} else if !item.isInstalled, let appStoreLink = item.appStoreLink {
				
				NotificationCenter.default.sendStatEventNotification(category: "Collect them all", action: "App Store", label: nil, value: nil, object: self)
				UINavigationBar.appearance().tintColor = ThemeManager.shared.theme.titleTextColor
				
				let link = TSCLink()
				link.url = appStoreLink
				self.link = link
				
				parentNavigationController?.push(link)
			}
		}
	}
}
