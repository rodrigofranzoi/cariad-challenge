//
//  CustomAnnotation.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 04/03/2023.
//

import Foundation
import MapKit

class ChargingStationAnnotation: NSObject, MKAnnotation {
    static let identifier: String = "ChargingStationAnnotation"
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var station: ChargingStation
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, station: ChargingStation) {
        self.coordinate = coordinate
        self.station = station
    }
}
