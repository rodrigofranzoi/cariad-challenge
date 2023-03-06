//
//  Constants.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 04/03/2023.
//

import Foundation

struct Constants {
    struct APIDetails {
        static let baseURL = "https://api.openchargemap.io/v3/poi/"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let distance = "distance"
        static let key = "key"
        static let camelcase = "camelcase"
    }
    
    struct Pooling {
        static let poolingInterval = 30.0 // seconds
    }
    
    struct Map {
        static let lat = 52.526
        static let lon = 13.415
        static let zoomDistance = 5000.0 // meters
    }
    
}
