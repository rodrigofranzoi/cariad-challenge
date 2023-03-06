//
//  cariad_challengeTests.swift
//  cariad-challengeTests
//
//  Created by Rodrigo Scroferneker on 02/03/2023.
//

import XCTest
import Combine
@testable import cariad_challenge


final class cariad_challengeTests: XCTestCase {
    
    var polling: PollingUseCaseType!
    var service: ChargingPointsServiceType!
    
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        service = ChargingPointsTest(provider: APIProvider())
        polling = PollingUseCase(interval: 60)
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testApiProvider() throws {
        let data = try awaitPublisher(service.fetchChargingPoint(latitude: 0, longitude: 0, distance: 0))

        XCTAssertEqual(data.count, 2)
        XCTAssertEqual(data[0].uuid, "ABC2")
        XCTAssertEqual(data[0].addressInfo.title, "rodrigo")
        XCTAssertEqual(data[0].addressInfo.addressLine1, "rodrigo")
        XCTAssertEqual(data[0].addressInfo.longitude, -123.0)
        XCTAssertEqual(data[0].addressInfo.latitude, 123.0)

        XCTAssertEqual(data[1].uuid, "ABC1")
        XCTAssertEqual(data[1].addressInfo.title, "valentina")
        XCTAssertEqual(data[1].addressInfo.addressLine1, "valentina")
        XCTAssertEqual(data[1].addressInfo.longitude, -123.0)
        XCTAssertEqual(data[1].addressInfo.latitude, 123.0)
    }
    
    func testModel() {
        
        //Given
        let expectation = XCTestExpectation(description: "Load first time")
        let sut = MapViewModel(lat: 0, lon: 0, zoomDistance: 0, pollingService: polling, service: service)

        sut
            .$stations
            .dropFirst()
            .sink(receiveValue: { _ in
                expectation.fulfill()
            }).store(in: &cancellables)

        //When
        sut.fetchData()

        //Then
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(sut.stations.count, 2)
        XCTAssertTrue(sut.viewState == .idle)
    }
    
    func testModelReload() {
        
        //Given
        let expectation = XCTestExpectation(description: "Load first time")
        let sut = MapViewModel(lat: 0, lon: 0, zoomDistance: 0, pollingService: polling, service: service)

        sut
            .$stations
            .dropFirst(2)
            .sink(receiveValue: { _ in
                expectation.fulfill()
            }).store(in: &cancellables)
        //When
        sut.fetchData()
        sut.fetchData()

        //Then
        wait(for: [expectation], timeout: 2)

        XCTAssertEqual(sut.stations.count, 100)
        XCTAssertTrue(sut.viewState == .idle)
    }
    
    func testPolling() {
        
        //Given
        let sut: PollingUseCaseType = PollingUseCase(interval: 1)
        
        let expectation = XCTestExpectation(description: "Polling 4 times")
        let service: ChargingPointsTest = ChargingPointsTest(provider: APIProvider())
        let model = MapViewModel(lat: 0, lon: 0, zoomDistance: 0, pollingService: sut, service: service)

        model
            .$stations
            .dropFirst(5)
            .sink(receiveValue: { _ in
                expectation.fulfill()
            }).store(in: &cancellables)
        //When
        
        model.fetchData()
        model.startMapPolling()

        //Then
        wait(for: [expectation], timeout: 5)
        XCTAssertEqual(service.count, 5)
    }
    
    func awaitPublisher<T: Publisher>(
            _ publisher: T,
            timeout: TimeInterval = 10,
            file: StaticString = #file,
            line: UInt = #line
        ) throws -> T.Output {
            var result: Result<T.Output, Error>?
            let expectation = self.expectation(description: "Awaiting publisher")

            let cancellable = publisher.sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        result = .failure(error)
                    case .finished:
                        break
                    }

                    expectation.fulfill()
                },
                receiveValue: { value in
                    result = .success(value)
                }
            )

            waitForExpectations(timeout: timeout)
            cancellable.cancel()


            let unwrappedResult = try XCTUnwrap(
                result,
                "Awaited publisher did not produce any output",
                file: file,
                line: line
            )

            return try unwrappedResult.get()
        }
}



final class ChargingPointsTest: ChargingPointsServiceType {
    
    let provider: APIProviderType
    public var count: Int = 0
    
    init(provider: APIProviderType) {
        self.provider = provider
    }
    
    func fetchChargingPoint(latitude: Double, longitude: Double, distance: Double) -> AnyPublisher<[ChargingStation], Error> {
        let resource = count%2 == 0 ? "ResponseExample2" : "ResponseExample"
        count += 1
        let path = Bundle.main.path(forResource: resource, ofType: "json")!
        let url = URL(fileURLWithPath: path)
        return provider
            .request(urlRequest: URLRequest(url: url))
            .eraseToAnyPublisher()
    }
}
