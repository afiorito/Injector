import XCTest
@testable import Injector

class ContainerNameTests: XCTestCase {
    var container: Container!

    override func setUp() {
        super.setUp()
        container = Container()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testContainerValidNames() {
        container.register(name: .quinn) { MockNamedService("Quinn") }
        container.register(name: .tom) { MockNamedService("Tom") }

        let quinn: MockNamedService? = container.resolveOptional(name: .quinn)
        let tom: MockNamedService? = container.resolveOptional(name: .tom)

        XCTAssertNotNil(quinn)
        XCTAssertNotNil(tom)

        XCTAssert(quinn?.name == "Quinn")
        XCTAssert(tom?.name == "Tom")
    }

    func testContainerInvalidNames() {
        container.register(name: .quinn) { MockNamedService("Quinn") }
        container.register(name: .tom) { MockNamedService("Tom") }

        let peter: MockNamedService? = container.resolveOptional(name: .peter)
        XCTAssertNil(peter)
    }

    func testContainerNamesWithUnnamed() {
        container.register(name: .quinn) { MockNamedService("Quinn") }
        container.register(name: .tom) { MockNamedService("Tom") }

        container.register { MockNamedService("Unnamed") }

        let quinn: MockNamedService? = container.resolveOptional(name: .quinn)
        let tom: MockNamedService? = container.resolveOptional(name: .tom)
        let unnamed: MockNamedService? = container.resolveOptional()

        XCTAssertNotNil(quinn)
        XCTAssertNotNil(tom)
        XCTAssertNotNil(unnamed)

        XCTAssert(quinn?.name == "Quinn")
        XCTAssert(tom?.name == "Tom")
        XCTAssert(unnamed?.name == "Unnamed")
    }

    func testContainerNamesUnnamedNotFound() {
        container.register(name: .quinn) { MockNamedService("Quinn") }
        container.register(name: .tom) { MockNamedService("Tom") }

        let unnamed: MockNamedService? = container.resolveOptional()
        XCTAssertNil(unnamed)
    }
}
