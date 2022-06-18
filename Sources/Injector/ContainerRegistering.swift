/// A protocol for performing initial registration of container services.
public protocol ContainerRegistering {
    /// Registers all services when resolving a dependency.
    static func registerContainerServices()
}
