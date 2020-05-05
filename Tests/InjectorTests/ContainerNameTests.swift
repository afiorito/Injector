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
        container.register(name: "Quinn") { MockNamedService("Quinn") }
        container.register(name: "Tom") { MockNamedService("Tom") }

        let quinn: MockNamedService? = container.resolveOptional(name: "Quinn")
        let tom: MockNamedService? = container.resolveOptional(name: "Tom")

        XCTAssertNotNil(quinn)
        XCTAssertNotNil(tom)

        XCTAssert(quinn?.name == "Quinn")
        XCTAssert(tom?.name == "Tom")
    }

    func testContainerInvalidNames() {
        container.register(name: "Quinn") { MockNamedService("Quinn") }
        container.register(name: "Tom") { MockNamedService("Tom") }

        let peter: MockNamedService? = container.resolveOptional(name: "Peter")
        XCTAssertNil(peter)
    }

    func testContainerNamesWithUnnamed() {
        container.register(name: "Quinn") { MockNamedService("Quinn") }
        container.register(name: "Tom") { MockNamedService("Tom") }

        container.register { MockNamedService("Unnamed") }

        let quinn: MockNamedService? = container.resolveOptional(name: "Quinn")
        let tom: MockNamedService? = container.resolveOptional(name: "Tom")
        let unnamed: MockNamedService? = container.resolveOptional()

        XCTAssertNotNil(quinn)
        XCTAssertNotNil(tom)
        XCTAssertNotNil(unnamed)

        XCTAssert(quinn?.name == "Quinn")
        XCTAssert(tom?.name == "Tom")
        XCTAssert(unnamed?.name == "Unnamed")
    }

    func testContainerNamesUnnamedNotFound() {
        container.register(name: "Quinn") { MockNamedService("Quinn") }
        container.register(name: "Tom") { MockNamedService("Tom") }

        let unnamed: MockNamedService? = container.resolveOptional()
        XCTAssertNil(unnamed)
    }

}
