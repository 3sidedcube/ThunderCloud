//
//  PresentationAnimator.swift
//  GDPC
//
//  Created by Ben Shutt on 09/12/2019.
//  Copyright © 2019 Ben Shutt. All rights reserved.
//

import UIKit

class PresentationAnimator : NSObject {
    private var isPresentation = false
    
    init (isPresentation: Bool) {
        self.isPresentation = isPresentation
    }
}

extension PresentationAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
        let controller = transitionContext.viewController(forKey: key)!
        
        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }

        let initialAlpha: CGFloat = isPresentation ? 0 : 1
        let finalAlpha: CGFloat = isPresentation ? 1 : 0
        
        controller.view.alpha = initialAlpha
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            controller.view.alpha = finalAlpha
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

