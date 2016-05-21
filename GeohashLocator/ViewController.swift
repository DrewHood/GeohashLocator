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
    }

    @IBAction func centerOnUserAction(_:AnyObject?) {
        // Center on the user's location
        let location: MKUserLocation = self.map!.userLocation
        
        // Mark down the graticule.
        self.graticule = (latitude: Int(location.coordinate.latitude), longitude: Int(location.coordinate.longitude))
        
        // Set the region. 
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        self.map.setRegion(region, animated: true)
    }
    
    @IBAction func setDateAction(_:AnyObject?) {
        self.date = datePicker.dateValue
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
        print(foundHash.coordinate)
    }
    
    func geohasherEncounteredError(geohasher: Geohasher, encounteredError: ErrorType) {
        print("Found error!!!")
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
        self.updateGeohashPin()
    }
    
    //
    // Date Picker Delegate
    //
//    func datePickerCell(_: NSDatePickerCell, validateProposedDateValue proposedDateValue: AutoreleasingUnsafeMutablePointer<NSDate?>, timeInterval _: UnsafeMutablePointer<NSTimeInterval>) {
//        self.date = proposedDateValue
//        
//        self.updateGeohashPin()
//    }

}
