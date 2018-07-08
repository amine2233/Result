import Foundation

precedencegroup LeftAssociativity {
    associativity: left
}

public protocol Semigroup {
    func operation(_ value: Self) -> Self
}

infix operator<>: LeftAssociativity
infix operator <*>: LeftAssociativity

public func<> <S: Semigroup>(lhs: S, rhs: S) -> S {
    return lhs.operation(rhs)
}

extension Int: Semigroup {
    public func operation(_ value: Int) -> Int {
        return self + value
    }
}

extension Bool: Semigroup {
    public func operation(_ value: Bool) -> Bool {
        return self || value
    }
}

extension String: Semigroup {
    public func operation(_ value: String) -> String {
        return self + value
    }
}

extension Array: Semigroup {
    public func operation(_ elements: Array) -> Array {
        return self + elements
    }
}
