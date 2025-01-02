import Foundation

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Windows)
import WinSDK
#endif

public typealias DynamiteFunction = UnsafeMutableRawPointer

public struct DynamiteLibrary: Equatable {

    public let url: URL

    internal let handle: UnsafeMutableRawPointer

    public static func == (lhs: DynamiteLibrary, rhs: DynamiteLibrary) -> Bool {
        return lhs.url == rhs.url && lhs.handle == rhs.handle
    }

    internal init(_ url: URL, handle: UnsafeMutableRawPointer) {
        self.url = url
        self.handle = handle
    }

    @discardableResult
    public func getFunction<Fn>(_ signature: String, as fnType: Fn.Type) -> Result<Fn, ExecutionError> {

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Linux)
        // Clear any old errors
        dlerror()

        guard let functionPtr = dlsym(handle, signature) else {
            if let message = String(validatingCString: dlerror()) {
                return .failure(.dlsymError(message: message))
            } else {
                return .failure(.unknownDlsymError)
            }
        }
        #elseif os(Windows)

        guard let functionPtr = GetProcAddress(handle, symbolName) else {
            return .failure(.winError)
        }
        #endif

        return .success(unsafeBitCast(functionPtr, to: fnType))

    }

}

public enum ExecutionError: Error {
    case dlsymError(message: String)
    case unknownDlsymError
    case winError
}
