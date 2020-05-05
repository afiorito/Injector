import XCTest
@testable import Injector

class ContainerStaticTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExplicitResolution() {
        let apiService: MockApiService? = Container.resolve(MockApiService.self)
        XCTAssertNotNil(apiService)
    }

    func testImplicitResolution() {
        let apiService: MockApiService? = Container.resolve() as MockApiService
        XCTAssertNotNil(apiService)
    }

    func testOptionalResolution() {
        let apiService: MockApiService? = Container.resolveOptional()
        XCTAssertNotNil(apiService)
    }

    func testOptionalResolutionNotFound() {
        let service: MockFileSystemService? = Container.resolveOptional()
        XCTAssertNil(service)
    }

    func testServiceDependencyResolution() {
        let databaseService: MockDatabaseService? = Container.resolveOptional()
        XCTAssertNotNil(databaseService)
        XCTAssertNotNil(databaseService?.apiService)
    }

    func testRegistrationOverwritting() {
        Container.register { MockNamedService("Quinn") }
        Container.register { MockNamedService("Tom") }

        let namedService: MockNamedService? = Container.resolveOptional()
        XCTAssertNotNil(namedService)
        XCTAssertEqual(namedService?.name, "Tom")
    }

    func testRegistrationWithResolver() {
        Container.register { MockApiService() }
        Container.register { resolver in MockDatabaseService(resolver.resolveOptional()) }

        let databaseService: MockDatabaseService? = Container.resolveOptional()
        XCTAssertNotNil(databaseService)
        XCTAssertNotNil(databaseService?.apiService)
    }

    func testResolutionProperties() {
        Container.register(name: "secret") { MockApiService() }
            .resolveProperties { (_, service) in
                service.url = "secret"
        }
        let apiService: MockApiService? = Container.resolveOptional(name: "secret")
        XCTAssertNotNil(apiService)
        XCTAssertEqual(apiService?.url, "secret")
    }

    func testResolution() {
        let databaseService: MockDatabaseService = Container.resolve()
        XCTAssertNotNil(databaseService.apiService)
    }

}
