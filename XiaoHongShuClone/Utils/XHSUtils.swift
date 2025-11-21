import Foundation
import RxSwift
import RxCocoa

// MARK: - Coordinator Pattern
protocol Coordinator {
    func start()
    func coordinate(to coordinator: Coordinator)
}

class MainCoordinator: Coordinator {
    private var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let tabBarController = XHSMainTabBarController()
        navigationController.pushViewController(tabBarController, animated: false)
    }
    
    func coordinate(to coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.start()
    }
}

// MARK: - Common Utilities
class XHSNetworkingService {
    static let shared = XHSNetworkingService()
    
    private init() {}
    
    func request<T: Codable>(_ type: T.Type, from endpoint: String) -> Observable<T> {
        return Observable.create { observer in
            // 模拟网络请求
            DispatchQueue.global().async {
                // 模拟网络延迟
                Thread.sleep(forTimeInterval: 1.0)
                
                // 模拟成功或失败
                if arc4random_uniform(100) > 10 { // 90% 成功率
                    // 这里应该是实际的网络请求逻辑
                    // 为了演示，返回一个默认实例
                    if let defaultInstance = T.self as? any XHSDummyInitializable.Type {
                        observer.onNext(defaultInstance.createDummyInstance() as! T)
                    } else {
                        // 对于无法创建默认实例的类型，我们返回错误
                        observer.onError(NSError(domain: "XHSNetworkingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建实例"]))
                    }
                    observer.onCompleted()
                } else {
                    observer.onError(NSError(domain: "XHSNetworkingService", code: -1, userInfo: [NSLocalizedDescriptionKey: "网络请求失败"]))
                }
            }
            
            return Disposables.create()
        }
    }
}

// 辅助协议，用于创建类型的虚拟实例
protocol XHSDummyInitializable {
    static func createDummyInstance() -> Any
}

// 扩展常用类型以支持虚拟实例创建
extension String: XHSDummyInitializable {
    static func createDummyInstance() -> Any {
        return "dummy"
    }
}

extension Int: XHSDummyInitializable {
    static func createDummyInstance() -> Any {
        return 0
    }
}

extension Double: XHSDummyInitializable {
    static func createDummyInstance() -> Any {
        return 0.0
    }
}

extension Bool: XHSDummyInitializable {
    static func createDummyInstance() -> Any {
        return false
    }
}

// MARK: - Common Extensions
extension ObservableType {
    func unwrap<T>() -> Observable<T> where E == T? {
        return self.compactMap { $0 }
    }
}

extension UIViewController {
    func showAlert(title: String, message: String, actions: [UIAlertAction] = [UIAlertAction(title: "确定", style: .default)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}

// MARK: - Data Models Base
protocol XHSModel {
    var id: String { get }
}

// MARK: - Global Constants
struct XHSConstants {
    struct Colors {
        static let primary = UIColor.red
        static let background = UIColor(red: 0.98, green: 0.95, blue: 0.92, alpha: 1.0)
        static let separator = UIColor.systemGray4
    }
    
    struct Fonts {
        static func titleFont(ofSize size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }
        
        static func bodyFont(ofSize size: CGFloat) -> UIFont {
            return UIFont.systemFont(ofSize: size, weight: .regular)
        }
    }
    
    struct Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
}

// MARK: - Global Functions
func XHSLocalized(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}