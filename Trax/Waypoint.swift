//
//  Waypoint.swift
//  Trax
//
//  Created by David Anglin on 10/22/16.
//  Copyright © 2016 David Anglin. All rights reserved.
//

import Foundation

class Waypoint: Entry
{
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
    
    var info: String? {
        set { attributes["desc"] = newValue }
        get { return attributes["desc"] }
    }
    lazy var date: NSDate? = self.attributes["time"]?.asGpxDate
    
    override var description: String {
        return ["lat=\(latitude)", "lon=\(longitude)", super.description].joinWithSeparator(" ")
    }
}