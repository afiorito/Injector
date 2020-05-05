import Foundation

/// A  dependency injection container for resolving services.
public final class Container {
    public typealias Factory<Service> = () -> Service?
    public typealias FactoryResolver<Service> = (_ resolver: Container) -> Service?
    public typealias FactoryModifier<Service> = (_ resolver: Container, _ service: Service) -> Void

    /// The main container for registering services.
    public static var container: Container = Container()

    public init() {}

    /// Performs one-time initialization of Container services.
    public static var registerServices: (() -> Void)? = {
        if Container.registerServices != nil, let registering = Container.self as? ContainerRegistering.Type {
            registering.registerContainerServices()
        }

        Container.registerServices = nil
    }

    // MARK: - Service Registration

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                         factory: @escaping Container.Factory<Service>) -> Registration<Service> {
        return container.register(type, name: name, factory: { _ -> Service? in return factory() })
    }

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                         factory: @escaping Container.FactoryResolver<Service>) -> Registration<Service> {
        return container.register(type, name: name, factory: { resolver -> Service? in return factory(resolver) })
    }

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                        factory: @escaping Container.Factory<Service>) -> Registration<Service> {
        return register(type, name: name, factory: { _ -> Service? in return factory() })
    }

    /// Registers a specifc type of service using a factory method.
    ///
    /// - Parameters:
    ///   - type: The type of service being registered. Optional, may be inferred by the factory return type.
    ///   - name: A  name to specify the variant of the service being registered.
    ///   - factory: A closure that constructs and returns an instance of the service.
    /// - Returns: An instance of the service `Registration` that allows further modifications.
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                        factory: @escaping Container.FactoryResolver<Service>) -> Registration<Service> {
        let name = name ?? NILNAME
        let identifier = ObjectIdentifier(Service.self).hashValue
        let registration = Registration(container: self, identifier: identifier, name: name, factory: factory)

        if var namedRegistrations = registrations[identifier] {
            namedRegistrations[name] = registration
            registrations[identifier] = namedRegistrations
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
    public static func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service {
        Container.registerServices?()
        return container.resolve(type, name: name)
    }

    /// Resolves a type of service from the current container.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved. Optional, may be inferred by the assignment type.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An instance of the specified service.
    public final func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service {
        if let registration = find(type, name: name ?? NILNAME),
            let service = resolver(registration.scope).resolve(registration: registration) {
                return service
        }

        fatalError("Container :: '\(type)(\(name ?? ""))' registration not found.")
    }

    /// Resolves an optional type of service from the main container.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved. Optional, may be inferred by the assignment type.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An optional instance of the specified service.
    public static func resolveOptional<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service? {
        Container.registerServices?()
        return container.resolveOptional(type, name: name)
    }

    /// Resolves an optional type of service from the current container.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved. Optional, may be inferred by the assignment type.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An optional instance of the specified service.
    public final func resolveOptional<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service? {
        if let registration = find(type, name: name ?? NILNAME),
            let service = resolver(registration.scope).resolve(registration: registration) {
                return service
        }

        return nil
    }

    /// Searches the current container for a matching registration of the given service type and name.
    ///
    /// - Parameters:
    ///     - type: The type of service being resolved.
    ///     - name: A  name to specify the variant of the service being resolved.
    /// - Returns: An optional instance of the specified service.
    private func find<Service>(_ type: Service.Type, name: String) -> Registration<Service>? {
        guard let namedRegistrations = registrations[ObjectIdentifier(Service.self).hashValue] else {
            return nil
        }

        return namedRegistrations[name] as? Registration<Service>
    }

    /// Returns a resolver for the given scope.
    ///
    /// - Parameters:
    ///     - scope: The scope of the resolver being returned.
    /// - Returns: an optional instance of the specified service.
    private func resolver(_ scope: Scope) -> Resolver {
        if let resolver = resolvers[scope] {
            return resolver
        }

        let resolver = scope.resolver
        resolvers[scope] = resolver

        return resolver
    }

    private var resolvers = [Scope: Resolver]()
    private var registrations = [Int: [String: Any]]()
    private let NILNAME = "*"

}
