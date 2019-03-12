//
//  ListItem.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import UIKit
import ThunderTable

/// A protocol that allows view controllers (And other objects if you wish) respond to row selection!
public protocol RowSelectable {
    /// handleSelection is called when an item in the table view is selected.
    /// An action is performed based on the `StormLink` which is passed in with the selection.
    ///
    /// - Parameters:
    ///   - row: The row which was selected
    ///   - indexPath: The indexPath of that row
    ///   - tableView: The table view the selection happened at
    func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView)
}

/// ListItem is the base object for displaying table rows in storm.
/// It complies to the `Row` protocol
open class ListItem: StormObject, Row {
    
    open var accessoryType: UITableViewCell.AccessoryType?
    
    /// Whether the row should display separators when rendered in the UITableView
    open var displaySeparators: Bool = true
    
    /// The title of the row
    open var title: String?
    
    /// The subtitle of the row
    /// The subtitle gets displayed under the title
    open var subtitle: String?
    
    /// A `StormLink` which determines what the row does when it is selected
    open var link: StormLink?
    
    /// The image for the row
    /// This is placed on the left hand side of the cell
    open var image: UIImage?
    
    /// The row's title text color
    open var titleTextColor: UIColor?
    
    /// The row's detail text color
    open var detailTextColor: UIColor?
    
    /// The `UINavigationController` of the view controller the row is displayed in
    public weak var parentNavigationController: UINavigationController?
    
    /// The `UITableViewController` that the row is displayed in
    public weak var parentViewController: TableViewController?
    
    required public init(dictionary: [AnyHashable : Any]) {
        
        super.init(dictionary: dictionary)
        
        if let titleDict = dictionary["title"] as? [AnyHashable : Any] {
            title = StormLanguageController.shared.string(for: titleDict)
        }
        
        if let subtitleDict = dictionary["description"] as? [AnyHashable : Any] {
            subtitle = StormLanguageController.shared.string(for: subtitleDict)
        }
        
        image = StormGenerator.image(fromJSON: dictionary["image"])
        
        if let linkDicationary = dictionary["link"] as? [AnyHashable : Any] {
            link = StormLink(dictionary: linkDicationary)
        }
    }
    
    open func configure(cell: UITableViewCell, at indexPath: IndexPath, in tableViewController: TableViewController) {
        
        parentNavigationController = tableViewController.navigationController
        parentViewController = tableViewController
        
        if link == nil {
            cell.accessoryType = .none
        }
        
        if let stormCell = cell as? StormTableViewCell {
            stormCell.parentViewController = tableViewController
        }
        
        if let titleTextColor = titleTextColor {
            cell.textLabel?.textColor = titleTextColor
            if let tCell = cell as? TableViewCell {
                tCell.cellTextLabel?.textColor = titleTextColor
            }
        }
        
        if let detailTextColor = detailTextColor {
            cell.detailTextLabel?.textColor = detailTextColor
            if let tCell = cell as? TableViewCell {
                tCell.cellDetailLabel?.textColor = detailTextColor
            }
        }
        
        
        if let tableCell = cell as? TableViewCell {
            
            tableCell.cellTextLabel?.isHidden = title == nil || title!.isEmpty
            tableCell.cellDetailLabel?.isHidden = subtitle == nil || subtitle!.isEmpty
            
            tableCell.cellImageView?.isHidden = image == nil && imageURL == nil
            tableCell.cellTextLabel?.font = ThemeManager.shared.theme.cellTitleFont
            tableCell.cellDetailLabel?.font = ThemeManager.shared.theme.cellDetailFont
            tableCell.textLabel?.font = ThemeManager.shared.theme.cellTitleFont
            tableCell.detailTextLabel?.font = ThemeManager.shared.theme.cellDetailFont
        }
    }
    
    open var cellClass: UITableViewCell.Type? {
        return StormTableViewCell.self
    }
    
    open var padding: CGFloat? {
        return 12.0
    }
    
    open var useNibSuperclass: Bool {
        return true
    }
    
    open var estimatedHeight: CGFloat? {
        return nil
    }
    
    open func handleSelection(of row: Row, at indexPath: IndexPath, in tableView: UITableView) {
        
        guard let parentNavigationController = parentNavigationController else { return }
        
        var rowSelectable: RowSelectable?
        
        switch parentNavigationController.visibleViewController {
        case let accordionTabBarViewController as AccordionTabBarViewController:
            rowSelectable = accordionTabBarViewController.selectedViewController as? RowSelectable
        case let tabbedViewController as NavigationTabBarViewController:
            rowSelectable = tabbedViewController.selectedViewController as? RowSelectable
        case let _listPage as RowSelectable:
            rowSelectable = _listPage
        case let tabBarController as UITabBarController:
            rowSelectable = tabBarController.selectedViewController as? RowSelectable
        case let navigationController as UINavigationController:
            rowSelectable = navigationController.visibleViewController as? RowSelectable
        default:
            return
        }
        
        rowSelectable?.handleSelection(of: row, at: indexPath, in: tableView)
    }
    
    open func height(constrainedTo size: CGSize, in tableView: UITableView) -> CGFloat? {
        return nil
    }
    
    open var selectionHandler: SelectionHandler? = { (row, wasSelection, indexPath, tableView) -> Void in
        
        guard let listItem = row as? ListItem, wasSelection else { return }
        
        listItem.handleSelection(of: row, at: indexPath, in: tableView)
    }
    
    open var selectionStyle: UITableViewCell.SelectionStyle? {
        return link != nil ? UITableViewCell.SelectionStyle.default : UITableViewCell.SelectionStyle.none
    }
}
