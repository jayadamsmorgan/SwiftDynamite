import Foundation

#if os(Linux)
import Glibc
#elseif os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
import Darwin
#elseif os(Windows)
import WinSDK
#endif

@MainActor
public struct DynamiteLoader {

    static var _loadedLibraries: [URL: DynamiteLibrary] = [:]

    public static var loadedLibraries: [DynamiteLibrary] {
        Array(DynamiteLoader._loadedLibraries.values)
    }

    public static func load(at url: URL) -> Result<DynamiteLibrary, LoadError> {
        guard _loadedLibraries[url] == nil else {
            return .failure(.alreadyLoaded)
        }

        let fileManager = FileManager.default

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return .failure(.notFound(path: url.path))
        }
        guard !isDirectory.boolValue else {
            return .failure(.notFound(path: url.path))
        }

        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Linux)

        // Clear any old errors
        dlerror()

        guard let handle = dlopen(url.path, RTLD_NOW) else {
            if let message = String(validatingCString: dlerror()) {
                return .failure(.openError(message: message))
            } else {
                return .failure(
                    .unknownOpenError
                )
            }
        }
        #elseif os(Windows)

        guard let handle = LoadLibraryA(url) else {
            return .failure(.windowsOpenError)
        }
        #endif

        let library = DynamiteLibrary(url, handle: handle)
        _loadedLibraries[url] = library

        return .success(library)

    }

    public static func load(at path: String) -> Result<DynamiteLibrary, LoadError> {
        let url = URL(fileURLWithPath: path)
        return load(at: url)
    }

    private static func unloadUnchecked(_ library: DynamiteLibrary) -> UnloadError? {
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(Linux)
        dlerror()  // Clear any old errors
        dlclose(library.handle)
        if let errorMessage = String(validatingCString: dlerror()) {
            return .closeError(message: errorMessage)
        }
        #elseif os(Windows)
        FreeLibrary(handle)
        #endif
        _loadedLibraries[library.url] = nil
        return nil
    }

    @discardableResult
    public static func unload(_ library: DynamiteLibrary) -> UnloadError? {
        guard loadedLibraries.contains(library) else {
            return .notLoaded(path: library.url.path)
        }
        return unloadUnchecked(library)
    }

    @discardableResult
    public static func unload(at url: URL) -> UnloadError? {
        guard let library = _loadedLibraries[url] else {
            return .notLoaded(path: url.path)
        }
        return unloadUnchecked(library)
    }

    @discardableResult
    public static func unload(at path: String) -> UnloadError? {
        let url = URL(fileURLWithPath: path)
        return unload(at: url)
    }

}