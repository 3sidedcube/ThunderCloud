//
//  StormLink.swift
//  ThunderCloud
//
//  Created by Simon Mitchell on 02/11/2017.
//  Copyright © 2017 threesidedcube. All rights reserved.
//

import Foundation

/// StormLink is an object representation of a storm link (think url). This url can be a reference to a storm page, a website, details of an SMS, email and various other types.
///
/// Navigating between storm views is best handled using `TSCLink`
open class StormLink: NSObject, StormObjectProtocol {
    
    public enum LinkClass: String {
        case app = "AppLink"
        case call = "CallLink"
        case email = "EmailLink"
        case emergency = "EmergencyLink"
        case external = "ExternalLink"
        case `internal` = "InternalLink"
        case localised = "LocalisedLink"
        case native = "NativeLink"
        case sms = "SmsLink"
        case share = "ShareLink"
        case timer = "TimerLink"
        case unknown
        case uri = "UriLink"
        case url
    }
    
    //MARK: - Init methods -
    
    /// Initialises with a CMS representation of a link
    ///
    /// - Parameter dictionary: A Link dictionary that you intend to push the user to
    public required init?(dictionary: [AnyHashable : Any]) {
        // Keep this around otherwise get compiler errors using `linkClass` before all members initialised
        let _linkClass = LinkClass(rawValue: dictionary["class"] as? String ?? "unknown") ?? .unknown
        linkClass = _linkClass
        
        super.init()
        
        configure(with: dictionary, languageController: StormLanguageController.shared)
        
        guard url != nil
            || linkClass == .app
            || linkClass == .sms
            || linkClass == .emergency
            || linkClass == .share
            || linkClass == .timer
            || linkClass == .external
            || linkClass == .uri else {
                return nil
        }
    }
    
    public init?(dictionary: [AnyHashable: Any], languageController: StormLanguageController = StormLanguageController.shared) {
        // Keep this around otherwise get compiler errors using `linkClass` before all members initialised
        let _linkClass = LinkClass(rawValue: dictionary["class"] as? String ?? "unknown") ?? .unknown
        linkClass = _linkClass
        
        super.init()
        
        configure(with: dictionary, languageController: languageController)
        
        guard url != nil
            || linkClass == .app
            || linkClass == .sms
            || linkClass == .emergency
            || linkClass == .share
            || linkClass == .timer
            || linkClass == .external
            || linkClass == .uri else {
                return nil
        }
    }
    
    public func configure(with dictionary: [AnyHashable: Any], languageController: StormLanguageController) {
        let _linkClass = LinkClass(rawValue: dictionary["class"] as? String ?? "unknown") ?? .unknown
        linkClass = _linkClass
        
        url = URL(string: (dictionary["destination"] as? String)?.replacingOccurrences(of: " ", with: "") ?? "")
        id = dictionary["id"] as? Int
        
        if let titleDict = dictionary["title"] as? [AnyHashable : Any] {
            title = languageController.string(for: titleDict)
        } else {
            title = nil
        }
        
        if let bodyDictionary = dictionary["body"] as? [AnyHashable : Any] {
            body = languageController.string(for: bodyDictionary)
        } else {
            body = nil
        }
        
        recipients = dictionary["recipients"] as? [String]
        appIdentityIdentifier = dictionary["identifier"] as? String
        
        // Correct the destination parameter on a native link!
        if _linkClass == .native {
            destination = (dictionary["destination"] as? String)?.components(separatedBy: "/").last
        } else {
            destination = dictionary["destination"] as? String
        }
        
        if let durationInt = dictionary["duration"] as? Int {
            duration = TimeInterval(durationInt) / 1000
        } else if let durationDouble = dictionary["duration"] as? TimeInterval {
            duration = durationDouble / 1000
        } else if let durationString = dictionary["duration"] as? String {
            duration = TimeInterval(durationString)
        } else {
            duration = nil
        }
        
        if linkClass == .localised {
            localise(with: dictionary)
        }
    }
    
