//
//  StormObject.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 04/07/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// All objects used in storm must conform to the `StormObjectProtocol` either by subclassing TSCStormObject or by directly implementing the protocol methods
@objc public protocol StormObjectProtocol {
	
	/// The designated initialiser for a storm object
	///
	/// - Parameter dictionary: A dictionary representation of the storm item
	init(dictionary: [AnyHashable : Any])
}

/// A base class for all storm objects, implementing `StormObjectProtocol`. 
/// This class has a shared instance and allows for overriding default storm behaviour
open class StormObject: StormObjectProtocol {
	
	
	/// The designated initialiser for a storm object
	///
	/// - Parameter dictionary: A dictionary representation of the storm item
	required public init(dictionary: [AnyHashable : Any]) {
		
	}
}

/// A factory for generating storm objects
@objc(TSCStormObjectFactory)
public class StormObjectFactory: NSObject {
	
	/// Shared instance of StormObjectFactory
	/// This is the instance of StormObject that class overrides should be called on
	public static let shared = StormObjectFactory()
	
	//MARK: -
	//MARK: - Overriding
	//MARK: -
	private var stormOverrides: [AnyHashable: AnyClass] = [:]
	
	/// Overrides the class which will be initialised for any Storm base class
	///
	/// This method allows customising storm standard behaviours.
	/// Overriding a class here means that whenever Storm instantiates a class of this type it will use your replacement class.
	/// The overriding class should almost always subclass from the overriden class to ensure behaviour of your app isn't affected.
	///
	/// - Parameters:
	///   - originalClass: The orignal storm class to override
	///   - override: The class to instantiate in replacement of `originalClass`
	@objc(overrideClass:withClass:)
	public func override(class originalClass: AnyClass, with override: AnyClass) {
		
		// Because legacy storm objects work by subclassing their new counterparts, we need
		// to make sure they are converted to the new object otherwise overrides will fail
		// (because legacy items aren't publicly declared so can't be directly overriden)
		
		if let legacyStormObject = legacyStormClass(for: originalClass) {
			self.override(className: NSStringFromClass(legacyStormObject), with: override)
		}
		
		self.override(className: NSStringFromClass(originalClass), with: override)
	}
	
	/// Overrides the class which will be initialised for any Storm base class
	///
	/// This method allows customising storm standard behaviours.
	/// Overriding a class here means that whenever Storm instantiates a class of this type it will use your replacement class.
	/// The overriding class should almost always subclass from the overriden class to ensure behaviour of your app isn't affected.
	///
	/// - Parameters:
	///   - originalClassName: The name of the original class to override
	///   - override: The class to instantiate in replacement of `originalClass`
	@objc(overrideClassName:withClass:)
	public func override(className originalClassName: String, with override: AnyClass?) {
		if let overrideClass = override {
			stormOverrides[originalClassName] = overrideClass
		} else {
			stormOverrides[originalClassName] = nil
		}
	}
	
	/// Returns the Class (Whether overriden or not) for a given class key.
	///
	/// - Parameter classKey: The key for the required class
	public func `class`(for classKey: String) -> AnyClass? {
		
		// We need to prefix class name with ThunderCloud. as classes are namespaced in swift
		var className = "ThunderCloud." + classKey
		var _stormClass: AnyClass? = stormOverrides[className] ?? NSClassFromString(className)
		
		// Fall back to TSC\(className)
		if _stormClass == nil {
			className = "TSC"+classKey
			_stormClass = stormOverrides[className] ?? NSClassFromString(className)
		}
		
		// Fall back to classKey
		if _stormClass == nil {
			_stormClass = stormOverrides[classKey] ?? NSClassFromString(classKey)
		}
		
		return _stormClass
	}
	
