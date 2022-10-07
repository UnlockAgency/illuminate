#  UI

## General 

### Theme

This package also provides some basic components for you to work with. These are styled using the default theme. You can switch themes by defining your own version:

```swift
Theme.setDefault(
    Theme(
        colors: Theme.Colors(
            primary: .purple,
            secondary: .green
        ),
        text: Theme.Text(
            primary: .black
        )
    )
)
```

Colors are then also accessible via:
 
```swift
SwiftUI.Color.Branding.primary
SwiftUI.Color.Branding.secondary

SwiftUI.Color.Text.primary
```

### Dimensions

We're defining constant dimensions in the package, to be consistent throughout the entire app. The default dimensions are:

```swift
public enum DefaultSize: String, Sizeable {
    case extraSmall
    case small
    case regular
    case large
    case extraLarge
    
    public var padding: CGFloat {
        switch self {
        case .extraSmall: return 4
        case .small: return 8
        case .regular: return 16
        case .large: return 22
        case .extraLarge: return 26
        }
    }
    
    public var spacing: CGFloat {
        switch self {
        case .extraSmall: return 4
        case .small: return 8
        case .regular: return 12
        case .large: return 16
        case .extraLarge: return 20
        }
    }
}
```

You can override these, but have to make sure you inherit your enum from `Sizeable`. You're then able to use the new dimensions in your app by defining a typealias:

```swift
typealias D = Dimensions<DefaultSize>

VStack { 
    Text("Large padding")
}.padding(D.Content.padding(.large))
```

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
        .listRowSeparator(.hidden)
        
        // Replaced with:
        .compatibleCall(.listRowSeparator(.hidden))
    }
}
```

All available functions:

```swift
.compatibleCall(.listRowSeparator(_ visibility: Visibility))
.compatibleCall(.scrollContentBackground(_ visibility: Visibility))
.compatibleCall(.scrollDisabled(_ disabled: Bool))
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
