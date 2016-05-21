//
//  Geohasher.swift
//  GeohashLocator
//
//  Created by Drew Hood on 5/20/16.
//  Copyright © 2016 Drew R. Hood. All rights reserved.
//

import Foundation
import CryptoSwift
import Alamofire

public class Geohasher {
    
    public var delegate: GeohasherDelegate?
    
    var graticule: GeohashCoordinate.Graticule? {
        didSet {
            self.calculateHashCoordinateAndReturn()
        }
    }
    var dowString: String? {
        didSet {
            self.calculateHashCoordinateAndReturn()
        }
    }
    var dateString: String? {
        didSet {
            self.calculateHashCoordinateAndReturn()
        }
    }
    
    public func retrieveHashForGraticule(graticule: GeohashCoordinate.Graticule, date: NSDate) {
        // Set the graticule
        self.graticule = graticule
        
        // format the date string
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.dateString = formatter.stringFromDate(date)
        
        self.retrieveDowJones(self.dateString!)
    }
    
    private func retrieveDowJones(forString: String) {
        let urlString = "http://geo.crox.net/djia/"+forString
        Alamofire.request(.GET, urlString).responseString { response in
            switch response.result {
            case .Success:
                self.dowString = (NSString(data: response.data!, encoding: NSUTF8StringEncoding) as! String)
            default:
                print("error was: "+response.result.error!.description)
            }
        }
    }
    
    //
    // Hash Calculation
    //
    
    private func calculateHashCoordinateAndReturn() {
        // in order to do this, we need a graticule, a date, a dow, and a delegate
        if ( self.graticule == nil || self.dowString == nil || self.dateString == nil || self.delegate == nil) {
            return
        }
        
        // Do stuff
        print(self.graticule)
        print("dow string is: "+self.dowString!)
        print("date string is: "+self.dateString!)
        
        // Make the final string to hash. 
        let finalString = self.dateString!+"-"+self.dowString!
        let hashString = finalString.md5()
        
        // Split the string in half
        // Prepend each half with 0x
        let splitPoint = hashString.startIndex.advancedBy(16)
        let latHash = "0x"+hashString.substringToIndex(splitPoint)
        let lonHash = "0x"+hashString.substringFromIndex(splitPoint)
        
        // Time to math
        // Calculate divisor
        let divisor:Double = pow(16,16)
        
        // Calculate offsets
        let latOffset = Double(latHash)! / divisor
        let lonOffset = Double(lonHash)! / divisor
        
        // Create final HashCoord object
        let foundHash = GeohashCoordinate(graticule: self.graticule!, latitudeOffset: latOffset, longitudeOffset: lonOffset)
        
        // Call delegate!!
        self.delegate!.geohasherFoundHash(self, foundHash: foundHash)
        
    }
}