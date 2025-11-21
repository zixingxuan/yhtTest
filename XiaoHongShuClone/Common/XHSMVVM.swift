import Foundation
import RxSwift

// MARK: - Base Protocols
protocol XHSViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

// MARK: - Base View Model Implementation
class XHSMVVMViewModel: XHSViewModelType {
    let disposeBag = DisposeBag()
    
    // Default implementation - should be overridden
    func transform(input: Input) -> Output {
        fatalError("Subclasses must implement the transform method")
    }
    
    struct Input {}
    struct Output {}
    
    init() {
        setupBindings()
    }
    
    // Override this method to set up initial bindings
    func setupBindings() {}
}

// MARK: - Reactive Extensions for View Models
extension XHSMVVMViewModel {
    func bind<InputType, OutputType>(viewModel: XHSMVVMViewModel, input: InputType, output: OutputType) {
        // This is a generic bind function that can be used to connect view models
        // Implementation will depend on specific use cases
    }
}

// MARK: - Common View Model Components
class LoadingViewModel {
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    func startLoading() {
        isLoading.accept(true)
    }
    
    func stopLoading() {
        isLoading.accept(false)
    }
}

class ErrorViewModel {
    let error = PublishRelay<Error>()
    
    func handleError(_ error: Error) {
        self.error.accept(error)
    }
}

// MARK: - Data Providers
protocol XHSDataProvider {
    associatedtype DataType
    func fetchData() -> Observable<[DataType]>
}

class XHSBaseDataProvider<T>: XHSDataProvider {
    typealias DataType = T
    
    func fetchData() -> Observable<[T]> {
        return Observable.empty()
    }
}

// MARK: - View Model Coordinator
class XHSViewModelCoordinator {
    private var viewModels: [XHSMVVMViewModel] = []
    
    func add(viewModel: XHSMVVMViewModel) {
        viewModels.append(viewModel)
    }
    
    func remove(viewModel: XHSMVVMViewModel) {
        viewModels.removeAll { $0 === viewModel }
    }
    
    func removeAll() {
        viewModels.removeAll()
    }
}

// MARK: - State Management
enum XHSViewState {
    case idle
    case loading
    case loaded(data: Any)
    case error(Error)
}

class XHSStateViewModel: XHSMVVMViewModel {
    let state = BehaviorRelay<XHSViewState>(value: .idle)
    
    override func transform(input: XHSStateViewModel.Input) -> XHSStateViewModel.Output {
        // Default implementation
        return Output(state: state.asObservable())
    }
    
    struct Input: XHSViewModelType.Input {}
    struct Output: XHSViewModelType.Output {
        let state: Observable<XHSViewState>
    }
    
    func updateState(_ newState: XHSViewState) {
        state.accept(newState)
    }
}

// MARK: - List View Model Base
class XHSListViewModel<T>: XHSMVVMViewModel {
    let items = BehaviorRelay<[T]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let error = PublishRelay<Error>()
    
    func addItem(_ item: T) {
        var currentItems = items.value
        currentItems.append(item)
        items.accept(currentItems)
    }
    
    func removeItem(at index: Int) {
        var currentItems = items.value
        if index < currentItems.count {
            currentItems.remove(at: index)
            items.accept(currentItems)
        }
    }
    
    func updateItem(at index: Int, with item: T) {
        var currentItems = items.value
        if index < currentItems.count {
            currentItems[index] = item
            items.accept(currentItems)
        }
    }
    
    // Override this method to implement data fetching
    func fetchData() -> Observable<[T]> {
        return Observable.empty()
    }
    
    override func transform(input: XHSListViewModel<T>.Input) -> XHSListViewModel<T>.Output {
        let refreshTrigger = input.refreshTrigger?
            .flatMapLatest { [weak self] _ -> Observable<[T]> in
                guard let self = self else { return Observable.empty() }
                self.isLoading.accept(true)
                return self.fetchData()
                    .do(onNext: { _ in
                        self.isLoading.accept(false)
                    }, onError: { error in
                        self.isLoading.accept(false)
                        self.error.accept(error)
                    })
            } ?? Observable.empty()
        
        // Combine initial data and refresh data
        let dataObservable = Observable.of(
            Observable.just(items.value),
            refreshTrigger
        ).merge()
        
        return Output(
            items: dataObservable,
            isLoading: isLoading.asObservable(),
            error: error.asObservable()
        )
    }
    
    struct Input: XHSViewModelType.Input {
        let refreshTrigger: Observable<Void>?
        
        init(refreshTrigger: Observable<Void>? = nil) {
            self.refreshTrigger = refreshTrigger
        }
    }
    
    struct Output: XHSViewModelType.Output {
        let items: Observable<[T]>
        let isLoading: Observable<Bool>
        let error: Observable<Error>
    }
}