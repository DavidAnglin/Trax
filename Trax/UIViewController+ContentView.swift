//
//  UIViewController+ContentView.swift
//  Trax
//
//  Created by David Anglin on 10/22/16.
//  Copyright © 2016 David Anglin. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    var contentViewController: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController!
        } else {
            return self
        }
    }
}