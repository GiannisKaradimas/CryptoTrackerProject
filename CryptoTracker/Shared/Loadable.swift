import Foundation

enum Loadable<T> {
    case idle
    case loading
    case loaded(T)
    case failed(AppError)
}

extension Loadable {
    var value: T? {
        if case let .loaded(v) = self { return v }
        return nil
    }
}
