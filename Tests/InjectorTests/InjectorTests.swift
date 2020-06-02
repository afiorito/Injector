@testable import Injector
import XCTest

class InjectorTests: XCTestCase {
    override func setUp() {
        super.setUp()

        Container.register { MockApiService() }
        Container.register { MockDatabaseService(Container.resolveOptional()) }

        Container.register(name: "Quinn") { MockNamedService("Quinn") }
        Container.register(name: "Tom") { MockNamedService("Tom") }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicInjection() {
        let injectedService = BasicInjectedService()
        XCTAssertNotNil(injectedService.service)
        XCTAssertNotNil(injectedService.service.apiService)
    }

    func testOptionalInjection() {
        let optionalInjectedService = OptionalInjectedService()
        XCTAssertNotNil(optionalInjectedService.service)
        XCTAssertNil(optionalInjectedService.notRegistered)
    }

    func testNamedInjection() {
        let injectedService = NamedInjectedService()
        XCTAssertNotNil(injectedService.service)
        XCTAssert(injectedService.service.name == "Quinn")
    }

    func testLazyInjection() {
        let lazyInjectedService = LazyInjectedService()
        XCTAssertFalse(lazyInjectedService.$service.isInjected)
        XCTAssertNotNil(lazyInjectedService.service)
        XCTAssertNotNil(lazyInjectedService.service.apiService)
        XCTAssertTrue(lazyInjectedService.$service.isInjected)
    }
}
