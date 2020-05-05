import XCTest
@testable import Injector

class ContainerScopeNameTests: XCTestCase {

    var container: Container!

    override func setUp() {
        super.setUp()
        container = Container()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testContainerScopeNameGraph() {
        // graph scope is the default
        container.register(name: "Quinn") { MockNamedService("Quinn") }
        container.register(name: "Tom") { MockNamedService("Tom") }

        let service1: MockNamedService? = container.resolveOptional(name: "Quinn")
        let service2: MockNamedService? = container.resolveOptional(name: "Tom")
        let service3: MockNamedService? = container.resolveOptional(name: "Tom")

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertNotNil(service3)
        XCTAssertEqual(service1?.name, "Quinn")
        XCTAssertEqual(service2?.name, "Tom")
        XCTAssertEqual(service3?.name, "Tom")
        XCTAssertNotEqual(service1?.uuid, service2?.uuid)
        XCTAssertNotEqual(service2?.uuid, service3?.uuid)
    }

    func testContainerScopeNameShared() {
        container.register(name: "Quinn") { MockNamedService("Quinn") }.scope(.shared)
        container.register(name: "Tom") { MockNamedService("Tom") }.scope(.shared)

        let service1: MockNamedService? = container.resolveOptional(name: "Quinn")
        let service2: MockNamedService? = container.resolveOptional(name: "Tom")
        let service3: MockNamedService? = container.resolveOptional(name: "Tom")

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertNotNil(service3)
        XCTAssertEqual(service1?.name, "Quinn")
        XCTAssertEqual(service2?.name, "Tom")
        XCTAssertEqual(service3?.name, "Tom")
        XCTAssertNotEqual(service1?.uuid, service2?.uuid)
        XCTAssertEqual(service2?.uuid, service3?.uuid)
    }

    func testContainerScopeNameApplication() {
        container.register(name: "Quinn") { MockNamedService("Quinn") }.scope(.singleton)
        container.register(name: "Tom") { MockNamedService("Tom") }.scope(.singleton)

        let service1: MockNamedService? = container.resolveOptional(name: "Quinn")
        let service2: MockNamedService? = container.resolveOptional(name: "Tom")
        let service3: MockNamedService? = container.resolveOptional(name: "Tom")

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertNotNil(service3)
        XCTAssertEqual(service1?.name, "Quinn")
        XCTAssertEqual(service2?.name, "Tom")
        XCTAssertEqual(service3?.name, "Tom")
        XCTAssertNotEqual(service1?.uuid, service2?.uuid)
        XCTAssertEqual(service2?.uuid, service3?.uuid)
    }

    func testContainerScopeNameUnique() {
        container.register(name: "Quinn") { MockNamedService("Quinn") }.scope(.unique)
        container.register(name: "Tom") { MockNamedService("Tom") }.scope(.unique)

        let service1: MockNamedService? = container.resolveOptional(name: "Quinn")
        let service2: MockNamedService? = container.resolveOptional(name: "Tom")
        let service3: MockNamedService? = container.resolveOptional(name: "Tom")

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertNotNil(service3)
        XCTAssertEqual(service1?.name, "Quinn")
        XCTAssertEqual(service2?.name, "Tom")
        XCTAssertEqual(service3?.name, "Tom")
        XCTAssertNotEqual(service1?.uuid, service2?.uuid)
        XCTAssertNotEqual(service2?.uuid, service3?.uuid)
    }

}
