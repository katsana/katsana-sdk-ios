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

class AppleReverseGeocodingClient: ReverseGeocodingClient{
    let geocoder: CLGeocoder
    
    init(geocoder: CLGeocoder = CLGeocoder()){
        self.geocoder = geocoder
    }
    
    func getAddress(_ coordinate: (latitude: Double, longitude: Double), completion: @escaping (Result<KTAddress, Error>) -> Void){
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemark, error in
            completion(.failure(error!))
        }
    }

}

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
//
//    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
//        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
//        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
//        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
//        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
//        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
//        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
//        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
//        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
//        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
//    }
//
//    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
//        let data = anyData()
//        let response = anyHTTPURLResponse()
//
//        let receivedValues = resultValuesFor((data: data, response: response, error: nil))
//
//        XCTAssertEqual(receivedValues?.data, data)
//        XCTAssertEqual(receivedValues?.response.url, response.url)
//        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
//    }
//
//    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
//        let response = anyHTTPURLResponse()
//
//        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
//
//        let emptyData = Data()
//        XCTAssertEqual(receivedValues?.data, emptyData)
//        XCTAssertEqual(receivedValues?.response.url, response.url)
//        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
//    }
    
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
}
