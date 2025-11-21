import UIKit
import RxSwift
import RxCocoa
import SnapKit

class XHSProfileViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // 顶部个人信息区域
    private let avatarImageView = UIImageView()
    private let menuButton = UIButton(type: .system) // 左上角菜单按钮
    private let shareButton = UIButton(type: .system) // 右上角分享按钮
    private let usernameLabel = UILabel()
    private let userIdLabel = UILabel()
    private let locationLabel = UILabel()
    private let bioLabel = UILabel()
    private let ageLocationStackView = UIStackView()
    
    // 统计信息区域
    private let statsStackView = UIStackView()
    private let followingLabel = UILabel()
    private let followersLabel = UILabel()
    private let likesLabel = UILabel()
    private let editProfileButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    
    // 功能卡片区域
    private let featureStackView = UIStackView()
    private let inspirationCard = FeatureCardView(title: "创作灵感", subtitle: "学创作找灵感")
    private let historyCard = FeatureCardView(title: "浏览记录", subtitle: "看过的笔记")
    private let groupCard = FeatureCardView(title: "群聊", subtitle: "查看详情")
    
    // 笔记标签和内容区域
    private let notesSegmentedControl = UISegmentedControl()
    private let searchButton = UIButton(type: .system)
    private let notesCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    // MARK: - Properties
    private let viewModel = XHSProfileViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "我"
        view.backgroundColor = UIColor(red: 0.227, green: 0.188, blue: 0.259, alpha: 1.0) // 深灰紫背景
        
        setupScrollView()
        setupTopBar()
        setupProfileHeader()
        setupStatsView()
        setupFeatureCards()
        setupNotesSection()
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
        
        // 绑定笔记数据到collectionView
        output.notes
            .bind(to: notesCollectionView.rx.items(
                cellIdentifier: "NoteCell",
                cellType: NoteCollectionViewCell.self)
            ) { index, note, cell in
                cell.configure(with: note)
            }
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
    
    private func setupTopBar() {
        // 菜单按钮
        menuButton.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        menuButton.tintColor = .white
        contentView.addSubview(menuButton)
        
        // 分享按钮（包含分屏和箭头图标）
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        contentView.addSubview(shareButton)
    }
    
    private func setupProfileHeader() {
        // 头像
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        avatarImageView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0)
        
        // 用户名
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        usernameLabel.textColor = .white
        usernameLabel.textAlignment = .left
        
        // 用户ID
        userIdLabel.font = UIFont.systemFont(ofSize: 14)
        userIdLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        userIdLabel.textAlignment = .left
        
        // IP属地标签
        locationLabel.font = UIFont.systemFont(ofSize: 12)
        locationLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        locationLabel.textAlignment = .left
        locationLabel.text = "IP属地：浙江"
        
        // 简介
        bioLabel.font = UIFont.systemFont(ofSize: 14)
        bioLabel.textColor = .white
        bioLabel.textAlignment = .left
        bioLabel.numberOfLines = 2
        bioLabel.text = "专注营养与体重管理，更健康，更快乐。"
        
        // 年龄地点堆栈视图
        ageLocationStackView.axis = .horizontal
        ageLocationStackView.spacing = 8
        ageLocationStackView.alignment = .center
        ageLocationStackView.distribution = .fillProportionally
        
        let ageLabel = UILabel()
        ageLabel.text = "34岁"
        ageLabel.font = UIFont.systemFont(ofSize: 12)
        ageLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        ageLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.2)
        ageLabel.layer.cornerRadius = 10
        ageLabel.textAlignment = .center
        ageLabel.layer.masksToBounds = true
        ageLabel.widthAnchor.constraint(equalTo: ageLabel.heightAnchor).isActive = true
        
        let locationTagLabel = UILabel()
        locationTagLabel.text = "浙江杭州"
        locationTagLabel.font = UIFont.systemFont(ofSize: 12)
        locationTagLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        locationTagLabel.backgroundColor = UIColor(white: 0.3, alpha: 0.2)
        locationTagLabel.layer.cornerRadius = 10
        locationTagLabel.textAlignment = .center
        locationTagLabel.layer.masksToBounds = true
        locationTagLabel.widthAnchor.constraint(equalTo: locationTagLabel.heightAnchor, multiplier: 2.5).isActive = true
        
        ageLocationStackView.addArrangedSubview(ageLabel)
        ageLocationStackView.addArrangedSubview(locationTagLabel)
        
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(userIdLabel)
        contentView.addSubview(locationLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(ageLocationStackView)
    }
    
    private func setupStatsView() {
        // 统计信息
        followingLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        followingLabel.textAlignment = .center
        followingLabel.text = "27"
        
        let followingTextLabel = UILabel()
        followingTextLabel.font = UIFont.systemFont(ofSize: 12)
        followingTextLabel.textColor = .white
        followingTextLabel.textAlignment = .center
        followingTextLabel.text = "关注"
        
        followersLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        followersLabel.textAlignment = .center
        followersLabel.text = "35"
        
        let followersTextLabel = UILabel()
        followersTextLabel.font = UIFont.systemFont(ofSize: 12)
        followersTextLabel.textColor = .white
        followersTextLabel.textAlignment = .center
        followersTextLabel.text = "粉丝"
        
        likesLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        likesLabel.textAlignment = .center
        likesLabel.text = "316"
        
        let likesTextLabel = UILabel()
        likesTextLabel.font = UIFont.systemFont(ofSize: 12)
        likesTextLabel.textColor = .white
        likesTextLabel.textAlignment = .center
        likesTextLabel.text = "获赞与收藏"
        
        // 创建统计堆栈视图
        let followingStack = UIStackView(arrangedSubviews: [followingLabel, followingTextLabel])
        followingStack.axis = .vertical
        followingStack.spacing = 4
        followingStack.alignment = .center
        
        let followersStack = UIStackView(arrangedSubviews: [followersLabel, followersTextLabel])
        followersStack.axis = .vertical
        followersStack.spacing = 4
        followersStack.alignment = .center
        
        let likesStack = UIStackView(arrangedSubviews: [likesLabel, likesTextLabel])
        likesStack.axis = .vertical
        likesStack.spacing = 4
        likesStack.alignment = .center
        
        statsStackView.addArrangedSubviews(followingStack, followersStack, likesStack)
        statsStackView.axis = .horizontal
        statsStackView.distribution = .fillEqually
        statsStackView.spacing = 20
        
        // 编辑资料按钮
        editProfileButton.setTitle("编辑资料", for: .normal)
        editProfileButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        editProfileButton.backgroundColor = UIColor(white: 0.3, alpha: 0.2)
        editProfileButton.setTitleColor(.white, for: .normal)
        editProfileButton.layer.cornerRadius = 16
        editProfileButton.layer.borderWidth = 0.5
        editProfileButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.3).cgColor
        
        // 设置按钮
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.tintColor = .white
        
        contentView.addSubview(statsStackView)
        contentView.addSubview(editProfileButton)
        contentView.addSubview(settingsButton)
    }
    
    private func setupFeatureCards() {
        featureStackView.axis = .horizontal
        featureStackView.distribution = .fillEqually
        featureStackView.spacing = 10
        
        featureStackView.addArrangedSubview(inspirationCard)
        featureStackView.addArrangedSubview(historyCard)
        featureStackView.addArrangedSubview(groupCard)
        
        contentView.addSubview(featureStackView)
    }
    
    private func setupNotesSection() {
        // 笔记分段控件
        notesSegmentedControl.insertSegment(withTitle: "笔记", at: 0, animated: false)
        notesSegmentedControl.insertSegment(withTitle: "收藏", at: 1, animated: false)
        notesSegmentedControl.insertSegment(withTitle: "赞过", at: 2, animated: false)
        notesSegmentedControl.selectedSegmentIndex = 0
        notesSegmentedControl.backgroundColor = UIColor(red: 0.294, green: 0.251, blue: 0.322, alpha: 1.0) // 浅灰卡片背景
        notesSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        notesSegmentedControl.setTitleTextAttributes([.foregroundColor: UIColor(white: 0.8, alpha: 1.0)], for: .normal)
        
        // 添加红色下划线给选中的"笔记"
        // 这里我们需要自定义实现
        notesSegmentedControl.removeFromSuperview() // 先移除
        contentView.addSubview(notesSegmentedControl)
        
        // 搜索按钮
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.tintColor = .white
        
        // 笔记集合视图
        notesCollectionView.backgroundColor = UIColor(red: 0.227, green: 0.188, blue: 0.259, alpha: 1.0)
        notesCollectionView.register(NoteCollectionViewCell.self, forCellWithReuseIdentifier: "NoteCell")
        
        if let layout = notesCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        }
        
        contentView.addSubview(searchButton)
        contentView.addSubview(notesCollectionView)
    }
    
    private func setupConstraints() {
        // 顶部栏约束
        menuButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(24)
        }
        
        shareButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        // 头像和信息约束
        avatarImageView.snp.makeConstraints { make in
            make.top.equalTo(menuButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(80)
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(5)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalTo(settingsButton.snp.leading).offset(-8)
        }
        
        userIdLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(4)
            make.leading.equalTo(usernameLabel)
            make.trailing.equalTo(settingsButton.snp.leading).offset(-8)
        }
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalTo(userIdLabel.snp.bottom).offset(4)
            make.leading.equalTo(usernameLabel)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).offset(10)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(8)
            make.leading.equalTo(usernameLabel)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        ageLocationStackView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(8)
            make.leading.equalTo(usernameLabel)
        }
        
        // 统计信息约束
        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(ageLocationStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(70)
        }
        
        editProfileButton.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(15)
            make.leading.equalToSuperview().offset(16)
            make.height.equalTo(32)
            make.width.equalTo(80)
        }
        
        // 功能卡片约束
        featureStackView.snp.makeConstraints { make in
            make.top.equalTo(editProfileButton.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(80)
        }
        
        // 笔记部分约束
        notesSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(featureStackView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(searchButton.snp.leading).offset(-8)
            make.height.equalTo(40)
        }
        
        searchButton.snp.makeConstraints { make in
            make.centerY.equalTo(notesSegmentedControl)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        notesCollectionView.snp.makeConstraints { make in
            make.top.equalTo(notesSegmentedControl.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(300) // 临时高度，实际会根据内容调整
        }
    }
    
    private func updateUI(with userData: XHSUserProfile) {
        usernameLabel.text = userData.username
        bioLabel.text = userData.bio
        followingLabel.text = "\(userData.following)"
        followersLabel.text = "\(userData.followers)"
        likesLabel.text = "\(userData.likes)"
        
        // 更新头像（暂时用颜色代替）
        avatarImageView.backgroundColor = UIColor(
            red: CGFloat(userData.avatarColor.0),
            green: CGFloat(userData.avatarColor.1),
            blue: CGFloat(userData.avatarColor.2),
            alpha: 1.0
        )
    }
}

// MARK: - Feature Card View
class FeatureCardView: UIView {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let backgroundView = UIView()
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.subtitleLabel.text = subtitle
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        // 背景视图
        backgroundView.backgroundColor = UIColor(red: 0.294, green: 0.251, blue: 0.322, alpha: 1.0) // 卡片背景色
        backgroundView.layer.cornerRadius = 12
        addSubview(backgroundView)
        sendSubviewToBack(backgroundView)
        
        // 标题
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        addSubview(titleLabel)
        
        // 副标题
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        subtitleLabel.textAlignment = .left
        addSubview(subtitleLabel)
        
        // 使用SnapKit设置约束
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}

// MARK: - Note Collection View Cell
class NoteCollectionViewCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let playButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
    private let statsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.294, green: 0.251, blue: 0.322, alpha: 1.0) // 卡片背景色
        layer.cornerRadius = 8
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        contentView.addSubview(imageView)
        
        playButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        playButton.tintColor = .white
        playButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        playButton.layer.cornerRadius = 15
        playButton.isHidden = true // 默认隐藏，仅在视频内容时显示
        contentView.addSubview(playButton)
        
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        contentView.addSubview(titleLabel)
        
        statsLabel.font = UIFont.systemFont(ofSize: 10)
        statsLabel.textColor = UIColor(white: 0.8, alpha: 1.0)
        contentView.addSubview(statsLabel)
        
        // 使用SnapKit设置约束
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(contentView.snp.width) // 正方形
        }
        
        playButton.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.width.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(6)
            make.leading.trailing.equalToSuperview().offset(6)
        }
        
        statsLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalToSuperview().offset(-6)
        }
    }
    
    func configure(with note: XHSNote) {
        titleLabel.text = note.title
        statsLabel.text = note.stats
        imageView.backgroundColor = note.isVideo ? UIColor.blue.withAlphaComponent(0.3) : UIColor.gray.withAlphaComponent(0.3)
        
        // 如果是视频，显示播放按钮
        playButton.isHidden = !note.isVideo
    }
}

