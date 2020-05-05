# ![icon](injector.png) Injector

A dependency injection framework written completely in Swift.

## Installation

Add Injector to your project using Swift Package Manager. In your Xcode project, select `File` > `Swift Packages` > `Add Package Dependency` and enter the repository URL.

## Documentation

- [Basic Usage](#basic-usage)
- [Scope](#scope)
- [Protocols](#protocols)
- [Optionals](#optionals)
- [Named Instances](#named-instances)


### Basic Usage

1. Register Services in `registerContainerServices`.

```swift
class ServiceA {}

extension Container: ContainerRegistering {
  public static func registerContainerServices() {
    register { ServiceA() }
  }
}
```
2. Inject Properties using `@Injected` and `@LazyInjected`.

```swift
class ViewController: UIViewController {
    @Injected serviceA: ServiceA
}
```

### Scope
The registration scope of a Service can be modified to set the lifecycle of a resolved instance.

There are 4 supported scopes:
```swift
enum Scope {
    // The same service is resolved during a resolution cycle. This is the default scope.
    case graph
    // The same service is resolved each time.
    case singleton
    // The same service is resolved as long as there is a reference to it.
    case shared
    // A new service is resolved each time.
    case unique
}
```

The scope can be set by doing:
```swift
register { ServiceA() }
    .scope(.singleton) // scope is now singleton.
```

### Protocols

There are two methods for resolving a service that conforms to a protocol.

1. Using type inference.
```swift
protocol Caching {}

register { ServiceA() as Caching }
```
2. Using the implements modifier.
```swift
register { ServiceA() }
    .implements(Caching.self)
```

### Optionals

Optional types differ slightly from their non-optional counterparts. Therefore, they must be injected a little differently.

```swift
class ViewController: UIViewController {
    @OptionalInjected var service: ServiceA?
}
```

### Named Instances
You can register a variant of a service by providing a name during registration.

```swift
register(name: "special") { ServiceA() }
```

Pass the same name to inject the named service.
```swift
class ViewController: UIViewController {
    @Injected(name: "special") var service: ServiceA
}
```

## License
Injector is available under the MIT license. See the [LICENSE.md](LICENSE) file for more info.