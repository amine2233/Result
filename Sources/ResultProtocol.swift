import Foundation

public protocol ResultProtocol {
    associatedtype Value
    associatedtype Error: Swift.Error

    init(value: Value)
    init(failure: Error)

    var isSuccess: Bool { get }
    var isFailure: Bool { get }
    var value: Value? { get }
    var error: Error? { get }
}
