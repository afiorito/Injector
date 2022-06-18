import Foundation

/// A  dependency injection container for resolving services.
public final class Container {
    public typealias Factory<Service> = () -> Service?
    public typealias FactoryResolver<Service> = (_ resolver: Container) -> Service?
    public typealias FactoryModifier<Service> = (_ resolver: Container, _ service: Service) -> Void

    /// A structure that defines the name of a service.
    public struct ServiceName: Hashable, RawRepresentable {
        public let rawValue: String

        public init(_ rawValue: String) {
            self.init(rawValue: rawValue)
        }

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    /// The root container for resolving services.
    public static var root = `default`

    /// Initializes the container.
    public init() {}

    /// Performs one-time initialization of Container services.
    public static var registerServices: (() -> Void)? = {
        if Container.registerServices != nil, let registering = Container.self as? ContainerRegistering.Type {
            registering.registerContainerServices()
        }

        Container.registerServices = nil
    }

    /// A semaphore for synchronizing container access.
    static var lock = NSRecursiveLock()

    // MARK: - Service Registration

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: ServiceName? = nil,
                                         factory: @escaping Factory<Service>) -> Registration<Service> {
        `default`.register(type, name: name, factory: { _ -> Service? in factory() })
    }

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public static func register<Service>(
        _ type: Service.Type = Service.self,
        name: ServiceName? = nil,
        factory: @escaping FactoryResolver<Service>
    ) -> Registration<Service> {
        `default`.register(type, name: name, factory: { resolver -> Service? in factory(resolver) })
    }

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public func register<Service>(_ type: Service.Type = Service.self, name: ServiceName? = nil,
                                  factory: @escaping Factory<Service>) -> Registration<Service> {
        register(type, name: name, factory: { _ -> Service? in factory() })
    }

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public func register<Service>(
        _: Service.Type = Service.self,
        name: ServiceName? = nil,
        factory: @escaping FactoryResolver<Service>
    ) -> Registration<Service> {
        lock.lock()
        defer { lock.unlock() }
        let name = name?.rawValue ?? NILNAME
        let identifier = ObjectIdentifier(Service.self).hashValue
        let registration = Registration(container: self, identifier: identifier, name: name, factory: factory)

        if var namedRegistration = registrations[identifier] {
            namedRegistration[name] = registration
            registrations[identifier] = namedRegistration
        } else {
            registrations[identifier] = [name: registration]
        }

        return registration
    }

    // MARK: - Service Resolution

    /// Resolves a type of service from the main container.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved. Optional, may be inferred by the assignment type.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An instance of the specified service.
    public static func resolve<Service>(_ type: Service.Type = Service.self, name: ServiceName? = nil) -> Service {
        Container.registerServices?()
        return root.resolve(type, name: name)
    }

    /// Resolves a type of service from the current container.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved. Optional, may be inferred by the assignment type.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An instance of the specified service.
    public func resolve<Service>(_ type: Service.Type = Service.self, name: ServiceName? = nil) -> Service {
        lock.lock()
        defer { lock.unlock() }
        if let registration = find(type, name: name?.rawValue ?? NILNAME),
           let service = resolver(registration.scope).resolve(registration: registration) {
            return service
        }

        fatalError("Container :: '\(type)(\(name?.rawValue ?? ""))' registration not found.")
    }

    /// Resolves an optional type of service from the main container.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved. Optional, may be inferred by the assignment type.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An optional instance of the specified service.
    public static func resolveOptional<Service>(_ type: Service.Type = Service.self,
                                                name: ServiceName? = nil) -> Service? {
        Container.registerServices?()
        return root.resolveOptional(type, name: name)
    }

    /// Resolves an optional type of service from the current container.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved. Optional, may be inferred by the assignment type.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An optional instance of the specified service.
    public func resolveOptional<Service>(_ type: Service.Type = Service.self, name: ServiceName? = nil) -> Service? {
        lock.lock()
        defer { lock.unlock() }
        if let registration = find(type, name: name?.rawValue ?? NILNAME),
           let service = resolver(registration.scope).resolve(registration: registration) {
            return service
        }

        return nil
    }

    /// Searches the current container for a matching registration of the given service type and name.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved.
    ///     - name: A name to specify the variant of the service being resolved.
    /// - Returns: An optional instance of the specified service.
    private func find<Service>(_: Service.Type, name: String) -> Registration<Service>? {
        guard let namedRegistrations = registrations[ObjectIdentifier(Service.self).hashValue] else {
            return nil
        }

        return namedRegistrations[name] as? Registration<Service>
    }

    /// Returns a resolver for the given scope.
    ///
    /// - Parameters:
    ///     - scope: The scope of the resolver being returned.
    /// - Returns: An optional instance of the specified service.
    private func resolver(_ scope: Scope) -> any Resolver {
        if let resolver = resolvers[scope] {
            return resolver
        }

        let resolver = scope.resolver
        resolvers[scope] = resolver

        return resolver
    }

    private static var `default` = Container()

    private let lock = Container.lock
    private var resolvers = [Scope: any Resolver]()
    private var registrations = [Int: [String: Any]]()
    private let NILNAME = "*"
}
