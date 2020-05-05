import XCTest
@testable import Injector

class ContainerProtocolTests: XCTestCase {

    var container: Container!

    override func setUp() {
        super.setUp()
        container = Container()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testProtocolWithExplicitResolution() {
        container.register { MockDataService() as MockCaching }

        let service: MockCaching? = container.resolve(MockCaching.self)
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "MockDataService")
    }

    func testProtocolWithInferedResolution() {
        container.register { MockDataService() as MockCaching }

        let service: MockCaching? = container.resolve() as MockCaching
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "MockDataService")
    }

    func testProtocolWithOptionalResolution() {
        container.register { MockDataService() as MockCaching }

        let service: MockCaching? = container.resolveOptional()
        XCTAssertNotNil(service)
        XCTAssertEqual(service?.identifier, "MockDataService")
    }

    func testMultipeProtocolsWithForwarding() {
        container.register { self.container.resolve() as MockDataService as MockCaching }
        container.register { self.container.resolve() as MockDataService as MockUpdating }
        container.register { MockDataService() }

        let dataService: MockDataService? = container.resolveOptional()
        XCTAssertNotNil(dataService)
        XCTAssertEqual(dataService?.identifier, "MockDataService")

        let cache: MockCaching? = container.resolveOptional()
        XCTAssertNotNil(cache)
        XCTAssertEqual(cache?.identifier, "MockDataService")

        let updater: MockUpdating? = container.resolveOptional()
        XCTAssertNotNil(updater)
        XCTAssertEqual(updater?.updating, true)
    }

    func testMultipeProtocolsWithImplements() {
        container.register { MockDataService() }
            .implements(MockCaching.self)
            .implements(MockUpdating.self)

        let service: MockDataService? = container.resolveOptional()
        XCTAssertNotNil(service)
        XCTAssert(service?.identifier == "MockDataService")

        let cache: MockCaching? = container.resolveOptional()
        XCTAssertNotNil(cache)
        XCTAssertEqual(cache?.identifier, "MockDataService")

        let updater: MockUpdating? = container.resolveOptional()
        XCTAssertNotNil(updater)
        XCTAssertEqual(updater?.updating, true)
    }

}
