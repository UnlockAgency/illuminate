# Cache

Helping you store objects or images in cache. 

## Usage

```swift
import Foundation
import IlluminateCache

struct ShoppingCart: Codable {
    private enum CodingKeys: String, CodingKey {
        case products
        case discount
        case shippingCharges
        case totalAmount
    }

    let products: [Product]
    let discount: Double?
    let shippingCharges: Double?
    let totalAmount: Double
}

class Cacher {
    
    private let apiClient = APIClient()
    
    init() {
        let manager = CacheManager()
        
        let shoppingCart = try await apiClient.getShoppingCart()
        manager.write(codable: shoppingCart, forKey: "shopping-cart")
        
        let cachedShoppingCart: ShoppingCart? = manager.readCodable(forKey: "shopping-cart")
    }
}
```

## Reference

```swift
public func cached(key: String) -> Bool

public func clean() 
public func clean(byKey key: String)

public func write(data: Data, forKey key: String)     
public func readData(forKey key:String) -> Data?

public func write<T: Encodable>(codable: T, forKey key: String) throws
public func readCodable<T: Decodable>(forKey key: String) throws -> T? 

public func write(image: UIImage, forKey key: String, format: ImageFormat? = nil)
public func readImage(forKey key: String) -> UIImage? 

public func write(string: String, forKey key: String)     
public func readString(forKey key: String) -> String? 
```
