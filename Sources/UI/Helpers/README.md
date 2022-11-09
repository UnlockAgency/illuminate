#  UI

## General 

## SwiftUI

### Compatibility

Some of the best features of SwiftUI are only available from iOS 14.0 or later. To be compatible with earlier iOS versions, we are using a `compatibleCall` function, to be able to add those new features in a neat way to our view.

```swift
struct ShoppingCartView: View {
    var body: some View {
        List {
            ProductView()
        }
        // Only available on iOS 16 and later:
        .scrollDisabled(true)
        
        // Replaced with:
        .compatibleCall(.scrollDisabled(true))
    }
}
```

`scrollDisable` is available by default, but you can create your custom functions like this:

```swift
extension SwiftUICompatibilityFunction {
    public static func scrollDisabled(_ disabled: Bool) -> SwiftUICompatibilityFunction {
        return SwiftUICompatibilityFunction { view in
            if #available(iOS 16.0, *) {
                return view.scrollDisabled(disabled)
            }
            
            return view.introspectScrollView {
                $0.isScrollEnabled = !disabled
            }
        }
    }
}

```

### ObservableModule

Remember this?

```swift
var body: some View {
    if loading {
        LoadingView()
    } else if let error {
        ErrorView()
    } else if let data {
        List {
            ProductView()
        }
    }
}
```

Using a `ModuledView` and `ObservableModule`, this becomes easier:

```swift
@Published var module: ObservableModule<[Product]>(initialValue: [])

// With your custom logic:
module.perform { 
    let products = try apiClient.products.list().async()
    
    return products.filter { 
        $0.isVisible
    }
}

// Or by assigning a `Publisher` directly:
module.perform(apiClient.products.list())
```

And using it in your view:

```swift
var body: some View {
    ModuledView(module) { result in
        List { 
            ForEach(products) { product in
                ProductView()
            }
        }
    }
}
```

The `ModuledView` automatically shows a loading or error state when necessary. You can override these default templates by: **nog niet**
