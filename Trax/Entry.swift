//
//  Entry.swift
//  Trax
//
//  Created by David Anglin on 10/22/16.
//  Copyright © 2016 David Anglin. All rights reserved.
//

import Foundation

class Entry: NSObject
{
    var links = [Link]()
    var attributes = [String:String]()
    
    var name: String? {
        set { attributes["name"] = newValue }
        get { return attributes["name"] }
    }
    
    override var description: String {
        var descriptions = [String]()
        if attributes.count > 0 { descriptions.append("attributes=\(attributes)") }
        if links.count > 0 { descriptions.append("links=\(links)") }
        return descriptions.joinWithSeparator(" ")
    }
}
