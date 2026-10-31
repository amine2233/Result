import Foundation

extension Result: ResultProtocol {

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var isFailure: Bool {
        return !isSuccess
    }

    public var value: Success? {
        switch self {
        case let .success(value):
            return value
        case .failure:
            return nil
        }
    }

    public var error: Failure? {
        switch self {
        case let .failure(error):
            return error
        case .success:
            return nil
        }
    }
}

// MARK: ResultProtocol Extension add result in protocol

extension ResultProtocol {

    /// Get result value
    public var result: Result<Success, Failure> {
        if let value = value {
            return .success(value)
        }
        // A `ResultProtocol` is either a success or a failure, so one of them is always set.
        return .failure(error!)
    }
}

// MARK: String Convertible

extension Result: @retroactive CustomStringConvertible {

    /// The textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure.
    public var description: String {
        switch self {
        case let .success(value):
            return String(describing: value)

        case let .failure(error):
            return String(describing: error)
        }
    }
}

// MARK: Debug String Convertible

extension Result: @retroactive CustomDebugStringConvertible {

    /// The debug textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure in addition to the value or error.
    public var debugDescription: String {
        switch self {
        case let .success(value):
            return String(describing: value)

        case let .failure(error):
            return String(describing: error)
        }
    }
}

// MARK: Constructors

extension Result {

    /// Constructs a success wrapping a `value`.
    public init(value: Success) {
        self = .success(value)
    }

    /// Constructs a failure wrapping an `error`.
    public init(failure: Failure) {
        self = .failure(failure)
    }

    /// Constructs a error wrapping an `error`.
    public init(error: Failure) {
        self = .failure(error)
    }

    /// Constructs a result from an `Optional`, failing with `Failure` if `nil`.
    public init(_ value: Success?, failWith: @autoclosure () -> Failure) {
        if let value = value {
            self = .success(value)
        } else {
            self = .failure(failWith())
        }
    }
}

// MARK: Work with result

extension Result {

    /// Returns the result of applying `transform` with optional value to `Success`es’ values,
    /// or re-wrapping `Failure`’s errors.
    public func compactMap<U>(_ transform: (Success?) -> U) -> Result<U, Failure> {
        switch self {
        case let .success(value): return .success(transform(value))
        case let .failure(error): return .failure(error)
        }
    }

    /// Returns a new Result by mapping `Failure`'s with optional value to `transform`,
    /// or re-wrapping `Success`’s errors.
    public func compactMapError<E: Swift.Error>(_ transform: (Failure?) -> E) -> Result<Success, E> {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(error): return .failure(transform(error))
        }
    }

    /// Returns a Result with a tuple of the receiver and `other` values if both
    /// are `Success`es, or re-wrapping the error of the earlier `Failure`.
    public func fanout<U>(_ other: @autoclosure () -> Result<U, Failure>) -> Result<(Success, U), Failure> {
        return flatMap { left in other().map { right in (left, right) } }
    }

    /// Returns a new Result by mapping `Success`es’ values using `success`, and by mapping `Failure`'s values using `failure`.
    public func bimap<U, E: Swift.Error>(success: (Success) -> U, failure: (Failure) -> E) -> Result<U, E> {
        switch self {
        case let .success(value): return .success(success(value))
        case let .failure(error): return .failure(failure(error))
        }
    }
}

// MARK: Result work with throws

extension Result where Failure == Swift.Error {

    /// Constructs a result from throwing completion, failing with `Error` if throwing error
    public init(block: () throws -> Success) {
        do {
            self = .success(try block())
        } catch {
            self = .failure(error)
        }
    }

    /// Returns a new result by mapping `Success`es’ values using a throwing `transform`.
    public func tryMap<U>(_ transform: (Success) throws -> U) -> Result<U, Failure> {
        return flatMap { value in
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        }
    }
}

extension Result {

    /// Return value or catch error
    public func convertThrow() throws -> Success {
        return try get()
    }

    /// Returns the value of .Success if it is a `Success`, or `Error` otherwise.
    public func resolve() throws -> Success {
        return try get()
    }
}

// MARK: Result recover & Higher-order functions

extension Result {

    /// Returns `self.value` if this result is a .Success, or the given value otherwise.
    public func recover(_ value: @autoclosure () -> Success) -> Success {
        switch self {
        case let .success(success): return success
        case .failure: return value()
        }
    }

    /// Returns this result if it is a .Success, or the given result otherwise.
    public func recover(with result: @autoclosure () -> Self) -> Self {
        switch self {
        case .success: return self
        case .failure: return result()
        }
    }
}

// MARK: Result Optional

extension Result {

    /// Returns the value of `left` if it is a `Success`, or `right` otherwise. Short-circuits.
    public static func ?? (left: Result<Success, Failure>, right: @autoclosure () -> Success) -> Success {
        return left.recover(right())
    }

    /// Returns `left` if it is a `Success`es, or `right` otherwise. Short-circuits.
    public static func ?? (left: Result<Success, Failure>, right: @autoclosure () -> Result<Success, Failure>) -> Result<Success, Failure> {
        return left.recover(with: right())
    }
}

// MARK: Callback style

extension Result {

    /// Transform a result into a callback based function. If the result was a failure,
    /// the transform will not be executed and the failure is passed to the callback instead.
    public func flatMap<U>(_ transform: @escaping (Success, @escaping (Result<U, Failure>) -> Void) -> Void) -> (@escaping (Result<U, Failure>) -> Void) -> Void {
        return { other in
            switch self {
            case let .success(value): transform(value, other)
            case let .failure(error): other(.failure(error))
            }
        }
    }
}
