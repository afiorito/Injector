/// A protocol for resolving a service.
protocol Resolver: class {
    func resolve<Service>(registration: Registration<Service>) -> Service?
}

/// A graph resolver resolves the same service once during a given resolution cycle.
class GraphResolver: Resolver {

    func resolve<Service>(registration: Registration<Service>) -> Service? {
        if let nodeService = graph[registration.key] as? Service {
            return nodeService
        }

        depth += 1
        let service = registration.resolve()
        depth -= 1

        if depth == 0 {
            graph.removeAll()
        } else if let service = service, type(of: service) is AnyClass {
            graph[registration.key] = service
        }

        return service
    }

    private var graph = [String: Any](minimumCapacity: 16)
    private var depth = 0
}

/// A shared resolver resolves the same service while strong references to them exist. The service remains deallocated until the next resolve.
class SharedResolver: Resolver {
    private var cachedServices = [String: WeakService](minimumCapacity: 16)

    func resolve<Service>(registration: Registration<Service>) -> Service? {
        if let cachedService = cachedServices[registration.key]?.service as? Service {
            return cachedService
        }

        let service = registration.resolve()

        if let service = service, type(of: service) is AnyClass {
            cachedServices[registration.key] = WeakService(service: service as AnyObject)
        }

        return service
    }

    private struct WeakService {
        weak var service: AnyObject?
    }

}

/// A singleton resolver resolves the same service after every resolution.
class SingletonResolver: Resolver {
    private var cachedServices = [String: Any](minimumCapacity: 16)

    func resolve<Service>(registration: Registration<Service>) -> Service? {
        if let cachedService = cachedServices[registration.key] as? Service {
            return cachedService
        }

        let service = registration.resolve()

        if let service = service {
            cachedServices[registration.key] = service
        }

        return service
    }
}

/// A unique resolver resolves a new service after every resolution.
class UniqueResolver: Resolver {
    func resolve<Service>(registration: Registration<Service>) -> Service? {
        return registration.resolve()
    }

}
