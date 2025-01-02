import Foundation

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Windows)
import WinSDK
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Linux)
internal typealias HandlePointer = UnsafeMutableRawPointer
#elseif os(Windows)
internal typealias HandlePointer = UnsafeMutablePointer<HINSTANCE__>
#endif

public struct DynamiteLibrary: Equatable {

    public let url: URL

    internal let handle: HandlePointer

    public static func == (lhs: DynamiteLibrary, rhs: DynamiteLibrary) -> Bool {
        return lhs.url == rhs.url && lhs.handle == rhs.handle
    }

    internal init(_ url: URL, handle: HandlePointer) {
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
                return .failure(.dlsymError(signature: signature, message: message))
            } else {
                return .failure(.unknownDlsymError(signature: signature))
            }
        }
        #elseif os(Windows)

        guard let functionPtr = GetProcAddress(handle, signature) else {
            return .failure(.winError(signature: signature))
        }
        #endif

        return .success(unsafeBitCast(functionPtr, to: fnType))

    }

}
