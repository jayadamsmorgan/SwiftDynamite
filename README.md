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
        .package(url: "https://github.com/jayadamsmorgan/SwiftDynamite", from: "1.0.0"),
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
let result = DynamiteLoader.load(at: "your_dynamic_lib.dylib")

switch result {

// Library loaded
case .success(let library):

    // Create type of the function you want to call from the loaded library
    typealias FnType = @convention(c) (Int32, Int32) -> UnsafeMutableRawPointer

    // Get the function from library
    let functionResult = library.getFunction("function_name", as: FnType.self)

    switch functionResult {
    case .success(let function):
        // Function loaded, you can call it
        let callResult = function(1, 2)

    case .failure(let error):
        // Failed to load the function
        print(error.localizedDescription)
    }

// Library failed to load
case .failure(let error):
    print(error.localizedDescription)

}

// Unload library
DynamiteLoader.unload(at: "your_dynamic_lib.dylib")
```

