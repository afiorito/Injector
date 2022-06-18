import XCTest
@testable import Injector

class InjectorTests: XCTestCase {
    override func setUp() {
        super.setUp()

        Container.register { MockApiService() }
        Container.register { MockDatabaseService(Container.resolveOptional()) }

        Container.register(name: .quinn) { MockNamedService("Quinn") }
        Container.register(name: .tom) { MockNamedService("Tom") }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicInjection() {
        let injectedService = BasicInjectedService()
        XCTAssertNotNil(injectedService.service)
        XCTAssertNotNil(injectedService.service.apiService)

        let overrideService = MockDatabaseService(nil)
        injectedService.service = overrideService
        XCTAssertIdentical(injectedService.service, overrideService)
    }

    func testOptionalInjection() {
        let optionalInjectedService = OptionalInjectedService()
        XCTAssertNotNil(optionalInjectedService.service)
        XCTAssertNil(optionalInjectedService.notRegistered)

        let overrideService = MockApiService()
        optionalInjectedService.service = overrideService
        XCTAssertIdentical(optionalInjectedService.service, overrideService)
    }

    func testNamedInjection() {
        let injectedService = NamedInjectedService()
        XCTAssertNotNil(injectedService.service)
        XCTAssert(injectedService.service.name == "Quinn")
    }

    func testLazyInjection() {
        let lazyInjectedService = LazyInjectedService()

        XCTAssertNotNil(lazyInjectedService.service)
        XCTAssertNotNil(lazyInjectedService.service.apiService)

        let overrideService = MockDatabaseService(nil)
        lazyInjectedService.service = overrideService
        XCTAssertIdentical(lazyInjectedService.service, overrideService)
    }
}
