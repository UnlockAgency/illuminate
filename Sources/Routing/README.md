# Routing

RoutingManager and RoutingService takes care of handling url's

## Implementation

**ProductDetailRoute.swift**

```swift
import Foundation
import IlluminateRouting

struct ProductDetailRoute: Route {
    let value: String
    
    static func handle(url: URL) -> ProductDetailRoute? {
        // Possible values:
        // - https://www.plein.nl/product/<id> | /product/</id>
        guard let path = getPath(from: url),
            path.starts(with: "/product") else {
            return nil
        }
		 
        return ProductDetailRoute(value: url.lastPathComponent)
    }
}
```
**AppCoordinator+di.swift**

```swift
let routingManager = RoutingManager()
routingManager.registerRoutes([ProductDetailRoute.self])

container.register(RoutingService.self) { _ in routingManager }

routingService.valuePublisher(for: ProductDetailRoute.self)
	.sink { value in
	    // Handle the product detail
	}.store(in: &cancellables)
```

**AppDelegate.swift**

```swift
extension AppDelegate: UIApplicationDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let url = userActivity.webpageURL else {
            return false
        }
        logger.trace("Application open url \(url)", metadata: [ "service": "routing" ])
        return routingService.handle(url: url)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        logger.trace("Application open url \(url)", metadata: [ "service": "routing" ])
        return routingService.handle(url: url)
    }
```
