//
//  Link.swift
//  Trax
//
//  Created by David Anglin on 10/22/16.
//  Copyright © 2016 David Anglin. All rights reserved.
//

import Foundation

class Link: CustomStringConvertible
{
    var href: String
    var linkattributes = [String:String]()
    
    init(href: String) { self.href = href }
    
    var url: NSURL? { return NSURL(string: href) }
    var text: String? { return linkattributes["text"] }
    var type: String? { return linkattributes["type"] }
    
    var description: String {
        var descriptions = [String]()
        descriptions.append("href=\(href)")
        if linkattributes.count > 0 { descriptions.append("linkattributes=\(linkattributes)") }
        return "[" + descriptions.joinWithSeparator(" ") + "]"
    }
}