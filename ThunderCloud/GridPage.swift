//
//  GridPage.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 16/02/2018.
//  Copyright © 2018 threesidedcube. All rights reserved.
//

import ThunderCollection
import ThunderTable

/// A subclass of `CollectionViewController` for displaying a CMS grid page
open class GridPage: CollectionViewController, StormObjectProtocol {
	
	/// An array of dictionaries which contain custom attributes for the `StormObject`
	public var attributes: [[AnyHashable : Any]]?
	
    /// The dictionary representation of the page.
    /// This is stored so we can put off the rendering of the page until viewDidLoad
    /// and avoid any issues with reloading the collection view in init.
    private var dictionary: [AnyHashable : Any] = [:]
	
	/// The unique identifier for the storm page
	public let pageId: String?
	
	/// The internal name for this page.
	/// Named pages can be used for native overrides and for identifying pages
	/// whose id may change with delta publishes. By default pages do not have
	/// names but they can be added in the CMS.
	public let pageName: String?
	
	public convenience init?(contentsOf url: URL) {
		
		guard let data = try? Data(contentsOf: url) else { return nil }
		guard let pageObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
		guard let pageDictionary = pageObject as? [AnyHashable : Any] else { return nil }
		
		self.init(dictionary: pageDictionary)
	}

	required public init?(dictionary: [AnyHashable : Any]) {
		
		self.dictionary = dictionary
		
		pageName = dictionary["name"] as? String
		
		if let pageNumberId = dictionary["id"] as? Int {
			pageId = "\(pageNumberId)"
		} else {
			pageId = dictionary["id"] as? String
		}
		
		super.init(collectionViewLayout: UICollectionViewFlowLayout())
		
		attributes = dictionary["attributes"] as? [[AnyHashable : Any]]
		
		if let titleDict = dictionary["title"] as? [AnyHashable : Any], let titleContentKey = titleDict["content"] as? String {
			title = StormLanguageController.shared.string(forKey: titleContentKey)
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		
		pageId = nil
		pageName = nil
		super.init(coder: aDecoder)
	}
    
    private var quizCompletedObserver: Any?
    
    private var isDirty = false
    
    deinit {
        guard let quizCompletedObserver = quizCompletedObserver else { return }
        NotificationCenter.default.removeObserver(quizCompletedObserver)
    }
	
	open override func viewDidLoad() {
		
		super.viewDidLoad()
        
        columns = 2
        
		collectionView?.backgroundColor = ThemeManager.shared.theme.backgroundColor
		collectionView?.alwaysBounceVertical = true
        
        quizCompletedObserver = NotificationCenter.default.addObserver(forName: QUIZ_COMPLETED_NOTIFICATION, object: nil, queue: .main, using: { [weak self] (notification) in
            self?.isDirty = true
        })
		
		guard let children = (dictionary["grid"] as? [AnyHashable : Any])?["children"] as? [[AnyHashable : Any]] else { return }
		
		let items = children.compactMap { (child) -> CollectionItemDisplayable? in
			return StormObjectFactory.shared.stormObject(with: child) as? CollectionItemDisplayable
		}
		
		let section = CollectionSection(items: items) { [weak self] (item, selected, indexPath, collectionView) -> (Void) in
			self?.handleSelection(of: item, at: indexPath, in: collectionView)
		}
		data = [section]
	}
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard isDirty else { return }
        collectionView?.reloadData()
        isDirty = false
    }
	
	open override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		guard let title = title else { return }
        NotificationCenter.default.sendAnalyticsScreenView(Analytics.ScreenView(screenName: title, navigationController: navigationController))
	}
	
	/// handleSelection is called when an item in the collection view is selected.
	///
	/// An action is performed based on the `StormLink` which is passed in with the item.
	///
	/// - Parameters:
	///   - item: The item which was selected
	///   - indexPath: The indexPath of that item
	///   - collectionView: The collection view the selection happened in
	open func handleSelection(of item: CollectionItemDisplayable, at indexPath: IndexPath, in collectionView: UICollectionView?) {
		
		guard let gridItem = item as? GridItem, let link = gridItem.link else { return }
		navigationController?.push(link: link)
	}
}
