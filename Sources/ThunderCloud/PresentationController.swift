//
//  PresentationController.swift
//  GDPC
//
//  Created by Ben Shutt on 09/12/2019.
//  Copyright © 2019 Ben Shutt. All rights reserved.
//

import UIKit

/// `UIPresentationController`
class PresentationController : UIPresentationController {
    
    // MARK: -  UIPresentationController
    
    override func presentationTransitionWillBegin() {
    }
    
    override func dismissalTransitionWillBegin() {
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return parentSize
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return .zero
        }
        
        let size = self.size(
            forChildContentContainer: presentedViewController,
            withParentContainerSize: containerView.bounds.size)
        
        return CGRect(x: (containerView.bounds.size.width - size.width) * 0.5,
                      y: (containerView.bounds.size.height - size.height) * 0.5,
                      width: size.width,
                      height: size.height)
    }

}
