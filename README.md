# FChucker

A powerful network debugging tool for iOS applications built with SwiftUI. FChucker intercepts and displays network requests in a beautiful, interactive interface, making it easy to debug API calls during development.

## Features

- 🔍 **Network Request Interception**: Automatically captures all HTTP/HTTPS requests
- 📱 **SwiftUI Interface**: Modern, native iOS interface built with SwiftUI
- 🎨 **Interactive JSON Viewer**: Expandable/collapsible JSON viewer with syntax highlighting
- 🔔 **Toast Notifications**: Real-time toast notifications for network requests
- 📊 **Request Details**: View complete request/response data including headers, body, and status codes
- ⚡ **Lightweight**: Minimal performance impact on your app

https://github.com/user-attachments/assets/fd7f3635-763b-4d31-a6dc-2f8c8912f9a5


## Requirements

- iOS 15.0+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add FChucker to your project using Swift Package Manager:

1. In Xcode, go to `File` → `Add Package Dependencies`
2. Enter the repository URL: `https://github.com/yourusername/FChucker`
3. Select the version you want to use
4. Add the package to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/FChucker", from: "1.0.0")
]
```

## Quick Start

### 1. Start Network Monitoring

In your app's entry point (usually `App.swift` or `SceneDelegate.swift`), start FChucker:

```swift
import FChucker

@main
struct MyApp: App {
    init() {
        // Start network monitoring
        #if DEBUG
        FChucker.start()
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .networkToasts() // Add toast notifications
        }
    }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

FChucker is available under the MIT license. See the LICENSE file for more info.

## Credits

Created by Muhammed Faruk Söğüt

---

**Note**: This tool is intended for development and debugging purposes only. Do not include it in production builds.
