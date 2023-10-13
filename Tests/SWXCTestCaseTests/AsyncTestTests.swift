import XCTest
@testable import SWXCTestCase

final class AsyncTestTests: XCTestCase, AsyncTestProtocol {

    func testSimpleAsync() async throws {
        let result = try await asynchronousTest { continuation in
            continuation.resume(returning: 1)
        }
        XCTAssertEqual(result, 1)
    }

    func testClosureAsync() async throws {
        func closure(_ completion: @escaping () -> ()) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion()
            }
        }
        let result = try await asynchronousTest { continuation in
            closure {
                continuation.resume(returning: 1)
            }
        }
        XCTAssertEqual(result, 1)
    }

}

