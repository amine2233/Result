import Foundation

/// Result
public enum Result<Value, Error: Swift.Error>: ResultProtocol {

    case success(Value)

    case failure(Error)

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        case .success:
            return false
        }
    }

    public var value: Value? {
        switch self {
        case let .success(value):
            return value
        default:
            return nil
        }
    }

    public var error: Error? {
        switch self {
        case let .failure(error):
            return error
        default:
            return nil
        }
    }
}

// MARK: ResultProtocol Extension add result in protocol

extension ResultProtocol {

    /// Get result value
    public var result: Result<Value, Error> {
        return Result(value, failWith: error!)
    }
}

// MARK: String Convertible

extension Result: CustomStringConvertible {

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

extension Result: CustomDebugStringConvertible {

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
    public init(value: Value) {
        self = .success(value)
    }

    /// Constructs a failure wrapping an `error`.
    public init(failure: Error) {
        self = .failure(failure)
    }

    /// Constructs a error wrapping an `error`.
    public init(error: Error) {
        self = .failure(error)
    }

    /// Constructs a result from an `Optional`, failing with `Error` if `nil`.
    public init(_ value: Value?, failWith: @autoclosure () -> Error) {
        self = value.map(Result.success) ?? .failure(failWith())
    }
}

// MARK: Work with result

extension Result {

    /// Get rsult value
    public var result: Result<Value, Error> {
        return self
    }

    /// Returns the result of applying `transform` with optional value to `Success`es’ values,
    /// or re-wrapping `Failure`’s errors.
    public func compactMap<U>(_ transform: (Value?) -> U) -> Result<U, Error> {
        switch self {
        case let .success(value): return .success(transform(value))
        case let .failure(error): return .failure(error)
        }
    }

    /// Returns a new Result by mapping `Failure`'s with optional value to `transform`,
    /// or re-wrapping `Success`’s errors.
    public func compactMapError<E: Swift.Error>(_ transform: (Error?) -> E) -> Result<Value, E> {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(error): return .failure(transform(error))
        }
    }

    /// Returns the result of applying `transform` to `Success`es’ values, or re-wrapping `Failure`’s errors.
    public func flatMap<U>(_ transform: (Value) -> Result<U, Error>) -> Result<U, Error> {
        switch self {
        case let .success(value): return transform(value)
        case let .failure(error): return .failure(error)
        }
    }

    /// Returns a new Result by mapping `Success`es’ values using `transform`, or re-wrapping `Failure`s’ errors.
    public func map<U>(_ transform: (Value) -> U) -> Result<U, Error> {
        return flatMap { .success(transform($0)) }
    }

    /// Returns a Result with a tuple of the receiver and `other` values if both
    /// are `Success`es, or re-wrapping the error of the earlier `Failure`.
    public func fanout<U>(_ other: @autoclosure () -> Result<U, Error>) -> Result<(Value, U), Error> {
        return flatMap { left in other().map { right in (left, right) } }
    }

    /// Returns the result of applying `transform` to `Failure`’s errors, or re-wrapping `Success`es’ values.
    public func flatMapError<E>(_ transform: (Error) -> Result<Value, E>) -> Result<Value, E> {
        switch self {
        case let .success(value): return .success(value)
        case let .failure(error): return transform(error)
        }
    }

    /// Returns a new Result by mapping `Failure`'s values using `transform`, or re-wrapping `Success`es’ values.
    public func mapError<E>(_ transfrom: (Error) -> E) -> Result<Value, E> {
        return flatMapError { .failure(transfrom($0)) }
    }

    /// Returns a new Result by mapping `Success`es’ values using `success`, and by mapping `Failure`'s values using `failure`.
    public func bimap<U, E>(success: (Value) -> U, failure: (Error) -> E) -> Result<U, E> {
        switch self {
        case let .success(value): return .success(success(value))
        case let .failure(error): return .failure(failure(error))
        }
    }
}

