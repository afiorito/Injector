import XCTest
@testable import Injector

class ContainerScopeReferenceTests: XCTestCase {

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
        container.register { MockApiService() }
        container.register { MockHybridApiService(self.container.resolveOptional(), self.container.resolveOptional()) }

        let service: MockHybridApiService? = container.resolveOptional()

        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.jsonApi)
        XCTAssertNotNil(service?.xmlApi)
        XCTAssertEqual(service?.jsonApi?.uuid, service?.xmlApi?.uuid)
    }

    func testContainerScopeShared() {
        container.register { MockApiService() }.scope(.shared)

        var service1: MockApiService? = container.resolveOptional()
        var service2: MockApiService? = container.resolveOptional()

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)

        XCTAssertEqual(service1?.uuid, service2?.uuid)

        let initialUUID = service1?.uuid

        service1 = nil
        service2 = nil

        let service: MockApiService? = container.resolveOptional()

        XCTAssertNotEqual(initialUUID, service?.uuid)
     }

    func testContainerScopeSingleton() {
        container.register { MockApiService() }.scope(.singleton)

        let service1: MockApiService? = container.resolveOptional()
        let service2: MockApiService? = container.resolveOptional()

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertEqual(service1?.uuid, service2?.uuid)
    }

    func testContainerScopeUnique() {
        container.register { MockApiService() }.scope(.unique)

        let service1: MockApiService? = container.resolveOptional()
        let service2: MockApiService? = container.resolveOptional()

        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        XCTAssertNotEqual(service1?.uuid, service2?.uuid)
    }

}
