//
//  ListPageViewController.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 06/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import CoreServices
import ThunderBasics
import ThunderTable
import CoreSpotlight

// To save time, the `Video` type in storm has been re-used to provide audio
// upload to any given `ListPage`. We'll typealias here so it's not `as`
// confusing to consumers of `ThunderCloud`
public typealias Audio = Video

/// `ListPage` is a subclass of `TableViewController` that lays out storm table view content
open class ListPage: TableViewController, StormObjectProtocol, RowSelectable {
    
    //MARK: -
    //MARK: Public API
    //MARK: -
    
    /// An array of dictionaries which contain custom attributes for the `StormObject`
    public var attributes: [[AnyHashable : Any]]?
    
    /// The unique identifier for the storm page
    public let pageId: String?

    /// The audio file attached to the given page
    public let audioFiles: [Audio]?

    /// Returns the audio file from `audioFiles` for the user's current locale
    /// - Parameter fallback: Whether to fallback to other audio files if there isn't
    /// a file for the user's current locale
    /// - Returns: The audio file for the user's current in-app language
    public func currentLanguageAudioFile(fallback: Bool = true) -> Audio? {
        guard let audioFiles = audioFiles else { return nil }
        guard let currentLanguage = StormLanguageController.shared.currentLanguage else {
            return fallback ? audioFiles.first : nil
        }
        return audioFiles.first(where: {
            $0.localeString == currentLanguage
        }) ?? (fallback ? audioFiles.first : nil)
    }
    
    /// handleSelection is called when an item in the table view is selected.
    /// An action is performed based on the `StormLink` which is passed in with the selection.
    ///
    /// - Parameters:
    ///   - row: The row which was selected
    ///   - indexPath: The indexPath of that row
    ///   - tableView: The table view the selection happened at
    open func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView) {
        
        guard let stormRow = row as? ListItem, let link = stormRow.link else { return }
        navigationController?.push(link: link)
    }
    
    /// The internal page name for this page.
    /// Named pages can be used for native overrides and for identifying
    /// pages that may change ID with delta publishes.
    /// By default this is nil, but name can be added in the CMS
    public let pageName: String?
    
    public convenience init?(contentsOf url: URL) {
        
        guard let data = try? Data(contentsOf: url) else { return nil }
        guard let pageObject = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        guard let pageDictionary = pageObject as? [AnyHashable : Any] else { return nil }
        
        self.init(dictionary: pageDictionary)
    }
    
    /// The dictionary representation of the page.
    /// This is stored so we can put off the rendering of the page until viewDidLoad
    /// and avoid any issues with reloading the collection view in init.
    private var dictionary: [AnyHashable : Any] = [:]
    
    public required init(dictionary: [AnyHashable : Any]) {
        
        self.dictionary = dictionary
        
        pageName = dictionary["name"] as? String
        
        if let pageNumberId = dictionary["id"] as? Int {
            pageId = "\(pageNumberId)"
        } else {
            pageId = dictionary["id"] as? String
        }

        if let audioObjects = dictionary["audio"] as? [[AnyHashable: Any]] {
            audioFiles = audioObjects.compactMap({ Audio(dictionary: $0) })
        } else {
            audioFiles = nil
        }
        
        super.init(style: .grouped)
        
        attributes = dictionary["attributes"] as? [[AnyHashable : Any]]
        
        if let titleDict = dictionary["title"] as? [AnyHashable : Any], let titleContentKey = titleDict["content"] as? String {
            title = StormLanguageController.shared.string(forKey: titleContentKey)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        pageId = nil
        pageName = nil
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    //MARK: View Controller Lifecycle
    //MARK: -
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = ThemeManager.shared.theme.backgroundColor
        
        guard let children = dictionary["children"] as? [[AnyHashable : Any]] else { return }
        
        data = children.compactMap { (child) -> Section? in
            return StormObjectFactory.shared.stormObject(with: child) as? Section
        }
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        NotificationCenter.default.sendAnalyticsScreenView(
            Analytics.ScreenView(
                screenName: title,
                navigationController: navigationController
            )
        )
    }
    
    open override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerFooterView = view as? UITableViewHeaderFooterView else { return }
        headerFooterView.textLabel?.textColor = ThemeManager.shared.theme.darkGrayColor
    }
    
    open override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let headerFooterView = view as? UITableViewHeaderFooterView else { return }
        headerFooterView.textLabel?.textColor = ThemeManager.shared.theme.darkGrayColor
    }
    
    //MARK: -
    //MARK: Accessibility
    //MARK:
    
    open override func accessibilitySettingsDidChange() {
        
        navigationController?.navigationBar.barTintColor = ThemeManager.shared.theme.navigationBarBackgroundColor
        navigationController?.navigationBar.tintColor = ThemeManager.shared.theme.navigationBarTintColor
        
        
    }
    
    //MARK: -
    //MARK: TSCCoreSpotlightIndexItem
    //MARK: -
    
}

// MARK: - Core spotlight indexing
open class IndexableListPage: CoreSpotlightIndexable, StormObjectProtocol {
    
    var title: String?
    
    let dictionary: [AnyHashable : Any]
    
    public required init?(dictionary: [AnyHashable : Any]) {
        
        self.dictionary = dictionary
        
        if let titleDict = dictionary["title"] as? [AnyHashable : Any], let titleContentKey = titleDict["content"] as? String {
            title = StormLanguageController.shared.string(forKey: titleContentKey)
        }
    }
    
    public var searchableAttributeSet: CSSearchableItemAttributeSet? {
        
        guard let children = dictionary["children"] as? [[AnyHashable : Any]] else { return nil }
        let sections = children.compactMap { (child) -> Section? in
            return StormObjectFactory.shared.indexableStormObject(with: child) as? Section
        }
        
        guard !sections.isEmpty else { return nil }
        
        let searchableAttributeSet = CSSearchableItemAttributeSet(itemContentType: String(kUTTypeData))
        searchableAttributeSet.title = title
        
        let rows: [Row] = sections.flatMap({ (section) -> [Row] in
            return section.rows
        })
        
        // Loop through each row until we've added a title and image to the searchable attribute set (Can't use for each as we need to break out)
        for row in rows {
            
            if let rowTitle = row.title, searchableAttributeSet.contentDescription == nil {
                
                if let subtitle = row.subtitle {
                    searchableAttributeSet.contentDescription = rowTitle + "\n\n\(subtitle)"
                } else {
                    searchableAttributeSet.contentDescription = rowTitle
                }
            }
            
            if let rowImage = row.image, searchableAttributeSet.thumbnailData == nil {
                searchableAttributeSet.thumbnailData = rowImage.jpegData(compressionQuality: 0.1)
            }
            
            if searchableAttributeSet.contentDescription != nil && searchableAttributeSet.thumbnailData != nil {
                break
            }
        }
        
        return searchableAttributeSet
    }
}
