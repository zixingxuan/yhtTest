import Foundation
import RxSwift

class XHSBaseViewModel {
    let disposeBag = DisposeBag()
    
    // MARK: - Inputs
    func transform(input: Input) -> Output {
        fatalError("Subclasses must implement the transform method")
    }
    
    struct Input {}
    struct Output {}
}