// MARK: Result work with throws

public extension Result {

    /// Constructs a result from throwing completion, failing with `Error` if throwing error
    public init(_ throwing: () throws -> Value) {
        do {
            self = .success(try throwing())
        } catch {
            self = .failure(error as! Error)
        }
    }

    /// Return value or catch error
    public func convertThrow() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}

// MARK: Result recover & Higher-order functions

public extension Result {

    /// Returns `self.value` if this result is a .Success, or the given value otherwise. Equivalent with `??`
    public func recover(_ value: @autoclosure () -> Value) -> Value {
        return self.value ?? value()
    }

    /// Returns this result if it is a .Success, or the given result otherwise. Equivalent with `??`
    public func recover(with result: @autoclosure () -> Result<Value, Error>) -> Result<Value, Error> {
        switch self {
        case .success: return self
        case .failure: return result()
        }
    }
}

// MARK: Result Equatable

extension Result where Value: Equatable, Error: Equatable {

    /// Returns `true` if `left` and `right` are both `Success`es and their values are equal,
    /// or if `left` and `right` are both `Failure`s and their errors are equal.
    public static func == (left: Result<Value, Error>, right: Result<Value, Error>) -> Bool {
        if let left = left.value, let right = right.value {
            return left == right
        } else if let left = left.error, let right = right.error {
            return left == right
        }
        return false
    }

    /// Returns `true` if `left` and `right` represent different cases, or if they represent the same case but different values.
    public static func != (left: Result<Value, Error>, right: Result<Value, Error>) -> Bool {
        return !(left == right)
    }
}

// MARK: Result Optinal

extension Result {

    /// Returns the value of `left` if it is a `Success`, or `right` otherwise. Short-circuits.
    public static func ?? (left: Result<Value, Error>, right: @autoclosure () -> Value) -> Value {
        return left.recover(right())
    }

    /// Returns `left` if it is a `Success`es, or `right` otherwise. Short-circuits.
    public static func ?? (left: Result<Value, Error>, right: @autoclosure () -> Result<Value, Error>) -> Result<Value, Error> {
        return left.recover(with: right())
    }
}

// MARK: Result Resolve

extension Result {

    /// Returns the value of .Success if it is a `Success`, or `Error` otherwise.
    public func resolve() throws -> Value {
        switch self {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        }
    }
}

extension Result {

    public init(block: () throws -> Value) {
        do {
            self = try .success(block())
        } catch let error {
            self = .failure(error as! Error)
        }
    }

    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func map<U, Error>(_ transform: @escaping (Value) -> U) -> Result<U, Error> {
        switch self {
        case let .success(value): return .success(transform(value))
        case let .failure(error): return .failure(error as! Error)
        }
    }

    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func flatMap<U, Error>(_ transform: (Value) -> Result<U, Error>) -> Result<U, Error> {
        switch self {
        case let .success(value): return transform(value)
        case let .failure(error): return .failure(error as! Error)
        }
    }

    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func flatMap<U, Error>(_ transform: (Value) throws -> U) -> Result<U, Error> {
        return flatMap { value in
            do {
                return .success(try transform(value))
            } catch let error {
                return .failure(error as! Error)
            }
        }
    }
    /**
     Transform a result into another result using a function. If the result was an error,
     the function will not be executed and the error returned instead.
     */
    public func flatMap<U, Error>(_ transform:@escaping (Value, (@escaping(Result<U, Error>)->Void))->Void) -> (@escaping(Result<U, Error>)->Void)->Void {
        return { other in
            switch self {
            case let .success(value): transform(value, other)
            case let .failure(error): other(.failure(error as! Error))
            }
        }
    }
}

/**
 Provide a default value for failed results.
 */
public func ?? <Value, Error> (result: Result<Value, Error>, defaultValue: @autoclosure () -> Value) -> Value {
    switch result {
    case .success(let value): return value
    case .failure: return defaultValue()
    }
}
