import Foundation

/// A property wrapper for immediately injecting services.
///
/// The wrapped dependent service is resolved immediately using the main container upon initialization.
@propertyWrapper
public struct Injected<Service> {
    public init(name: Container.ServiceName? = nil) {
        service = Container.resolve(Service.self, name: name)
    }

    public var wrappedValue: Service {
        get { service }
        mutating set { service = newValue }
    }

    private var service: Service
}

/// A property wrapper for immediately injecting optional services.
///
/// The wrapped dependent service is resolved immediately using the main container upon initialization.
@propertyWrapper
public struct OptionalInjected<Service> {
    private var service: Service?

    public init(name: Container.ServiceName? = nil) {
        service = Container.resolveOptional(Service.self, name: name)
    }

    public var wrappedValue: Service? {
        get { service }
        mutating set { service = newValue }
    }
}

/// A property wrapper for lazily injecting services.
///
/// The wrapped dependent service is not resolved by the main container until the service is accessed.
@propertyWrapper
public struct LazyInjected<Service> {
    public var name: Container.ServiceName?

    public init(name: Container.ServiceName? = nil) {
        self.name = name
    }

    public var wrappedValue: Service {
        mutating get {
            lock.lock()
            defer { lock.unlock() }
            if service == nil {
                service = Container.resolve(Service.self, name: name)
            }
            return service
        }
        mutating set {
            lock.lock()
            defer { lock.unlock() }
            service = newValue
        }
    }

    private var service: Service!
    private var lock = Container.lock
}
