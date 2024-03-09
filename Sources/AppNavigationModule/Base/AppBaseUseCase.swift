//
//  File.swift
//  
//
//  Created by Mohan Singh Thagunna on 27/02/2024.
//

import Foundation
import Combine

public protocol AppBaseUseCase {
    associatedtype Q
    associatedtype R
    func execute(_ param: Q, onComplete: @escaping (Result<R, Error>) -> Void)
}

public protocol AppBaseUseCaseAlt {
    associatedtype Q
    associatedtype R
    func execute(_ param: Q) -> AnyPublisher<R, Error>
}

public protocol AppNetworkUseCase {
    associatedtype R
    func execute(_ param: [String: Any]) -> AnyPublisher<R, Error>
}
