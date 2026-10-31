import Foundation

extension Result where Failure: Semigroup {

    public func apply<U>(_ transform: Result<(Success) -> U, Failure>) -> Result<U, Failure> {
        switch (transform, self) {
        case let (.success(value), _): return map(value)
        case let (.failure(error), .success): return .failure(error)
        case let (.failure(error1), .failure(error2)): return .failure(error1 <> error2)
        }
    }

    public func or(_ default: Result) -> Result {
        switch (self, `default`) {
        case (.success, _): return self
        case (_, .success): return `default`
        case let (.failure(error1), .failure(error2)): return .failure(error1 <> error2)
        }
    }

    public func and(_ result: Result) -> Result {
        switch (self, result) {
        case (.success, .success): return result
        case (.failure, _): return self
        case (_, .failure): return result
        }
    }

    public static func || (_ lhs: Result, rhs: Result) -> Result {
        return lhs.or(rhs)
    }

    public static func && (_ lhs: Result, rhs: Result) -> Result {
        return lhs.and(rhs)
    }

    public static func <*> <B>(lhs: Result<(Success) -> B, Failure>, rhs: Result<Success, Failure>) -> Result<B, Failure> {
        return rhs.apply(lhs)
    }
}
