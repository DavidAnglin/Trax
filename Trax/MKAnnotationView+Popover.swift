//
//  MKAnnotationView+Popover.swift
//  Trax
//
//  Created by David Anglin on 10/22/16.
//  Copyright © 2016 David Anglin. All rights reserved.
//

import Foundation
import UIKit
import MapKit

extension MKAnnotationView {
    func popoverSourceRectForCoordinatePoint(coordinatePoint: CGPoint) -> CGRect {
        var popoverSourceRectCenter = coordinatePoint
        popoverSourceRectCenter.x -= frame.width / 2 - centerOffset.x - calloutOffset.x
        popoverSourceRectCenter.y -= frame.height / 2 - centerOffset.y - calloutOffset.y
        return CGRect(origin: popoverSourceRectCenter, size: frame.size)
    }
}