//
//  MockLocationProvider.swift
//  COORBAssessmentTests
//
//  Created by Mina Wefky on 02/05/2026.
//

import Combine
@testable import COORBAssessment

final class MockLocationProvider: LocationProviding {

    let currentCountrySubject = CurrentValueSubject<String?, Never>(nil)
    let permissionDeniedSubject = CurrentValueSubject<Bool, Never>(false)
    private(set) var requestLocationCalls = 0

    var currentCountryPublisher: AnyPublisher<String?, Never> {
        currentCountrySubject.eraseToAnyPublisher()
    }

    var permissionDeniedPublisher: AnyPublisher<Bool, Never> {
        permissionDeniedSubject.eraseToAnyPublisher()
    }

    func requestLocation() {
        requestLocationCalls += 1
    }
}
