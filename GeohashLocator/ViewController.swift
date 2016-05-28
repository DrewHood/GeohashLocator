//
//  ViewController.swift
//  GeohashLocator
//
//  Created by Drew Hood on 5/20/16.
//  Copyright © 2016 Drew R. Hood. All rights reserved.
//

import Cocoa
import MapKit

class ViewController: NSViewController, MKMapViewDelegate, NSDatePickerCellDelegate, GeohasherDelegate {
    
    // Vars
    @IBOutlet weak private var map: MKMapView!
    @IBOutlet weak private var datePicker: NSDatePicker!
    @IBOutlet weak private var typeSegment: NSSegmentedCell!
    
    private var haveMovedToUsersLocation: Bool = false
    private var graticule: GeohashCoordinate.Graticule? {
        didSet {
            self.updateGeohashPin()
        }
    }
    private var date: NSDate? {
        didSet {
            self.updateGeohashPin()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up Date view
        self.datePicker.dateValue = NSDate()
        self.datePicker.maxDate = NSDate()
        self.datePicker.delegate = self
        
        self.setDateAction(nil)
    }

    @IBAction func centerOnUserAction(_:AnyObject?) {
        // Center on the user's location
        let location: MKUserLocation = self.map!.userLocation
        
        // Mark down the graticule.
        self.updateGraticuleToCurrentMapCenter()
        
        // Set the region. 
        let span = MKCoordinateSpan(latitudeDelta: 2, longitudeDelta: 2)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    @IBAction func setDateAction(_:AnyObject?) {
        self.date = datePicker.dateValue
    }
    
    @IBAction func setMapTypeAction(sender:AnyObject?) {
        // Get the tag from the segment controller
        let segment:Int = self.typeSegment.selectedSegment
        
        var type:MKMapType = MKMapType.Standard
        switch segment {
        case 0:
            type = MKMapType.Standard
        case 1:
            type = MKMapType.Satellite
        case 2:
            type = MKMapType.Hybrid
        default:
            break
        }
        
        self.map.mapType = type
    }
    
    //
    // Geohashing
    //
    
    func updateGeohashPin() {
        if (self.graticule != nil && self.date != nil) {
            let hasher = Geohasher()
            hasher.delegate = self
            hasher.retrieveHashForGraticule(self.graticule!, date: self.date!)
        }
    }
    
    func geohasherFoundHash(geohasher: Geohasher, foundHash: GeohashCoordinate) {
        //print(foundHash.coordinate)
        
        // Reset annotations
        self.map.removeAnnotations(self.map.annotations)
        
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = foundHash.coordinate
        newAnnotation.title = "Meeting Location"
        self.map.addAnnotation(newAnnotation)
    }
    
    func geohasherEncounteredError(geohasher: Geohasher, encounteredError: ErrorType) {
        print("Found error!!!")
    }
    
    func updateGraticuleToCurrentMapCenter() {
        self.graticule = (latitude: Int(self.map.centerCoordinate.latitude), longitude: Int(self.map.centerCoordinate.longitude))
    }
    
    //
    // MapView Delegation
    //
    
    // User Location Updates
    func mapView(_: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        if !haveMovedToUsersLocation {
            self.haveMovedToUsersLocation = true
            self.centerOnUserAction(nil)
            self.updateGeohashPin()
        }
    }
    
    // Region changes
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        self.updateGraticuleToCurrentMapCenter()
        self.updateGeohashPin()
    }
    
    // Annotations
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let reuseId = "HashLocation"
            
            var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            } else {
                annotationView?.annotation = annotation
            }
            
            return annotationView
        }
        
        return nil
    }

}
