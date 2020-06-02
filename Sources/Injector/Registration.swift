/// A type for storing a service description and its factory closure.
public final class Registration<Service> {
    private let identifier: Int
    public let key: String

    /// The scope to use when resolving a service.
    var scope: Scope = .graph

    public init(container: Container, identifier: Int, name: String?,
                factory: @escaping Container.FactoryResolver<Service>) {
        self.identifier = identifier
        self.container = container
        self.factory = factory

        if let serviceName = name {
            key = "\(identifier)::\(serviceName)"
        } else {
            key = String(identifier)
        }
    }

    /// Resolves a service from the container and applies modifiers.
    ///
    /// - Returns: An instance of the service described by the registration.
    public final func resolve() -> Service? {
        guard let resolver = container, let service = factory(resolver) else {
            return nil
        }

        modifier?(resolver, service)
        return service
    }

    /// The container used to resolve a service.
    private weak var container: Container?

    /// A closure for modifying the registration object.
    private var modifier: Container.FactoryModifier<Service>?

    /// A closure that constructs and returns an instance of the service.
    private let factory: Container.FactoryResolver<Service>
}

// MARK: Modifiers

extension Registration {
    /// Indicates that the registered service implements a specific protocol.
    ///
    /// - Parameters:
    ///     - type: The type of protocol being registered.
    ///     - name: A  name to specify the variant of the protocol being registered.
    /// - Returns: The current instance of the service `Registration` that allows further modifications.
    @discardableResult
    public final func implements<Protocol>(_ type: Protocol.Type, name: String? = nil) -> Self {
        container?.register(type.self, name: name) { resolver in resolver.resolve(Service.self) as? Protocol }
        return self
    }

    /// Allows further modification of the resolved service.
    ///
    /// - Parameters:
    ///     - block: A closure block for modifying a passed service.
    /// - Returns: The current instance of the service `Registration` that allows further modifications.
    @discardableResult
    public final func resolveProperties(_ block: @escaping Container.FactoryModifier<Service>) -> Self {
        modifier = block
        return self
    }

    /// Modifies the scope in which the requested service is resolved.
    ///
    /// - Parameters:
    ///     - scope: The scope in which the service is resolved.
    /// - Returns: The current instance of the service `Registration` that allows further modifications.
    @discardableResult
    public final func scope(_ scope: Scope) -> Self {
        self.scope = scope
        return self
    }
}