	/// Returns an initialised `StormObjectProtocol` from a given dictionary representation returned from the CMS
	///
	/// - Parameters:
	///   - dictionary: The dictionary representation of the storm object
	public func stormObject(with dictionary: [AnyHashable : Any]) -> Any? {
		
		guard var className = dictionary["class"] as? String else {
			print("[Storm Factory] Warning - class property not found on storm object")
			return nil
		}
				
		// Double check for native pages (This is for when the root page (vector) is native)
		if className == "NativePage", let pageName = dictionary["name"] as? String {
			return TSCStormViewController.viewController(forNativePageName: pageName)
		}
		
		// Double check for native list items (This is for when a native list item is put into a storm page)
		if className == "NativeListItem", let listItemName = dictionary["name"] as? String {
			className = listItemName
		}
		
		// We need to prefix class name with ThunderCloud. as classes are namespaced in swift
		let _stormClass = self.class(for: className)
		
		guard let stormClass = _stormClass else {
			print("[Storm Factory] Warning - missing storm object for class: \(className)")
			return nil
		}
		
		if let stormObjectClass = stormClass as? StormObjectProtocol.Type {
			return stormObjectClass.init(dictionary: dictionary)
		} else if let objcClass = stormClass as? NSObject.Type {
			return objcClass.init()
		}
		
		print("[Storm Factory] Warning - couldn't initialise object of class \(className) as either a StormObjectProtocol or NSObject")
		return nil
	}
	
	//MARK: -
	//MARK: - Legacy Items
	//MARK: -
	
	private var legacyStormClassMap: [AnyHashable : String] {
		return [
			"TSCHeaderListItem":"ThunderCloud.HeaderListItemView",
			"TSCCollectionListItem":"ThunderCloud.CollectionListItemView",
			"TSCGridItem":"ThunderCloud.TSCGridCell",
			"TSCUnorderedListItem":"ThunderCloud.BulletListItemView",
			"TSCLogoListItem":"ThunderCloud.LogoListItemView",
			"TSCDescriptionListItem":"ThunderCloud.DescriptionListItemView",
			"TSCAnimatedImageListItem":"ThunderCloud.AnimatedImageListItemView",
			"TSCVideoListItem":"ThunderCloud.MultiVideoListItemView",
			"TSCCheckableListItem":"ThunderCloud.CheckableListItemView",
			"TSCToggleableListItem":"ThunderCloud.ToggleableListItemView",
			"TSCOrderedListItem":"ThunderCloud.AnnotatedListItemView",
			"TSCImageListItem":"ThunderCloud.ImageListItemView",
			"TSCQuizItem":"ThunderCloud.QuizQuestion",
			"TSCSliderQuizItem":"ThunderCloud.ImageSliderSelectionQuestion",
			"TSCAreaQuizItem":"ThunderCloud.AreaSelectionQuestion",
			"TSCTextQuizItem":"ThunderCloud.TextSelectionQuestion",
			"TSCImageQuizItem":"ThunderCloud.ImageSelectionQuestion",
			"TSCListItem":"ThunderCloud.ListItemView",
			"TSCStandardListItem":"ThunderCloud.StandardListItemView",
			"TSCSpotlightImageListItem":"ThunderCloud.SpotlightImageListItemView",
			"TSCList":"ThunderCloud.GroupView",
			"TSCStandardGridItem":"ThunderCloud.StandardGridCell",
			"TSCTextListItem":"ThunderCloud.TextListItemView",
			"TSCButtonListItem":"ThunderCloud.ButtonListItemView",
			"TSCSpotlightListItem":"ThunderCloud.SpotlightImageListItemView"
		]
	}
	
	private func legacyStormClass(for originalClass: AnyClass) -> AnyClass? {
		
		let className = NSStringFromClass(originalClass)
		if let legacyClassName = legacyStormClassMap[className] {
			return NSClassFromString(legacyClassName)
		} else if let legacyClassName = legacyStormClassMap["TSC"+className] {
			return NSClassFromString(legacyClassName)
		}
		
		guard let separatedClassName = className.components(separatedBy: ".").last else { return nil }
		
		if let legacyClassName = legacyStormClassMap[separatedClassName] {
			return NSClassFromString(legacyClassName)
		} else if let legacyClassName = legacyStormClassMap["TSC"+separatedClassName] {
			return NSClassFromString(legacyClassName)
		}
		
		return nil
	}
}
