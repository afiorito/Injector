import Foundation
import Injector

extension Container: ContainerRegistering {
    public static func registerContainerServices() {
        register { MockApiService() }
        register { MockDatabaseService(resolveOptional()) }
    }
}

extension Container.ServiceName {
    static let peter = Self("peter")
    static let quinn = Self("quinn")
    static let secret = Self("secret")
    static let tom = Self("tom")
}

// MARK: - Mock Protocols

protocol MockCaching {
    var identifier: String { get }
}

protocol MockUpdating {
    var updating: Bool { get }
}

// MARK: - Mock Services

class MockApiService {
    var url: String = ""
    let uuid = UUID()
}

class MockDataService: MockCaching, MockUpdating {
    var identifier: String { "MockDataService" }
    var updating: Bool { true }
}

class MockDatabaseService {
    let apiService: MockApiService?

    init(_ apiService: MockApiService?) {
        self.apiService = apiService
    }
}

class MockFileSystemService {}

class MockHybridApiService {
    let jsonApi: MockApiService?
    let xmlApi: MockApiService?

    init(_ jsonApi: MockApiService?, _ xmlApi: MockApiService?) {
        self.jsonApi = jsonApi
        self.xmlApi = xmlApi
    }
}

class MockNamedService {
    let name: String
    let uuid = UUID()

    init(_ name: String) {
        self.name = name
    }
}

struct MockValue {
    let uuid = UUID()
    var name: String { "MockValue" }
}

class MockValueService {
    let value1: MockValue?
    let value2: MockValue?

    init(_ value1: MockValue?, _ value2: MockValue?) {
        self.value1 = value1
        self.value2 = value2
    }
}

// MARK: - @Injected Mocks

class BasicInjectedService {
    @Injected var service: MockDatabaseService
}

class OptionalInjectedService {
    @OptionalInjected var service: MockApiService?
    @OptionalInjected var notRegistered: MockFileSystemService?
}

class LazyInjectedService {
    @LazyInjected var service: MockDatabaseService
}

class NamedInjectedService {
    @Injected(name: .quinn) var service: MockNamedService
}
