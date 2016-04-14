//
//  EMONoCommentsViewController.swift
//  Emoodji
//
//  Created by Simon Mitchell on 08/01/2016.
//  Copyright © 2016 Three Sided Cube. All rights reserved.
//

import UIKit
import ThunderCloud

class EMONoCommentsViewController: EMOViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        titleLabel.text = String(NSString(localisationKey: "_COMMENTS_NOCOMMENTS_TITLE", fallbackString: "NO COMMENTS").uppercaseString)
        subtitleLabel.text = String(NSString(localisationKey: "_COMMENTS_NOCOMMENTS_SUBTITLE", fallbackString: "You can be the first to leave one!"))
        return "Earthquakes".stringWithLocalisationKey("_MAPS_LAYER_EARTHQUAKETRACKER_TITLE")
        
        navigationItem.prompt = "WOO FALLBACK".stringWithLocalisationKey("_SWIFT_FUNC_FALLBACK")
        navigationItem.prompt = "{people} Selected:".stringWithLocalisationKey("_SWIFT_FUNC_PARAMS_FALLBACK", paramDictionary: ["people":peopleViewController.invitees.count])
        String("Hello World").stringWithLocalisationKey("_SWIFT_FUNC_INIT_FALLBACK")
        String(2.14).stringWithLocalisationKey("_SWIFT_FUNC_INIT_NUMBER")
        String(count:3, repeatedValue:b).stringWithLocalisationKey("_SWIFT_FUNC_INIT_OTHER")
    }
}
