//
//  HalfSizePresentationController.swift
//  FacebookMessage
//
//  Created by Swarup_Pattnaik on 01/10/16.
//  Copyright © 2016 Swarup_Pattnaik. All rights reserved.
//

import UIKit

class HalfSizePresentationController: UIPresentationController {
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        return CGRect(x: 0, y: containerView!.bounds.height*2/3, width: containerView!.bounds.width, height: containerView!.bounds.height/3)
    }
}
