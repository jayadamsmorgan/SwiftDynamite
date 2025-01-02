import Foundation

public enum UnloadError: Error {

    case notLoaded(path: String)

    case closeError(message: String)
}

public enum LoadError: Error {

    case notFound(path: String)

    case alreadyLoaded

    case openError(message: String)
    case unknownOpenError

    case windowsOpenError

}
