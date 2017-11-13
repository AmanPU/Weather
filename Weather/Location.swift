//
//  Location.swift
//  Weather
//
//  Created by Aman Bhullar on 2017-11-09.
//  Copyright © 2017 Aman Bhullar. All rights reserved.
//

import CoreLocation

class Location {
    static var sharedInstance = Location()
    private init() {}
    
    var latitude: Double!
    var longitude: Double!
}
