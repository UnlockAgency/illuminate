#  UI

## Theme

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

## Dimensions

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
