import UIKit

class XHSMainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .red  // 小红书主题色
        tabBar.unselectedItemTintColor = .gray
        
        // 隐藏TabBar分割线
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
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
        
        // 设置视图控制器，不包含中间的发布按钮
        viewControllers = [homeNav, marketNav, messageNav, profileNav]
        
        // 添加发布按钮到tabbar中间位置
        setupPublishButton()
    }
    
    private func setupPublishButton() {
        let publishButton = UIButton(type: .custom)
        publishButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)), for: .normal)
        publishButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)), for: .highlighted)
        publishButton.tintColor = .red
        
        // 设置按钮大小
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加按钮到TabBar
        tabBar.addSubview(publishButton)
        
        // 设置按钮居中位置，确保兼容iOS 13+
        NSLayoutConstraint.activate([
            publishButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            publishButton.widthAnchor.constraint(equalToConstant: 60),
            publishButton.heightAnchor.constraint(equalToConstant: 60),
            // 设置按钮在TabBar内部的垂直位置
            publishButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -10),
            publishButton.bottomAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: -10)
        ])
        
        // 添加点击事件
        publishButton.addTarget(self, action: #selector(publishButtonTapped), for: .touchUpInside)
    }
    
    @objc private func publishButtonTapped() {
        let publishVC = XHSPublishViewController()
        let navController = UINavigationController(rootViewController: publishVC)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func createNavigationController(rootViewController: UIViewController, 
                                         title: String, 
                                         imageName: String, 
                                         selectedImageName: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        
        rootViewController.title = title
        rootViewController.tabBarItem.title = title
        rootViewController.tabBarItem.image = UIImage(systemName: imageName)
        rootViewController.tabBarItem.selectedImage = UIImage(systemName: selectedImageName)
        
        return navController
    }
}