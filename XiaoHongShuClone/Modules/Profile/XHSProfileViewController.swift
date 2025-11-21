import UIKit
import RxSwift
import RxCocoa
import SnapKit

class XHSProfileViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 个人信息区域
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let bioLabel = UILabel()
    private let statsStackView = UIStackView()
    private let followersLabel = UILabel()
    private let followingLabel = UILabel()
    private let likesLabel = UILabel()
    
    // 功能按钮区域
    private let settingsButton = UIButton(type: .system)
    private let notificationButton = UIButton(type: .system)
    
    // 选项列表
    private let tableView = UITableView()
    
    // MARK: - Properties
    private let viewModel = XHSProfileViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "我"
        
        setupScrollView()
        setupProfileHeader()
        setupStatsView()
        setupActionButtons()
        setupOptionsTableView()
        setupConstraints()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let input = XHSProfileViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        // 绑定用户数据
        output.userData
            .subscribe(onNext: { [weak self] userData in
                self?.updateUI(with: userData)
            })
            .disposed(by: disposeBag)
        
        // 绑定选项数据到tableView
        output.options
            .bind(to: tableView.rx.items) { tableView, row, option in
                let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell") ?? XHSSettingsTableViewCell(style: .value1, reuseIdentifier: "OptionCell")
                cell.configure(with: option)
                return cell
            }
            .disposed(by: disposeBag)
        
        // 处理cell点击事件
        tableView.rx.modelSelected(XHSProfileOption.self)
            .subscribe(onNext: { [weak self] option in
                self?.handleOptionTap(option)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
    }
    
    private func setupProfileHeader() {
        // 头像
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        
        // 用户名
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        usernameLabel.textColor = .label
        usernameLabel.textAlignment = .center
        
        // 简介
        bioLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.textColor = .secondaryLabel
        bioLabel.textAlignment = .center
        bioLabel.numberOfLines = 2
        bioLabel.text = "点击编辑个人简介"
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(bioLabel)
    }
    
    private func setupStatsView() {
        // 统计信息
        followersLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        followersLabel.textAlignment = .center
        followersLabel.text = "0"
        
        let followersTextLabel = UILabel()
        followersTextLabel.font = UIFont.systemFont(ofSize: 12)
        followersTextLabel.textColor = .secondaryLabel
        followersTextLabel.textAlignment = .center
        followersTextLabel.text = "关注者"
        
        followingLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        followingLabel.textAlignment = .center
        followingLabel.text = "0"
        
        let followingTextLabel = UILabel()
        followingTextLabel.font = UIFont.systemFont(ofSize: 12)
        followingTextLabel.textColor = .secondaryLabel
        followingTextLabel.textAlignment = .center
        followingTextLabel.text = "关注"
        
        likesLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        likesLabel.textAlignment = .center
        likesLabel.text = "0"
        
        let likesTextLabel = UILabel()
        likesTextLabel.font = UIFont.systemFont(ofSize: 12)
        likesTextLabel.textColor = .secondaryLabel
        likesTextLabel.textAlignment = .center
        likesTextLabel.text = "获赞"
        
        // 创建统计堆栈视图
        let followersStack = UIStackView(arrangedSubviews: [followersLabel, followersTextLabel])
        followersStack.axis = .vertical
        followersStack.spacing = 4
        followersStack.alignment = .center
        
        let followingStack = UIStackView(arrangedSubviews: [followingLabel, followingTextLabel])
        followingStack.axis = .vertical
        followingStack.spacing = 4
        followingStack.alignment = .center
        
        let likesStack = UIStackView(arrangedSubviews: [likesLabel, likesTextLabel])
        likesStack.axis = .vertical
        likesStack.spacing = 4
        likesStack.alignment = .center
        
        statsStackView.addArrangedSubviews(followersStack, followingStack, likesStack)
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 20
        
        contentView.addSubview(statsStackView)
    }
    
    private func setupActionButtons() {
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.tintColor = .label
        settingsButton.backgroundColor = .systemGray5
        settingsButton.layer.cornerRadius = 20
        
        notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
        notificationButton.tintColor = .label
        notificationButton.backgroundColor = .systemGray5
        notificationButton.layer.cornerRadius = 20
        
        contentView.addSubview(settingsButton)
        contentView.addSubview(notificationButton)
    }
    
    private func setupOptionsTableView() {
        contentView.addSubview(tableView)
        
        tableView.register(XHSSettingsTableViewCell.self, forCellReuseIdentifier: "OptionCell")
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.backgroundColor = .systemBackground
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(16)
            make.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(40)
            make.height.equalTo(60)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(40)
        }
        
        notificationButton.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(20)
            make.trailing.equalToSuperview().inset(20)
            make.width.height.equalTo(40)
            make.width.equalTo(settingsButton)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(settingsButton.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
            make.height.equalTo(44 * 8) // 假设有8个选项
        }
    }
    
    private func updateUI(with userData: XHSUserProfile) {
        usernameLabel.text = userData.username
        bioLabel.text = userData.bio
        followersLabel.text = "\(userData.followers)"
        followingLabel.text = "\(userData.following)"
        likesLabel.text = "\(userData.likes)"
        
        // 更新头像（暂时用颜色代替）
        avatarImageView.backgroundColor = UIColor(
            red: CGFloat(userData.avatarColor.0),
            green: CGFloat(userData.avatarColor.1),
            blue: CGFloat(userData.avatarColor.2),
            alpha: 1.0
        )
    }
    
    private func handleOptionTap(_ option: XHSProfileOption) {
        print("点击了选项: \(option.title)")
        
        // 根据选项执行相应操作
        switch option.type {
        case .myPosts:
            // 跳转到我的帖子页面
            let myPostsVC = XHSMyPostsViewController()
            navigationController?.pushViewController(myPostsVC, animated: true)
        case .myFavorites:
            // 跳转到我的收藏页面
            let myFavoritesVC = XHSMyFavoritesViewController()
            navigationController?.pushViewController(myFavoritesVC, animated: true)
        case .myOrders:
            // 跳转到我的订单页面
            let myOrdersVC = XHSMyOrdersViewController()
            navigationController?.pushViewController(myOrdersVC, animated: true)
        case .settings:
            // 跳转到设置页面
            let settingsVC = XHSSettingsViewController()
            navigationController?.pushViewController(settingsVC, animated: true)
        case .help:
            // 跳转到帮助页面
            let helpVC = XHSHelpViewController()
            navigationController?.pushViewController(helpVC, animated: true)
        default:
            // 其他选项暂时显示提示
            let alert = UIAlertController(title: option.title, message: option.subtitle, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - View Model
class XHSProfileViewModel: XHSBaseViewModel {
    
    override func transform(input: Input) -> Output {
        let userData = Observable.just(createMockUserProfile())
        let options = Observable.just(createMockOptions())
        
        return Output(
            userData: userData,
            options: options
        )
    }
    
    private func createMockUserProfile() -> XHSUserProfile {
        return XHSUserProfile(
            username: "小红书用户",
            bio: "热爱生活，分享美好",
            followers: 128,
            following: 56,
            likes: 512,
            avatarColor: (0.9, 0.5, 0.5)
        )
    }
    
    private func createMockOptions() -> [XHSProfileOption] {
        return [
            XHSProfileOption(title: "我的帖子", subtitle: "", type: .myPosts, icon: "doc.text"),
            XHSProfileOption(title: "我的收藏", subtitle: "", type: .myFavorites, icon: "heart"),
            XHSProfileOption(title: "我的订单", subtitle: "", type: .myOrders, icon: "bag"),
            XHSProfileOption(title: "优惠券", subtitle: "", type: .coupons, icon: "ticket"),
            XHSProfileOption(title: "我的钱包", subtitle: "", type: .wallet, icon: "creditcard"),
            XHSProfileOption(title: "设置", subtitle: "", type: .settings, icon: "gear"),
            XHSProfileOption(title: "帮助与客服", subtitle: "", type: .help, icon: "questionmark.circle"),
            XHSProfileOption(title: "关于小红书", subtitle: "v9.9.0", type: .about, icon: "info")
        ]
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let userData: Observable<XHSUserProfile>
        let options: Observable<[XHSProfileOption]>
    }
}

// MARK: - Models
struct XHSUserProfile {
    let username: String
    let bio: String
    let followers: Int
    let following: Int
    let likes: Int
    let avatarColor: (Double, Double, Double) // RGB值 (0.0 - 1.0)
}

struct XHSProfileOption {
    let title: String
    let subtitle: String
    let type: OptionType
    let icon: String
}

enum OptionType {
    case myPosts      // 我的帖子
    case myFavorites  // 我的收藏
    case myOrders     // 我的订单
    case coupons      // 优惠券
    case wallet       // 钱包
    case settings     // 设置
    case help         // 帮助与客服
    case about        // 关于
}

// MARK: - Additional Profile Views
class XHSSettingsTableViewCell: UITableViewCell {
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let disclosureImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .default
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .systemBlue
        iconImageView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
        iconImageView.layer.cornerRadius = 12
        iconImageView.clipsToBounds = true
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        
        disclosureImageView.image = UIImage(systemName: "chevron.right")
        disclosureImageView.tintColor = .systemGray2
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(disclosureImageView)
        
        iconImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(16)
            make.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(disclosureImageView.snp.leading).inset(-8)
        }
        
        disclosureImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(16)
        }
    }
    
    func configure(with option: XHSProfileOption) {
        titleLabel.text = option.title
        subtitleLabel.text = option.subtitle.isEmpty ? nil : option.subtitle
        iconImageView.image = UIImage(systemName: option.icon)
    }
}

// MARK: - Sub-View Controllers
class XHSMyPostsViewController: XHSBaseViewController {
    override func setupUI() {
        super.setupUI()
        title = "我的帖子"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "我的帖子内容"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class XHSMyFavoritesViewController: XHSBaseViewController {
    override func setupUI() {
        super.setupUI()
        title = "我的收藏"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "我的收藏内容"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class XHSMyOrdersViewController: XHSBaseViewController {
    override func setupUI() {
        super.setupUI()
        title = "我的订单"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "我的订单内容"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class XHSSettingsViewController: XHSBaseViewController {
    override func setupUI() {
        super.setupUI()
        title = "设置"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "设置内容"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

class XHSHelpViewController: XHSBaseViewController {
    override func setupUI() {
        super.setupUI()
        title = "帮助与客服"
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = "帮助与客服内容"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}