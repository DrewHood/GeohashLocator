//
//  GeohasherDelegate.swift
//  GeohashLocator
//
//  Created by Drew Hood on 5/21/16.
//  Copyright © 2016 Drew R. Hood. All rights reserved.
//

import Foundation

public protocol GeohasherDelegate {
    func geohasherFoundHash(geohasher: Geohasher, foundHash: GeohashCoordinate)
    func geohasherEncounteredError(geohasher: Geohasher, encounteredError: ErrorType)
}