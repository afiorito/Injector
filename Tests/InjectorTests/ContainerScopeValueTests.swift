import XCTest
@testable import Injector

class ContainerScopeValueTests: XCTestCase {
    var container: Container!

    override func setUp() {
        super.setUp()
        container = Container()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testContainerScopeGraph() {
        // graph scope is the default
        container.register { MockValue() }
        container.register { MockValueService(self.container.resolveOptional(), self.container.resolveOptional()) }

        let service: MockValueService? = container.resolveOptional()

        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.value1)
        XCTAssertNotNil(service?.value2)
        XCTAssertNotEqual(service?.value1?.uuid, service?.value2?.uuid)
    }

    func testContainerScopeShared() {
        container.register { MockValue() }.scope(.shared)

        var value1: MockValue? = container.resolveOptional()
        var value2: MockValue? = container.resolveOptional()

        XCTAssertNotNil(value1)
        XCTAssertNotNil(value2)
        XCTAssertNotEqual(value1?.uuid, value2?.uuid)

        let initialUUID = value1?.uuid

        value1 = nil
        value2 = nil

        let value: MockValue? = container.resolveOptional()

        XCTAssertNotEqual(value?.uuid, initialUUID)
    }

    func testContainerScopeApplication() {
        container.register { MockValue() }.scope(.singleton)

        let value1: MockValue? = container.resolveOptional()
        let value2: MockValue? = container.resolveOptional()

        XCTAssertNotNil(value1)
        XCTAssertNotNil(value2)
        XCTAssertEqual(value1?.uuid, value2?.uuid)
    }

    func testContainerScopeUnique() {
        container.register { MockValue() }.scope(.unique)

        let value1: MockValue? = container.resolveOptional()
        let value2: MockValue? = container.resolveOptional()

        XCTAssertNotNil(value1)
        XCTAssertNotNil(value2)
        XCTAssertNotEqual(value1?.uuid, value2?.uuid)
    }
}
