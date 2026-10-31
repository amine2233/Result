import Foundation

/// Protocol used to constrain `tryMap` to `Result`s with compatible `Error`s.
public protocol ErrorConvertible: Swift.Error {
    static func error(from error: Swift.Error) -> Self
}

extension Result where Failure: ErrorConvertible {

    /// Returns the result of applying `transform` to `Success`es’ values, or wrapping thrown errors.
    public func tryMap<U>(_ transform: (Success) throws -> U) -> Result<U, Failure> {
        return flatMap { value in
            do {
                return .success(try transform(value))
            } catch {
                let convertedError = Failure.error(from: error)
                // Revisit this in a future version of Swift. https://twitter.com/jckarter/status/672931114944696321
                return .failure(convertedError)
            }
        }
    }
}
