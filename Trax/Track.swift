//
//  Track.swift
//  Trax
//
//  Created by David Anglin on 10/22/16.
//  Copyright © 2016 David Anglin. All rights reserved.
//

import Foundation

class Track: Entry
{
    var fixes = [Waypoint]()
    
    override var description: String {
        let waypointDescription = "fixes=[\n" + fixes.map { $0.description }.joinWithSeparator("\n") + "\n]"
        return [super.description, waypointDescription].joinWithSeparator(" ")
    }
}
