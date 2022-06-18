/// Resolution scope of a registered service.
public enum Scope {
    /// The same service is resolved during a resolution cycle. This is the default scope.
    case graph

    /// The same service is resolved as long as there is a reference to it.
    case shared

    /// The same service is resolved each time.
    case singleton

    /// A new service is resolved each time.
    case unique

    var resolver: any Resolver {
        switch self {
            case .graph: return GraphResolver()
            case .shared: return SharedResolver()
            case .singleton: return SingletonResolver()
            case .unique: return UniqueResolver()
        }
    }
}
