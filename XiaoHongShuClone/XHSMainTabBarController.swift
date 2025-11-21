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
        
        let publishNav = createNavigationController(
            rootViewController: XHSPublishViewController(),
            title: "",
            imageName: "plus.circle.fill",
            selectedImageName: "plus.circle.fill"
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
        
        // 设置中间按钮为发布按钮
        viewControllers = [homeNav, marketNav, UIViewController(), publishNav, messageNav, profileNav]
        
        // 配置发布按钮
        let publishItem = tabBar.items?[3]
        publishItem?.isEnabled = false  // 临时禁用，通过其他方式处理中间按钮
        
        // 实际的发布按钮
        setupPublishButton()
    }
    
    private func setupPublishButton() {
        let publishButton = UIButton(type: .custom)
        publishButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        publishButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        publishButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill"), for: .highlighted)
        publishButton.tintColor = .red
        
        // 添加按钮到TabBar
        tabBar.addSubview(publishButton)
        
        // 设置按钮位置
        publishButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            publishButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            publishButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: -10),
            publishButton.widthAnchor.constraint(equalToConstant: 60),
            publishButton.heightAnchor.constraint(equalToConstant: 60)
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