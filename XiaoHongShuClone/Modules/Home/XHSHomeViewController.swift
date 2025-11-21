import UIKit
import RxSwift
import RxCocoa
import SnapKit

class XHSHomeViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let headerView = XHSHomeHeaderView()
    
    // MARK: - Properties
    private let viewModel = XHSHomeViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "首页"
        
        setupTableView()
        setupHeaderView()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let input = XHSHomeViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        // 绑定数据到tableView
        output.feedItems
            .bind(to: tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell") ?? XHSFeedTableViewCell(style: .default, reuseIdentifier: "FeedCell")
                cell.configure(with: item)
                return cell
            }
            .disposed(by: disposeBag)
        
        // 处理cell点击事件
        tableView.rx.modelSelected(XHSFeedItem.self)
            .subscribe(onNext: { [weak self] item in
                // 处理点击事件
                print("点击了: \(item.title)")
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.register(XHSFeedTableViewCell.self, forCellReuseIdentifier: "FeedCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.92, alpha: 1.0) // 小红书背景色
    }
    
    private func setupHeaderView() {
        // 设置header视图
        tableView.tableHeaderView = headerView
    }
}

// MARK: - View Model
class XHSHomeViewModel: XHSBaseViewModel {
    
    override func transform(input: Input) -> Output {
        let feedItems = Observable.just(generateMockData())
        
        return Output(feedItems: feedItems)
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let feedItems: Observable<[XHSFeedItem]>
    }
    
    private func generateMockData() -> [XHSFeedItem] {
        return [
            XHSFeedItem(id: "1", title: "夏日穿搭分享", content: "今天分享几套适合夏天的搭配", imageUrl: "", username: "时尚达人", likes: 128, comments: 24),
            XHSFeedItem(id: "2", title: "美食探店", content: "发现了一家超棒的咖啡厅", imageUrl: "", username: "吃货小分队", likes: 256, comments: 42),
            XHSFeedItem(id: "3", title: "旅行攻略", content: "周末去杭州的行程安排", imageUrl: "", username: "旅行家", likes: 512, comments: 87),
            XHSFeedItem(id: "4", title: "美妆心得", content: "新入手的口红试色", imageUrl: "", username: "美妆博主", likes: 342, comments: 32),
            XHSFeedItem(id: "5", title: "家居布置", content: "小户型收纳技巧", imageUrl: "", username: "生活家", likes: 198, comments: 18)
        ]
    }
}

// MARK: - Models
struct XHSFeedItem {
    let id: String
    let title: String
    let content: String
    let imageUrl: String
    let username: String
    let likes: Int
    let comments: Int
}

// MARK: - Views
class XHSHomeHeaderView: UIView {
    private let searchView = UISearchBar()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(red: 0.98, green: 0.95, blue: 0.92, alpha: 1.0)
        self.frame = CGRect(x: 0, y: 0, width: 0, height: 100)
        
        searchView.placeholder = "搜索感兴趣的内容"
        searchView.barStyle = .default
        searchView.searchBarStyle = .minimal
        
        addSubview(searchView)
        
        searchView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(36)
        }
    }
}

class XHSFeedTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let avatarImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let imageViewContainer = UIImageView()
    private let likesLabel = UILabel()
    private let commentsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 设置UI元素
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.clipsToBounds = true
        
        usernameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        usernameLabel.textColor = .label
        
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textColor = .secondaryLabel
        contentLabel.numberOfLines = 0
        
        imageViewContainer.contentMode = .scaleAspectFill
        imageViewContainer.clipsToBounds = true
        imageViewContainer.layer.cornerRadius = 8
        
        likesLabel.font = UIFont.systemFont(ofSize: 12)
        likesLabel.textColor = .secondaryLabel
        likesLabel.text = " 💖 0"
        
        commentsLabel.font = UIFont.systemFont(ofSize: 12)
        commentsLabel.textColor = .secondaryLabel
        commentsLabel.text = " 💬 0"
        
        // 添加到视图层级
        contentView.addSubview(avatarImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(imageViewContainer)
        contentView.addSubview(likesLabel)
        contentView.addSubview(commentsLabel)
        
        // 使用SnapKit设置约束
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(40)
            make.bottom.greaterThanOrEqualToSuperview().offset(-12) // 确保头像不会被压缩
        }
        
        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView).priority(.high) // 设置较低优先级以避免冲突
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.lessThanOrEqualToSuperview().inset(16) // 使用lessThanOrEqualTo避免约束冲突
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.leading.equalTo(avatarImageView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalTo(avatarImageView)
            make.trailing.equalToSuperview().inset(16)
        }
        
        imageViewContainer.snp.makeConstraints { make in
            make.top.equalTo(contentLabel.snp.bottom).offset(8)
            make.leading.equalTo(avatarImageView)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(200)  // 简化的固定高度
        }
        
        likesLabel.snp.makeConstraints { make in
            make.top.equalTo(imageViewContainer.snp.bottom).offset(12)
            make.leading.equalTo(avatarImageView)
            make.bottom.equalToSuperview().inset(12)
        }
        
        commentsLabel.snp.makeConstraints { make in
            make.leading.equalTo(likesLabel.snp.trailing).offset(16)
            make.centerY.equalTo(likesLabel)
            make.trailing.lessThanOrEqualToSuperview().inset(16) // 防止超出边界
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    func configure(with item: XHSFeedItem) {
        usernameLabel.text = item.username
        titleLabel.text = item.title
        contentLabel.text = item.content
        likesLabel.text = " 💖 \(item.likes)"
        commentsLabel.text = " 💬 \(item.comments)"
    }
}