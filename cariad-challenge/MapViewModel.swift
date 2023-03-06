//
//  ChargingPointResponse.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 03/03/2023.
//

import Foundation
import MapKit
import Combine

class MapViewModel {
    
    @Published private(set) var viewState: MapViewController.State = .idle
    @Published private(set) var stations: [ChargingStation] = []
    
    public let lat: Double
    public let lon: Double
    public let zoomDistance: CLLocationDistance
    
    private let pollingService: PollingUseCaseType
    private let service: ChargingPointsServiceType
    private var cancellables = Set<AnyCancellable>()
    
    init(lat: Double, lon: Double, zoomDistance: Double, pollingService: PollingUseCaseType, service: ChargingPointsServiceType) {
        self.lat = lat
        self.lon = lon
        self.zoomDistance = CLLocationDistance(zoomDistance)
        self.pollingService = pollingService
        self.service = service
    }
    
    public func startMapPolling() {
        pollingService
            .observe()
            .sink { [weak self] _ in
                self?.fetchData()
            }.store(in: &cancellables)
    }

    public func fetchData() {
        self.viewState = .fetching
        service
            .fetchChargingPoint(
                latitude: lat,
                longitude: lon,
                distance: zoomDistance)
            .sink { [weak self] completionState in
                switch completionState {
                case .failure(let e):
                    self?.viewState = .error(e)
                case .finished:
                    self?.viewState = .idle
                }
            } receiveValue: { [weak self] stations in
                if self?.stations != stations {
                    self?.stations = stations
                }
            }
            .store(in: &cancellables)
    }
}
