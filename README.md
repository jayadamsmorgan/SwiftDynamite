<div align="center">

# SwiftDynamite
**Crossplatform Swift library to load dynamic libraries at runtime**

</div>

## Installation

```swift
let package = Package(
    // name, platforms, products, etc.
    dependencies: [
        // other dependencies
        .package(url: "https://github.com/jayadamsmorgan/SwiftDynamite", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(name: "yourApp", dependencies: [
            // other dependencies
            .product(name: "SwiftDynamite", package: "SwiftDynamite"),
        ]),
        // other targets
    ]
)
```

## Usage

**Note: DynamiteLoader should be called from @MainActor**

```swift
// Load library
let library = try DynamiteLoader.load(at: "some_library.dylib").get()

// Create type of the function you want to call from the loaded library
typealias FnType = @convention(c) (Int32, Int32) -> UnsafeMutableRawPointer

// Get the function from library
let function =
    try library
    .getFunction("some_function", as: FnType.self)
    .get()

// Call the function and print result
print(function(1, 2))

// Get the variable from library
let someStringVariable =
    try library
    .getVariable("some_variable", as: UnsafePointer<CChar>.self)
    .get()

// Print the variable
print(String(validatingCString: someStringVariable) ?? "nil")

// Unload library
DynamiteLoader.unload(library)
```

