//
//  GPX.swift
//  Trax
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//
//  Very simple GPX file parser.
//  Only verified to work for CS193p demo purposes!

import Foundation

class GPX: NSObject
{
    // MARK: - Private Constants -
    private let url: NSURL
    private let completionHandler: GPXCompletionHandler

    // MARK: - Public Constants -
    
    // MARK: Private Variables -
    private var input = ""
    
    // MARK: - Public Variables -
    
    var waypoint: Waypoint?
    var track: Track?
    var link: Link?

    var waypoints = [Waypoint]()
    var tracks = [Track]()
    var routes = [Track]()
    
    override var description: String {
        var descriptions = [String]()
        if waypoints.count > 0 { descriptions.append("waypoints = \(waypoints)") }
        if tracks.count > 0 { descriptions.append("tracks = \(tracks)") }
        if routes.count > 0 { descriptions.append("routes = \(routes)") }
        return descriptions.joinWithSeparator("\n")
    }
    
    // MARK: - TypeAlias -
    
    typealias GPXCompletionHandler = (GPX?) -> Void
    
    // MARK: - Private Init -
    
    private init(url: NSURL, completionHandler: GPXCompletionHandler) {
        self.url = url
        self.completionHandler = completionHandler
    }
    
    // MARK: - Class Function -
    
    class func parse(url: NSURL, completionHandler: GPXCompletionHandler) {
        GPX(url: url, completionHandler: completionHandler).parse()
    }
    
    // MARK: - Private Implementation

    private func complete(success success: Bool) {
        dispatch_async(dispatch_get_main_queue()) {
            self.completionHandler(success ? self : nil)
        }
    }
    
    private func fail() { complete(success: false) }
    private func succeed() { complete(success: true) }
    
    private func parse() {
        let qos = Int(QOS_CLASS_USER_INITIATED.rawValue)
        dispatch_async(dispatch_get_global_queue(qos, 0)) {
            if let data = NSData(contentsOfURL: self.url) {
                let parser = NSXMLParser(data: data)
                parser.delegate = self
                parser.shouldProcessNamespaces = false
                parser.shouldReportNamespacePrefixes = false
                parser.shouldResolveExternalEntities = false
                parser.parse()
            } else {
                self.fail()
            }
        }
    }
}

// MARK: - Parser Delegate -
extension GPX: NSXMLParserDelegate {
    
    func parserDidEndDocument(parser: NSXMLParser) { succeed() }
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) { fail() }
    func parser(parser: NSXMLParser,validationErrorOccurred validationError: NSError){ fail() }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        input += string
        
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "trkseg":
            if track == nil { fallthrough }
        case "trk":
            tracks.append(Track())
            track = tracks.last
        case "rte":
            routes.append(Track())
            track = routes.last
        case "rtept", "trkpt", "wpt":
            let latitude = (attributeDict["lat"]! as NSString).doubleValue
            let longitude = (attributeDict["lon"]! as NSString).doubleValue
            waypoint = Waypoint(latitude: latitude, longitude: longitude)
        case "link":
            link = Link(href: attributeDict["href"]! as String)
        default: break
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "wpt":
            if waypoint != nil { waypoints.append(waypoint!); waypoint = nil }
        case "trkpt", "rtept":
            if waypoint != nil { track?.fixes.append(waypoint!); waypoint = nil }
        case "trk", "trkseg", "rte":
            track = nil
        case "link":
            if link != nil {
                if waypoint != nil {
                    waypoint!.links.append(link!)
                } else if track != nil {
                    track!.links.append(link!)
                }
            }
            link = nil
        default:
            if link != nil {
                link!.linkattributes[elementName] = input.trimmed
            } else if waypoint != nil {
                waypoint!.attributes[elementName] = input.trimmed
            } else if track != nil {
                track!.attributes[elementName] = input.trimmed
            }
            input = ""
        }
    }
}
