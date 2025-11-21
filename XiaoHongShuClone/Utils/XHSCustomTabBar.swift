import UIKit
import SnapKit

protocol XHSCustomTabBarDelegate: AnyObject {
    func tabBar(_ tabBar: XHSCustomTabBar, didSelect index: Int)
}

// 自定义TabBar按钮，实现图片在上、文字在下的布局
class CustomTabBarButton: UIButton {
    
    override var isSelected: Bool {
        didSet {
            setTitleColor(isSelected ? UIColor.red : UIColor.gray, for: .selected)
            tintColor = isSelected ? UIColor.red : UIColor.gray
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // 设置按钮样式为图片在上，文字在下
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleLabel?.font = UIFont.systemFont(ofSize: 10)
        titleLabel?.textAlignment = .center
        contentEdgeInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
    }
    
    func setupWithItem(_ item: UITabBarItem) {
        setImage(item.image, for: .normal)
        setImage(item.selectedImage, for: .selected)
        setTitle(item.title, for: .normal)
        setTitleColor(UIColor.gray, for: .normal)
        setTitleColor(UIColor.red, for: .selected)
        tintColor = UIColor.gray
        adjustsImageWhenHighlighted = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let titleLabel = titleLabel, let imageView = imageView else { return }
        
        // 设置图片在上方，文字在下方
        let imageHeight = imageView.frame.height
        let titleHeight = titleLabel.frame.height
        
        let totalHeight = imageHeight + titleHeight + 4 // 4是图片和文字之间的间距
        let yOffset = (bounds.height - totalHeight) / 2
        
        imageView.frame = CGRect(
            x: (bounds.width - imageView.frame.width) / 2,
            y: yOffset,
            width: imageView.frame.width,
            height: imageView.frame.height
        )
        
        titleLabel.frame = CGRect(
            x: (bounds.width - titleLabel.frame.width) / 2,
            y: imageView.frame.maxY + 4,
            width: titleLabel.frame.width,
            height: titleLabel.frame.height
        )
    }
}

class XHSCustomTabBar: UIView {
    
    // MARK: - Properties
    weak var delegate: XHSCustomTabBarDelegate?
    
    private var tabBarButtons: [CustomTabBarButton] = []
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
        tabBarButtons.removeAll()
        
        tabBarItems = items
        
        // 创建TabBar按钮，但不包括发布按钮的位置
        var validItems: [(item: UITabBarItem, index: Int)] = []
        for (index, item) in items.enumerated() {
            if index != publishButtonIndex {
                validItems.append((item: item, index: index))
            }
        }
        
        // 为非发布项创建按钮
        for (item, originalIndex) in validItems {
            createTabBarButton(for: item, at: originalIndex)
        }
        
        // 创建发布按钮
        createPublishButton()
    }
    
    private func createTabBarButton(for item: UITabBarItem, at index: Int) {
        let button = CustomTabBarButton()
        button.tag = index
        button.setupWithItem(item)
        
        button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
        
        addSubview(button)
        
        // 使用SnapKit布局
        button.snp.makeConstraints { make in
            make.top.equalTo(separatorLine.snp.bottom).offset(8)
            make.bottom.equalToSuperview().inset(8)
            make.width.equalToSuperview().dividedBy(CGFloat(tabBarItems.count - 1)) // 减1因为发布按钮不占tab位置
            make.centerX.equalToSuperview().multipliedBy(CGFloat(calculateButtonCenterX(for: index))).priority(.high)
        }
    }
    
    private func calculateButtonCenterX(for index: Int) -> Double {
        // 计算避开发布按钮位置的按钮中心X坐标
        let totalValidItems = tabBarItems.count - 1 // 减去发布按钮
        let validIndex = index >= publishButtonIndex ? index - 1 : index
        return Double(validIndex + 1) / Double(totalValidItems + 1)
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
    
    @objc private func tabBarButtonTapped(_ sender: CustomTabBarButton) {
        delegate?.tabBar(self, didSelect: sender.tag)
    }
    
    @objc private func publishButtonTapped(_ sender: UIButton) {
        // 发布按钮始终触发索引2
        delegate?.tabBar(self, didSelect: publishButtonIndex)
    }
    
    func setSelectedIndex(_ index: Int, animated: Bool = true) {
        // 更新按钮选择状态
        for button in tabBarButtons {
            button.isSelected = button.tag == index
        }
    }
}