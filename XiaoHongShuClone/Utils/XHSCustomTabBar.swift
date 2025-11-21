import UIKit
import SnapKit

protocol XHSCustomTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: XHSCustomTabBar, didSelect index: Int)
}

class XHSCustomTabBar: UIView {
    
    // MARK: - Properties
    weak var delegate: XHSCustomTabBarDelegate?
    
    private let tabBarButtons: [UIButton] = []
    private var tabBarItems: [UITabBarItem] = []
    private var publishButton: UIButton!
    private let publishButtonIndex = 2 // 发布按钮在中间位置
    
    // MARK: - UI Elements
    private let backgroundView = UIView()
    private let separatorLine = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        // 背景视图
        backgroundView.backgroundColor = UIColor.systemBackground
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: -1)
        backgroundView.layer.shadowOpacity = 0.1
        backgroundView.layer.shadowRadius = 3
        addSubview(backgroundView)
        
        // 分隔线
        separatorLine.backgroundColor = UIColor.systemGray5
        addSubview(separatorLine)
        
        // 设置约束
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        separatorLine.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    func setItems(_ items: [UITabBarItem], selectedIndex: Int = 0) {
        // 移除旧的按钮
        tabBarButtons.forEach { $0.removeFromSuperview() }
        
        tabBarItems = items
        
        // 创建TabBar按钮，但不包括发布按钮的位置
        var validItems: [(item: UITabBarItem, index: Int)] = []
        for (index, item) in items.enumerated() {
            if index != publishButtonIndex {
                validItems.append((item: item, index: validItems.count))
            }
        }
        
        // 为非发布项创建按钮
        for (item, displayIndex) in validItems {
            createTabBarButton(for: item, at: displayIndex)
        }
        
        // 创建发布按钮
        createPublishButton()
    }
    
    private func createTabBarButton(for item: UITabBarItem, at index: Int) {
        let button = UIButton(type: .custom)
        button.tag = index
        button.setImage(item.image, for: .normal)
        button.setImage(item.selectedImage, for: .selected)
        button.setTitle(item.title, for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.setTitleColor(UIColor.red, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.tintColor = UIColor.gray
        button.adjustsImageWhenHighlighted = false
        
        button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
        
        addSubview(button)
        
        // 使用SnapKit布局
        button.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom)
            make.height.equalToSuperview().multipliedBy(0.8) // 按钮高度为整个TabBar的80%
            make.width.equalToSuperview().dividedBy(CGFloat(tabBarItems.count)) // 平均分配宽度
            make.leading.equalToSuperview().offset(
                (CGFloat(index) * (1.0 / CGFloat(tabBarItems.count - 1))) * (superview?.frame.width ?? 0)
            )
        }
        
        // 重新调整约束以适应所有按钮均匀分布
        // 需要稍后更新约束以确保平均分布
    }
    
    private func createPublishButton() {
        publishButton = UIButton(type: .custom)
        publishButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)), for: .normal)
        publishButton.setBackgroundImage(UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)), for: .highlighted)
        publishButton.tintColor = .red
        publishButton.tag = publishButtonIndex
        
        addSubview(publishButton)
        
        // 发布按钮位于中央，稍微突出
        publishButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(separatorLine.snp.bottom).offset(30) // 突出到上方
            make.width.height.equalTo(60)
        }
        
        publishButton.addTarget(self, action: #selector(publishButtonTapped(_:)), for: .touchUpInside)
    }
    
    // 重新实现布局以确保按钮均匀分布
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 计算每个按钮的位置，避开发布按钮的位置
        let totalItems = tabBarItems.count - 1 // 不包括发布按钮
        let buttonWidth = frame.width / CGFloat(totalItems + 1) // +1 为发布按钮预留空间
        
        var buttonIndex = 0
        for (index, _) in tabBarItems.enumerated() {
            if index == publishButtonIndex {
                continue // 跳过发布按钮位置
            }
            
            if buttonIndex < subviews.count - 2 { // -2 为发布按钮和分隔线预留
                let button = subviews[buttonIndex + 2] as! UIButton // +2 为背景视图和分隔线预留
                button.frame = CGRect(
                    x: CGFloat(buttonIndex) * buttonWidth + (buttonIndex >= publishButtonIndex ? buttonWidth : 0),
                    y: separatorLine.frame.maxY,
                    width: buttonWidth,
                    height: frame.height - separatorLine.frame.maxY
                )
            }
            
            buttonIndex += 1
        }
    }
    
    @objc private func tabBarButtonTapped(_ sender: UIButton) {
        delegate?.tabBar(self, didSelect: sender.tag)
    }
    
    @objc private func publishButtonTapped(_ sender: UIButton) {
        delegate?.tabBar(self, didSelect: sender.tag)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        // 更新按钮选择状态
        for (i, view) in subviews.enumerated() {
            if let button = view as? UIButton, 
               button != publishButton { // 不处理发布按钮
                button.isSelected = i - 2 == index // -2 为背景视图和分隔线预留
            }
        }
    }
}