import XCTest
@testable import SWXCTestCase
#if os(iOS) || os(tvOS)

final class SWXCTestCaseTests: XCTestCase, LeakTestProtocol {
    func testExample() throws {
        // XCTest Documenation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }

    func testViewControllerDeallocated() throws {
        deallocatorWatcherSpec {
            UIViewController()
        }
    }

    func testViewDeallocated() throws {
        deallocatorWatcherSpec {
            UIView()
        }
    }
}

#endif
