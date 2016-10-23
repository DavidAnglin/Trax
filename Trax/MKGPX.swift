//
//  MKGPX.swift
//  Trax
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import MapKit

class EditableWaypoint: Waypoint
{
    // MARK: - Public Variables
    
    // make coordinate get & set (for draggable annotations)
    override var coordinate: CLLocationCoordinate2D {
        get { return super.coordinate }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
   override var thumbnailURL: NSURL? { return imageURL }
   override var imageURL: NSURL? { return links.first?.url }
}


