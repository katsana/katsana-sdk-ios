//
//  AppleReverseGeocodingClientTests.swift
//  KatsanaSDKTest
//
//  Created by Wan Ahmad Lutfi on 02/04/2023.
//  Copyright © 2023 pixelated. All rights reserved.
//

import XCTest
import KatsanaSDK
import CoreLocation
import Intents
import Contacts

class AppleReverseGeocodingClientTests: XCTestCase {
    func test_getAddress_performsReverseGeocoding() {
        let (sut, spy) = makeSUT()
        
        sut.getAddress(anyCoordinate()) { _ in }
        XCTAssertEqual(spy.requestCount, 1)
    }
    

    func test_getAddress_failsOnRequestError() {
        let (sut, spy) = makeSUT()

        expect(sut, coordinate: anyCoordinate(), toCompleteWith: .failure(anyNSError())) {
            spy.completeRequest(with: anyNSError())
        }
    }

    func test_getAddresss_succeedsOnRequestSuccess() {
        let (sut, spy) = makeSUT()
        
        let placemark = CLPlacemark(location: anyLocation(),
                                     name: "any name",
                                     postalAddress: nil)

        expect(sut, coordinate: anyCoordinate(), toCompleteWith: .success(address(with: anyLocation()))) {
            spy.completeRequest(with: placemark)
        }
    }
    
    func test_getAddresss_failsOnInvalidRepresentationCases() {
        let (sut, spy) = makeSUT()

        expect(sut, coordinate: anyCoordinate(), toCompleteWith: .failure(AppleReverseGeocodingClient.UnexpectedValuesRepresentation())) {
            spy.completeRequest(with: (nil, nil))
        }
    }
    
    
    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (ReverseGeocodingClient, GeocoderStub) {
        let geocoder = GeocoderStub()
        let sut = AppleReverseGeocodingClient(geocoder: geocoder)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, geocoder)
    }
    
    private func expect(_ sut: ReverseGeocodingClient, coordinate: (latitude: Double, longitude: Double), toCompleteWith expectedResult: ReverseGeocodingClient.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.getAddress(coordinate) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }

    func anyLocation() -> CLLocation{
        return CLLocation(latitude: anyCoordinate().latitude, longitude: anyCoordinate().longitude)
    }
    
    func address(with location: CLLocation) -> KTAddress{
        return KTAddress(latitude: anyLocation().coordinate.latitude, longitude: anyLocation().coordinate.longitude)
    }
    
}

class GeocoderStub: CLGeocoder{
    var requests = [CLGeocodeCompletionHandler]()
    
    var requestCount: Int{
        return requests.count
    }
    
    override func reverseGeocodeLocation(_ location: CLLocation, completionHandler: @escaping CLGeocodeCompletionHandler) {
        requests.append(completionHandler)
    }
    
    func completeRequest(with error: Error, at index: Int = 0) {
        requests[index](nil, error)
    }
    
    func completeRequest(with placemark: CLPlacemark, at index: Int = 0) {
        requests[index]([placemark], nil)
    }
    
    func completeRequest(with result: ([CLPlacemark]?, Error?), at index: Int = 0) {
        requests[index](result.0, result.1)
    }
}
