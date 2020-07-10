//
//  PresentationManager.swift
//  GDPC
//
//  Created by Ben Shutt on 09/12/2019.
//  Copyright © 2019 Ben Shutt. All rights reserved.
//

import UIKit

class PresentationManager : NSObject {
    var disableCompatHeight = false
}

extension PresentationManager : UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.delegate = self
        return presentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(isPresentation: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(isPresentation: false)
    }
}

extension PresentationManager : UIAdaptivePresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact && disableCompatHeight {
            return UIModalPresentationStyle.overFullScreen
        } else {
            return UIModalPresentationStyle.none
        }
    }
}
