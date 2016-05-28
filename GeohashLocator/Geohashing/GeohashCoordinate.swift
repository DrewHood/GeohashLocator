//
//  GeohashCoordinate.swift
//  GeohashLocator
//
//  Created by Drew Hood on 5/20/16.
//  Copyright © 2016 Drew R. Hood. All rights reserved.
//

import Foundation
import CoreLocation

public class GeohashCoordinate {
    // Typealiases
    public typealias Graticule = (latitude: Int, longitude: Int)
    
    // Vars
    public let graticule: Graticule
    public let coordinate: CLLocationCoordinate2D
    
    init(graticule: Graticule!, latitudeOffset: Double!, longitudeOffset: Double!) {
        self.graticule = graticule
        
        let latitude: Double
        let longitude: Double
        if self.graticule.latitude < 0 {
            latitude = Double(self.graticule.latitude) - latitudeOffset
        } else if self.graticule.latitude == -0 {
            latitude = 0.00 - latitudeOffset
        } else {
            latitude = Double(self.graticule.latitude) + latitudeOffset
        }
        
        if self.graticule.longitude < 0 {
            longitude = Double(self.graticule.longitude) - longitudeOffset
        } else if self.graticule.longitude == -0 {
            longitude = 0.00 - longitudeOffset
        } else {
            longitude = Double(self.graticule.longitude) + longitudeOffset
        }
        
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}