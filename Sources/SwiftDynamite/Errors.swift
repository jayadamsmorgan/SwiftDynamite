import Foundation

public enum UnloadError: Error {

    case notLoaded(path: String)

    public var localizedDescription: String {
        switch self {
        case .notLoaded(let path):
            return "Unable to unload library at path \(path). Library was not loaded before."
        }
    }
}

public enum LoadError: Error {

    case notFound(path: String)

    case alreadyLoaded(path: String)

    case openError(path: String, message: String)
    case unknownOpenError(path: String)

    case windowsOpenError(path: String)

    public var localizedDescription: String {
        let commonStr = "Unable to load library at path "
        switch self {
        case .notFound(let path):
            return commonStr + "\(path). Library was not found."
        case .alreadyLoaded(let path):
            return commonStr + "\(path). Library was already loaded."
        case .openError(let path, let message):
            return commonStr + "\(path). `dlopen` error: \(message)."
        case .unknownOpenError(let path), .windowsOpenError(let path):
            return commonStr + "\(path). Unknown error."
        }
    }

}

public enum ExecutionError: Error {
    case dlsymError(signature: String, message: String)
    case unknownDlsymError(signature: String)
    case winError(signature: String)

    public var localizedDescription: String {
        let commonStr = "Unable to execute function "
        switch self {
        case .dlsymError(let signature, let message):
            return commonStr + "\(signature). `dlsym` error: \(message)."
        case .unknownDlsymError(let signature), .winError(let signature):
            return commonStr + "\(signature). Unknown error."
        }
    }
}
