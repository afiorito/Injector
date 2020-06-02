@testable import Injector
import XCTest

class ContainerBasicTests: XCTestCase {
    var container: Container!

    override func setUp() {
        super.setUp()
        container = Container()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExplicitResolution() {
        container.register { MockApiService() }

        let apiService: MockApiService? = container.resolve(MockApiService.self)
        XCTAssertNotNil(apiService)
    }

    func testImplicitResolution() {
        container.register { MockApiService() }

        let apiService: MockApiService? = container.resolve() as MockApiService
        XCTAssertNotNil(apiService)
    }

    func testOptionalResolution() {
        container.register { MockApiService() }

        let apiService: MockApiService? = container.resolveOptional()
        XCTAssertNotNil(apiService)
    }

    func testOptionalResolutionNotFound() {
        let service: MockApiService? = container.resolveOptional()
        XCTAssertNil(service)
    }

    func testServiceDependencyResolution() {
        container.register { MockApiService() }
        container.register { MockDatabaseService(self.container.resolveOptional()) }

        let databaseService: MockDatabaseService? = container.resolveOptional()
        XCTAssertNotNil(databaseService)
        XCTAssertNotNil(databaseService?.apiService)
    }

    func testRegistrationOverwritting() {
        container.register { MockNamedService("Quinn") }
        container.register { MockNamedService("Tom") }

        let namedService: MockNamedService? = container.resolveOptional()
        XCTAssertNotNil(namedService)
        XCTAssertEqual(namedService?.name, "Tom")
    }

    func testRegistrationWithResolver() {
        container.register { MockApiService() }
        container.register { resolver in MockDatabaseService(resolver.resolveOptional()) }

        let databaseService: MockDatabaseService? = container.resolveOptional()
        XCTAssertNotNil(databaseService)
        XCTAssertNotNil(databaseService?.apiService)
    }

    func testResolutionProperties() {
        container.register(name: "secret") { MockApiService() }
            .resolveProperties { _, service in
                service.url = "secret"
            }
        let apiService: MockApiService? = container.resolveOptional(name: "secret")
        XCTAssertNotNil(apiService)
        XCTAssertEqual(apiService?.url, "secret")
    }

    func testResolution() {
        container.register { MockApiService() }

        let apiService: MockApiService = container.resolve()
        XCTAssertNotNil(apiService)
    }
}
