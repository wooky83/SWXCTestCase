import XCTest

protocol AsyncTestProtocol {
    func asynchronousTest<T>(_ closure: @escaping (CheckedContinuation<T, Error>) -> ()) async throws -> T
}

extension AsyncTestProtocol where Self: XCTestCase {
    func asynchronousTest<T>(_ closure: @escaping (CheckedContinuation<T, Error>) -> ()) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            closure(continuation)
        }
    }
}
