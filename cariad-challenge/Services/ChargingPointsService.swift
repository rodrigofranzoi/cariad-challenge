//
//  ChargingPointsService.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 02/03/2023.
//

import Foundation
import Combine

protocol ChargingPointsServiceType {
    func fetchChargingPoint(latitude: Double, longitude: Double, distance: Double) -> AnyPublisher<[ChargingStation], Error>
}

final class ChargingPointsService: ChargingPointsServiceType {
    let provider: APIProviderType
    init(provider: APIProviderType) {
        self.provider = provider
    }
    
    func fetchChargingPoint(
        latitude: Double,
        longitude: Double,
        distance: Double) -> AnyPublisher<[ChargingStation], Error> {
            provider
                .request(urlRequest: createUrlRequest(latitude, longitude, distance))
                .eraseToAnyPublisher()
    }
 
    private func createUrlRequest(
        _ latitude: Double,
        _ longitude: Double,
        _ distance: Double) -> URLRequest {
            var urlComponents = URLComponents(string: Constants.APIDetails.baseURL)
            urlComponents?.queryItems = [URLQueryItem(name: Constants.APIDetails.key, value: Secrets.apiKey),
                                         URLQueryItem(name: Constants.APIDetails.latitude, value: "\(latitude)"),
                                         URLQueryItem(name: Constants.APIDetails.longitude, value: "\(longitude)"),
                                         URLQueryItem(name: Constants.APIDetails.distance, value: "\(distance)"),
                                         URLQueryItem(name: Constants.APIDetails.camelcase, value: "\(true)")]
            let url = urlComponents?.url ?? URL(fileURLWithPath: "")
            return URLRequest(url: url)
    }
}
