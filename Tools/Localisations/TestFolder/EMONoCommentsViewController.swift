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
        
        titleLabel.text = String(NSString(localisationKey: Hello+"_COMMENTS_NOCOMMENTS_TITLE", fallbackString: "NO COMMENTS").uppercaseString)
        
        subtitleLabel.text = String(NSString(localisationKey: "_COMMENTS_NOCOMMENTS_SUBTITLE"+Sup, fallbackString: "You can be the first to leave one!"))
        
        titleLabel.text = String(NSString(localisationKey: "_SWIFT_INIT_VARIABLE_\(SomeVar)", fallbackString: "NO COMMENTS").uppercaseString)
        
        titleLabel.text = String(NSString(localisationKey: "_SWIFT_INIT_VARIABLE"+Hello+"_SOME_OTHER_VAR\(Hey)", fallbackString: "NO COMMENTS \(Yo)"+"Hey Hun"+SomeVar).uppercaseString)
        
        titleLabel.text = String(NSString(localisationKey: "_COMMENTS_NOCOMMENTS_TITLE").uppercaseString)
        
        return "Earthquakes".stringWithLocalisationKey("_MAPS_LAYER_EARTHQUAKETRACKER_TITLE")
        
        
        navigationItem.prompt = "WOO FALLBACK".stringWithLocalisationKey("_SWIFT_FUNC_FALLBACK")
        
        navigationItem.prompt = "WOO FALLBACK \(SomeVar)".stringWithLocalisationKey("_SWIFT_FUNC_FALLBACK")
        
        navigationItem.prompt = "WOO FALLBACK \"\" \(SomeVar)".stringWithLocalisationKey("_SWIFT_FUNC_FALLBACK")
        
        navigationItem.prompt = "{people} Selected:".stringWithLocalisationKey("_SWIFT_FUNC_PARAMS_FALLBACK", paramDictionary: ["people":peopleViewController.invitees.count])
        
        navigationItem.prompt = "{people} Selected:".stringWithLocalisationKey(TestVar+"_SWIFT_FUNC_PARAMS_FALLBACK_\(Hey)"+"_ANOTHER_"+SomeVar , paramDictionary: ["people":peopleViewController.invitees.count])
        
        
        String("Hello World").stringWithLocalisationKey("_SWIFT_FUNC_INIT_FALLBACK")
        
        String(2.14).stringWithLocalisationKey("_SWIFT_FUNC_INIT_NUMBER")
        
        String(count:3, repeatedValue:b).stringWithLocalisationKey("_SWIFT_FUNC_INIT_OTHER")
        
        String(Wassup+"Hello World").stringWithLocalisationKey("_SWIFT_FUNC_INIT_VARIABLE_\(SomeVar)")
        
        String(count:3, repeatedValue:b).stringWithLocalisationKey( "_SWIFT_FUNC_INIT_VARIABLE"+SomeVar, paramDictionary:["Some Key":"Value"])
        
        String(count:3, repeatedValue:b).stringWithLocalisationKey("_SWIFT_FUNC_INIT_VARIABLE"+SomeVar)


    }
}
