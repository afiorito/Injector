/// Resolution scope of a registered service.
public enum Scope {
    case singleton
    case shared
    case unique
    case graph

    var resolver: Resolver {
        switch self {
        case .graph: return GraphResolver()
        case .shared: return SharedResolver()
        case .singleton: return SingletonResolver()
        case .unique: return UniqueResolver()
        }
    }
}
