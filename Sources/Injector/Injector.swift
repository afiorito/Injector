import Foundation

/// A property wrapper for immediately injecting services.
///
/// The wrapped dependent service is resolved immediately using the main container upon initialization.
@propertyWrapper
public struct Injected<Service> {

    public init(name: String? = nil) {
        self.service = Container.resolve(Service.self, name: name)
    }

    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }

    public var projectedValue: Injected<Service> {
        get { return self }
        mutating set { self = newValue }
    }

    private var service: Service
}

/// A property wrapper for immediately injecting optional services.
///
/// The wrapped dependent service is resolved immediately using the main container upon initialization.
@propertyWrapper
public struct OptionalInjected<Service> {
    private var service: Service?
    public init() {
        self.service = Container.resolveOptional(Service.self)
    }
    public init(name: String? = nil) {
        self.service = Container.resolveOptional(Service.self, name: name)
    }
    public var wrappedValue: Service? {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: OptionalInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

/// A property wrapper for lazily injecting services.
///
/// The wrapped dependent service is not resolved by the main container until the service is accessed.
@propertyWrapper
public struct LazyInjected<Service> {

    public var name: String?

    public init(name: String? = nil) {
        self.name = name
    }

    public var isInjected: Bool {
        return service != nil
    }

    public var wrappedValue: Service {
        mutating get {
            if self.service == nil {
                self.service = Container.resolve(Service.self, name: name)
            }
            return service
        }
        mutating set { service = newValue  }
    }

    public var projectedValue: LazyInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }

    private var service: Service!
}
