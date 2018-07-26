import Foundation

public protocol ResultProtocol {
    
    /// Generic Value
    associatedtype Value
    
    /// Generic Error Value
    associatedtype Error: Swift.Error

    /// Constructs a success wrapping a `value`.
    init(value: Value)
    
    /// Constructs a failure wrapping an `error`.
    init(failure: Error)

    /// Returns `true` if the result is a success, `false` otherwise.
    var isSuccess: Bool { get }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    var isFailure: Bool { get }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    var value: Value? { get }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    var error: Error? { get }
}
