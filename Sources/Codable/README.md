# Codable


## DefaultCodable propertyWrapper

**Product.swift**

```swift
class Product: Identifiable, Codable {    
    var id: Int = 0
    
    @DefaultEmpty
    var name: String = ""
    
    @DefaultNil
    var subTitle: String?
}    
``` 

### Available property wrappers by default

```swift
/// If decoding returns `nil` or throws an error: Fallback to an empty array
public typealias DefaultEmptyDictionary<T, U> 

/// If decoding returns `nil` or throws an error: Fallback to `nil`
public typealias DefaultNil<T>

/// If decoding returns `nil` or throws an error: Fallback to `false`
public typealias DefaultFalse

/// If decoding returns `nil` or throws an error: Fallback to and empty string (`""`) or array (`[]`)
public typealias DefaultEmpty<T>

/// If decoding returns `nil` or throws an error: Fallback to `true`
public typealias DefaultTrue

/// If decoding returns `nil` or throws an error: Fallback to `0`
public typealias DefaultZero<T>

/// If decoding returns `nil` or throws an error: Fallback to the first enum element
public enum FirstEnumCase<A>

/// If decoding returns `nil` or throws an error: Fallback to the last enum element
public enum LastEnumCase<A>
```

## Convertor propertyWrapper

**StringToDoubleConvertor.swift**

```swift
struct StringToDoubleConvertor: ConvertorValueProvider {
    static var defaultValue: Double {
        return 0
    }
    
    static func decode(from value: String) -> Double {
        return Double(value) ?? 0
    }
    
    static func encode(from value: Double) -> String {
        return "\(value)"
    }
}

typealias StringToDouble = CodableConvertor<StringToDoubleConvertor>
```

**ShoppingCartItem.swift**

```swift
struct ShoppingCartItem: Codable {
    @StringToDouble
    var price: Double = 0
    
    @DefaultZero
    var quantity: Int = 0
    
    var product: Product?
}