//
//  APIService.swift
//  cariad-challenge
//
//  Created by Rodrigo Scroferneker on 02/03/2023.
//

import Foundation
import Combine

protocol APIProviderType {
    func request<T: Decodable>(urlRequest: URLRequest) -> AnyPublisher<T, Error>
}

final class APIProvider: APIProviderType {
    let session = URLSession.shared
    func request<T>(urlRequest: URLRequest) -> AnyPublisher<T, Error> where T: Decodable {
        session
            .dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
