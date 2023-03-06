//
//  PoolingService.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 04/03/2023.
//

import Foundation
import Combine

protocol PollingUseCaseType {
    func observe() -> AnyPublisher<Void, Never>
}

final class PollingUseCase: PollingUseCaseType {
    
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    init(interval: Double) {
        self.timer = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
    }

    func observe() -> AnyPublisher<Void, Never> {
        timer
            .map { _ in () }
            .eraseToAnyPublisher()
    }
}