    /// Initialises a StormLink with a destination URL
    ///
    /// - Parameter url: The url that is the destination
    public init(url: URL) {
        
        self.url = url
        id = nil
        title = "Link"
        linkClass = .url
        body = nil
        recipients = nil
        appIdentityIdentifier = nil
        destination = nil
        duration = nil
        
        guard let scheme = url.scheme else { return }
        
        switch scheme {
        case "cache":
            guard let host = url.host else { return }
            if url.pathExtension == "json" && host == "pages"  {
                linkClass = .internal
            } else if host == "native" {
                linkClass = .native
            }
            break
        case "mailto":
            linkClass = .email
            break
        case "sms":
            linkClass = .sms
            break
        case "tel":
            linkClass = .call
            break
        default:
            break
        }
    }
    
    /// Initialises a link to a storm page
    ///
    /// - Parameter pageId: The id of the storm page to link to
    public init?(pageId: String) {
        
        let pageURL: URL?
        
        if let metadata = ContentController.shared.metadataForPage(withId: pageId), let src = metadata["src"] as? String {
            
            pageURL = URL(string: src) ?? URL(string: "cache://pages/\(pageId).json")
            
        } else {
            
            pageURL = URL(string: "cache://pages/\(pageId).json")
        }
        
        guard let _pageURL = pageURL else {
            return nil
        }
        
        id = Int(pageId)
        title = "Link"
        url = _pageURL
        linkClass = .internal
        body = nil
        recipients = nil
        appIdentityIdentifier = nil
        destination = nil
        duration = nil
    }
    
    /// Initialises a link to a storm page
    ///
    /// - Parameter pageName: The internal name of the storm page to link to
    public init?(pageName: String) {
        
        guard let metadata = ContentController.shared.metadataForPage(withName: pageName), let src = metadata["src"] as? String else {
            return nil
        }
        
        guard let srcURL = URL(string: src) else { return nil }
        
        id = nil
        title = "Link"
        url = srcURL
        linkClass = .internal
        body = nil
        recipients = nil
        appIdentityIdentifier = nil
        destination = nil
        duration = nil
    }
    
    public override init() {
        
        id = nil
        title = "Link"
        url = nil
        linkClass = .internal
        body = nil
        recipients = nil
        appIdentityIdentifier = nil
        destination = nil
        duration = nil
    }
    
    //MARK: - Standard link properties

    /// The unique identifier for the link
    public var id: Int?

    /// The title to describe the link
    public var title: String?
    
    /// The URL of the link
    public var url: URL?
    
    /// The type of link
    ///
    /// Storm has various link types for different link behaviours. They are represented as different objects in the CMS, but ultimately are represented by the same model natively
    public var linkClass: LinkClass
    
    //MARK: - SMS and Email -
    
    /// The body of the text to be shared
    ///
    /// Only valid for Email/SMS links
    public var body: String?
    
    /// An array of recipients that the body should be shared to
    ///
    /// Only valid for SMS links
    public var recipients: [String]?
    
    //MARK: - Inter-app linking -
    
    private var appIdentityIdentifier: String?
    
    /// The app identity to link to
    ///
    /// Only valid for inter-app links
    public var appIdentity: AppIdentity? {
        guard let appIdentityIdentifier = appIdentityIdentifier else { return nil }
        return AppLinkController().apps.first(where: {$0.identifier == appIdentityIdentifier })
    }
    
    /// The URL to be passed to the recieving app
    ///
    /// Only valid for inter-app links
    public var destination: String?
    
    //MARK: - Timer links -
    
    /// The number of seconds the timer should run for
    ///
    /// Only valid for timer links
    public var duration: TimeInterval?
    
    //MARK: - Miscellaneous -
    
    /// Aribtrary attributes added to the link
    public var attributes: [String] = []
}

