import XCTest

#if os(iOS) || os(tvOS)

public protocol LeakTestProtocol {
    func deallocatorWatcherSpec<T: AnyObject>(
        _ lifecycle: ViewControllerLifecycle,
        block object: () -> T
    )

    func deallocatorWatcherSpecAsync<T: AnyObject>(
        _ lifecycle: ViewControllerLifecycle,
        timeout seconds: TimeInterval,
        block object: () -> T
    )

    func wait(
        for condition: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval,
        description: String,
        file: StaticString,
        line: UInt
    )
}

extension LeakTestProtocol where Self: XCTestCase {
    func deallocatorWatcherSpec<T: AnyObject>(
        _ lifecycle: ViewControllerLifecycle = .viewDidLoad,
        block object: () -> T
    ) {
        weak var weakReferenceToObject: T?
        autoreleasepool {
            let object = object()
            deallocatorWatcherFactory(
                object,
                lifecycle: lifecycle
            )
            weakReferenceToObject = object
            XCTAssertNotNil(weakReferenceToObject)
        }

        XCTAssertNil(weakReferenceToObject)
    }

    func deallocatorWatcherSpecAsync<T: AnyObject>(
        _ lifecycle: ViewControllerLifecycle = .viewDidLoad,
        timeout seconds: TimeInterval = 0.5,
        block object: () -> T
    ) {
        weak var weakReferenceToObject: T?
        let autoreleasepoolExpectation = expectation(description: "auto releasepool")
        autoreleasepool {
            let object = object()
            deallocatorWatcherFactory(
                object,
                lifecycle: lifecycle
            )

            weakReferenceToObject = object
            XCTAssertNotNil(weakReferenceToObject)

            autoreleasepoolExpectation.fulfill()
        }

        wait(for: [autoreleasepoolExpectation], timeout: seconds)
        wait(
            for: weakReferenceToObject == nil,
            timeout: seconds,
            description: "The object should be deallocated since no strong reference points to it."
        )
    }

    /// Checks for the callback to be the expected value within the given timeout.
    ///
    /// - Parameters:
    ///   - condition: The condition to check for.
    ///   - timeout: The timeout in which the callback should return true.
    ///   - description: A string to display in the test log for this expectation, to help diagnose failures.
    func wait(
        for condition: @autoclosure @escaping () -> Bool,
        timeout: TimeInterval,
        description: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let end = Date().addingTimeInterval(timeout)

        var value = false
        let closure: () -> Void = {
            value = condition()
        }

        while !value && 0 < end.timeIntervalSinceNow {
            if RunLoop.current.run(mode: RunLoop.Mode.default, before: Date(timeIntervalSinceNow: 0.002)) {
                Thread.sleep(forTimeInterval: 0.002)
            }
            closure()
        }

        closure()

        XCTAssertTrue(value, "Timed out waiting for condition to be true: \"\(description)\"", file: file, line: line)
    }
}

private extension LeakTestProtocol {
    func deallocatorWatcherFactory<T: AnyObject>(
        _ object: T,
        lifecycle: ViewControllerLifecycle = .viewDidLoad
    ) {
        switch object {
        case let viewObject as UIView:
            viewObject.awakeFromNib()
        case let viewControllerObject as UIViewController:
            viewControllerObject
                .build(lifecycle)
        default:
            break
        }
    }
}

extension UIViewController {
    @discardableResult
    func build(_ lifecycle: ViewControllerLifecycle) -> Self {
        ViewControllerLifecycle.all.forEach {
            guard $0.rawValue <= lifecycle.rawValue else { return }
            switch $0 {
            case .viewDidLoad: self.viewDidLoad()
            case .viewWillAppear: self.viewWillAppear(false)
            case .viewDidAppear: self.viewDidAppear(false)
            case .viewWillDisappear: self.viewWillDisappear(false)
            case .viewDidDisappear: self.viewDidDisappear(false)
            default: break
            }
        }

        return self
    }
}

public struct ViewControllerLifecycle: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    static let viewDidLoad = ViewControllerLifecycle(rawValue: 1 << 0)
    static let viewWillAppear = ViewControllerLifecycle(rawValue: 1 << 1)
    static let viewDidAppear = ViewControllerLifecycle(rawValue: 1 << 2)
    static let viewWillDisappear = ViewControllerLifecycle(rawValue: 1 << 3)
    static let viewDidDisappear = ViewControllerLifecycle(rawValue: 1 << 4)

    fileprivate static var all: [Self] {
        [ .viewDidLoad, .viewWillAppear, .viewDidAppear, .viewWillDisappear, .viewDidDisappear ]
    }
}

#endif
