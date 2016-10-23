//
//  ViewController.swift
//  Trax
//
//  Created by David Anglin on 2/11/16.
//  Copyright © 2016 David Anglin. All rights reserved.
//


import UIKit
import MapKit

class GPXViewController: UIViewController
{
    // MARK: - Constants -
    
    private struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 59, height: 59)
        static let AnnotationViewReuseIdentifier = "waypoint"
        static let ShowImageSegue = "Show Image"
        static let EditWaypointSegue = "Edit Waypoint"
        static let EditWaypointPopoverWidth: CGFloat = 320
    }
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Satellite
            mapView.delegate = self
        }
    }
    
    // MARK: - IBActions -
    
    @IBAction func addWaypoint(sender: UILongPressGestureRecognizer)
    {
        if sender.state == UIGestureRecognizerState.Began {
            let coordinate = mapView.convertPoint(sender.locationInView(mapView), toCoordinateFromView: mapView)
            let waypoint = EditableWaypoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
            waypoint.name = "Dropped"
            //            waypoint.links.append(GPX.Link(href: "http://cs193p.stanford.edu/Images/Panorama.jpg"))
            mapView.addAnnotation(waypoint)
        }
    }
    
    // MARK: - Public API -
    
    var gpxURL: NSURL? {
        didSet {
            clearWaypoints()
            if let url = gpxURL {
                GPX.parse(url) {
                    if let gpx = $0 {
                        self.handleWaypoints(gpx.waypoints)
                    }
                }
            }
        }
    }
    
    // MARK: - View Controller Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // sign up to hear about GPX files arriving
        // we never remove this observer, so we will never leave the heap
        // might make some sense to think about when to remove this observer
        
        let center = NSNotificationCenter.defaultCenter()
        let queue = NSOperationQueue.mainQueue()
        let appDelegate = UIApplication.sharedApplication().delegate
        
        center.addObserverForName(GPXURL.Notification, object: appDelegate, queue: queue)  { notification in
            if let url = notification.userInfo?[GPXURL.Key] as? NSURL {
                self.gpxURL = url
            }
        }
        
        gpxURL = NSURL(string: "http://cs193p.stanford.edu/Vacation.gpx") // for demo/debug/testing
    }
    
    // MARK: - Navigation -
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == Constants.ShowImageSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? Waypoint {
                if let wivc = segue.destinationViewController.contentViewController as? WaypointImageViewController {
                    wivc.waypoint = waypoint
                } else if let ivc = segue.destinationViewController.contentViewController as? ImageViewController {
                    ivc.imageURL = waypoint.imageURL
                    ivc.title = waypoint.name
                }
            }
        } else if segue.identifier == Constants.EditWaypointSegue {
            if let waypoint = (sender as? MKAnnotationView)?.annotation as? EditableWaypoint {
                if let ewvc = segue.destinationViewController.contentViewController as? EditWaypointViewController {
                    if let ppc = ewvc.popoverPresentationController {
                        let coordinatePoint = mapView.convertCoordinate(waypoint.coordinate, toPointToView: mapView)
                        ppc.sourceRect = (sender as! MKAnnotationView).popoverSourceRectForCoordinatePoint(coordinatePoint)
                        let minimumSize = ewvc.view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                        ewvc.preferredContentSize = CGSize(width: Constants.EditWaypointPopoverWidth, height: minimumSize.height)
                        ppc.delegate = self
                    }
                    ewvc.waypointToEdit = waypoint
                }
            }
        }
    }
    
    // MARK: - Waypoints -
    
    private func clearWaypoints() {
        if mapView?.annotations != nil { mapView.removeAnnotations(mapView.annotations ) }
    }
    
    private func handleWaypoints(waypoints: [Waypoint]) {
        mapView.addAnnotations(waypoints)
        mapView.showAnnotations(waypoints, animated: true)
    }
}

// MARK: - MKMapViewDelegate -

extension GPXViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(Constants.AnnotationViewReuseIdentifier)
        
        if view == nil {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: Constants.AnnotationViewReuseIdentifier)
            view!.canShowCallout = true
        } else {
            view!.annotation = annotation
        }
        
        view!.draggable = annotation is EditableWaypoint
        
        view!.leftCalloutAccessoryView = nil
        view!.rightCalloutAccessoryView = nil
        if let waypoint = annotation as? Waypoint {
            if waypoint.thumbnailURL != nil {
                view!.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
            }
            if annotation is EditableWaypoint {
                view!.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure)
            }
        }
        
        return view
    }
    
    // this had to be adjusted slightly when we added editable waypoints
    // we can no longer depend on the thumbnailURL being set at "annotation view creation time"
    // so here we just check to see if there's a thumbnail URL
    // and, if so, we can lazily create the leftCalloutAccessoryView if needed
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let waypoint = view.annotation as? Waypoint {
            if let url = waypoint.thumbnailURL {
                if view.leftCalloutAccessoryView == nil {
                    // a thumbnail must have been added since the annotation view was created
                    view.leftCalloutAccessoryView = UIButton(frame: Constants.LeftCalloutFrame)
                }
                if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                    if let imageData = NSData(contentsOfURL: url) { // blocks main thread!
                        if let image = UIImage(data: imageData) {
                            thumbnailImageButton.setImage(image, forState: .Normal)
                        }
                    }
                }
            }
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if (control as? UIButton)?.buttonType == UIButtonType.DetailDisclosure {
            mapView.deselectAnnotation(view.annotation, animated: false)
            performSegueWithIdentifier(Constants.EditWaypointSegue, sender: view)
        } else if let waypoint = view.annotation as? Waypoint {
            if waypoint.imageURL != nil {
                performSegueWithIdentifier(Constants.ShowImageSegue, sender: view)
            }
        }
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate -

extension GPXViewController: UIPopoverPresentationControllerDelegate
{
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverFullScreen // full screen, but we can see what's underneath
    }
    
    func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController?
    {
        let navcon = UINavigationController(rootViewController: controller.presentedViewController)
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        visualEffectView.frame = navcon.view.bounds
        navcon.view.insertSubview(visualEffectView, atIndex: 0) // "back-most" subview
        return navcon
    }
}

// MARK: - Convenience Extensions -

extension Waypoint: MKAnnotation
{
    // MARK: - MKAnnotation -
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var title: String? { return name }
    
    var subtitle: String? { return info }
    
    // MARK: - Links to Images -
    
    var thumbnailURL: NSURL? { return getImageURLofType("thumbnail") }
    var imageURL: NSURL? { return getImageURLofType("large") }
    
    private func getImageURLofType(type: String) -> NSURL? {
        for link in links {
            if link.type == type {
                return link.url
            }
        }
        return nil
    }
}