// MARK: - Note Model
struct XHSNote {
    let id: String
    let title: String
    let stats: String // 播放量等统计数据
    let isVideo: Bool
    let imageUrl: String
}

// MARK: - View Model
class XHSProfileViewModel: XHSBaseViewModel {
    
    override func transform(input: Input) -> Output {
        let userData = Observable.just(createMockUserProfile())
        let notes = Observable.just(createMockNotes())
        
        return Output(
            userData: userData,
            notes: notes
        )
    }
    
    private func createMockUserProfile() -> XHSUserProfile {
        return XHSUserProfile(
            username: "梦影",
            bio: "专注营养与体重管理，更健康，更快乐。",
            followers: 35,
            following: 27,
            likes: 316,
            avatarColor: (0.5, 0.7, 1.0)
        )
    }
    
    private func createMockNotes() -> [XHSNote] {
        return [
            XHSNote(id: "draft", title: "本地草稿", stats: "有1篇笔记待发布 >", isVideo: false, imageUrl: ""),
            XHSNote(id: "1", title: "绍兴租房·华秦铂湾", stats: "播放量85", isVideo: true, imageUrl: ""),
            XHSNote(id: "2", title: "房间不同角度", stats: "", isVideo: true, imageUrl: ""),
            XHSNote(id: "3", title: "阳光满屋治愈小家", stats: "播放量120", isVideo: true, imageUrl: "")
        ]
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let userData: Observable<XHSUserProfile>
        let notes: Observable<[XHSNote]>
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
        let notes: Observable<[XHSNote]>
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

