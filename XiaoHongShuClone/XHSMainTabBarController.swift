import UIKit
import SnapKit

class XHSMainTabBarController: UIViewController, XHSCustomTabBarDelegate {
    
    // MARK: - Properties
    private var viewControllers: [UIViewController] = []
    private var selectedViewController: UIViewController?
    private var selectedIndex: Int = 0
    
    // MARK: - UI Elements
    private let customTabBar = XHSCustomTabBar()
    private let containerView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupViewControllers()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加容器视图
        view.addSubview(containerView)
        
        // 添加自定义TabBar
        view.addSubview(customTabBar)
        customTabBar.delegate = self
        
        // 使用SnapKit设置约束
        containerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(customTabBar.snp.top)
        }
        
        customTabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(83) // TabBar的标准高度
        }
    }
    
    private func setupViewControllers() {
        let homeNav = createNavigationController(
            rootViewController: XHSHomeViewController(),
            title: "首页",
            imageName: "house.fill",
            selectedImageName: "house.fill"
        )
        
        let marketNav = createNavigationController(
            rootViewController: XHSMarketViewController(),
            title: "市集",
            imageName: "bag.fill",
            selectedImageName: "bag.fill"
        )
        
        let messageNav = createNavigationController(
            rootViewController: XHSMessageViewController(),
            title: "消息",
            imageName: "heart.fill",
            selectedImageName: "heart.fill"
        )
        
        let profileNav = createNavigationController(
            rootViewController: XHSProfileViewController(),
            title: "我",
            imageName: "person.fill",
            selectedImageName: "person.fill"
        )
        
        let publishVC = XHSPublishViewController() // 发布视图控制器单独处理
        
        // 设置视图控制器数组
        viewControllers = [homeNav, marketNav, publishVC, messageNav, profileNav]
        
        // 设置初始视图控制器
        setSelectedViewController(at: 0)
        
        // 设置TabBar项
        let tabBarItems = viewControllers.map { vc in
            var item = UITabBarItem()
            if let navController = vc as? UINavigationController {
                item = navController.tabBarItem
            } else {
                // 发布视图控制器没有导航控制器
                item = UITabBarItem(title: "", image: UIImage(systemName: "plus.circle.fill"), selectedImage: UIImage(systemName: "plus.circle.fill"))
            }
            return item
        }
        
        customTabBar.setItems(tabBarItems, selectedIndex: 0)
    }
    
    private func setSelectedViewController(at index: Int) {
        // 移除当前视图控制器
        selectedViewController?.removeFromParent()
        selectedViewController?.view.removeFromSuperview()
        
        // 获取新的视图控制器
        let newViewController = viewControllers[index]
        
        // 添加新的视图控制器
        addChild(newViewController)
        containerView.addSubview(newViewController.view)
        
        newViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        newViewController.didMove(toParent: self)
        selectedViewController = newViewController
        selectedIndex = index
        
        // 更新TabBar选中状态
        customTabBar.setSelectedIndex(index, animated: true)
    }
    
    // MARK: - XHSCustomTabBarDelegate
    func tabBar(_ tabBar: XHSCustomTabBar, didSelect index: Int) {
        if index == 2 { // 发布按钮索引
            // 弹出发布视图控制器
            let publishVC = XHSPublishViewController()
            let navController = UINavigationController(rootViewController: publishVC)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        } else {
            // 切换到其他视图控制器
            setSelectedViewController(at: index)
        }
    }
    
    private func createNavigationController(rootViewController: UIViewController, 
                                         title: String, 
                                         imageName: String, 
                                         selectedImageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        
        rootViewController.title = title
        rootViewController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: imageName), selectedImage: UIImage(systemName: selectedImageName))
        
        return navController
    }
}