//
//  ChargingPoint.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 03/03/2023.
//

import Foundation

struct ChargingStation: Codable, Equatable {
    let uuid: String
    let dateLastStatusUpdate: String
    let addressInfo: AddressInfo
    let numberOfPoints: Int?
    
    static func == (lhs: ChargingStation, rhs: ChargingStation) -> Bool {
        lhs.uuid == rhs.uuid && lhs.dateLastStatusUpdate == rhs.dateLastStatusUpdate
    }
}

struct AddressInfo: Codable {
    let title: String
    let addressLine1: String
    let latitude: Double
    let longitude: Double
}
