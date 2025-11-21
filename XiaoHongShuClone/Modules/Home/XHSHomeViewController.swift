import UIKit
import RxSwift
import RxCocoa
import SnapKit

class XHSHomeViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let headerView = XHSHomeHeaderView()
    private let refreshControl = UIRefreshControl()
    
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
            viewDidLoad: Observable.just(()),
            refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            loadMoreTrigger: tableView.rx.willDisplayCell.asObservable()
                .filter { [weak self] _ in
                    // 检查是否接近底部
                    guard let self = self,
                          self.tableView.numberOfRows(inSection: 0) > 0 else { return false }
                    
                    let lastRowIndex = self.tableView.numberOfRows(inSection: 0) - 1
                    let lastVisibleIndex = self.tableView.indexPathsForVisibleRows?.last?.row ?? 0
                    return lastVisibleIndex >= lastRowIndex - 1 // 在倒数第二个时开始加载
                }
                .map { _ in () } // 将结果转换为Void
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
        
        // 停止刷新控件
        output.refreshComplete
            .subscribe(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
            })
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
        
        // 添加下拉刷新
        tableView.refreshControl = refreshControl
    }
    
    private func setupHeaderView() {
        // 设置header视图
        tableView.tableHeaderView = headerView
    }
}

// MARK: - View Model
class XHSHomeViewModel: XHSBaseViewModel {
    
    private let networkService = XHSNetworkService.shared
    private let feedItemsSubject = BehaviorSubject<[XHSFeedItem]>(value: [])
    private var currentPage = 1
    private let itemsPerPage = 10
    private var isLoading = false
    private var hasMore = true
    
    override func transform(input: Input) -> Output {
        // 初始加载数据
        input.viewDidLoad
            .subscribe(onNext: { [weak self] _ in
                self?.loadData(page: 1, isRefresh: false)
            })
            .disposed(by: disposeBag)
        
        // 下拉刷新
        input.refreshTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.loadData(page: 1, isRefresh: true)
            })
            .disposed(by: disposeBag)
        
        // 上拉加载更多
        input.loadMoreTrigger
            .filter { [weak self] in
                guard let self = self else { return false }
                return !self.isLoading && self.hasMore
            }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.loadData(page: self.currentPage + 1, isRefresh: false)
            })
            .disposed(by: disposeBag)
        
        return Output(
            feedItems: feedItemsSubject.asObservable(),
            refreshComplete: input.refreshTrigger.map { _ in () }
        )
    }
    
    private func loadData(page: Int, isRefresh: Bool) {
        guard !isLoading else { return }
        isLoading = true
        
        networkService.fetchHomeFeed(page: page, limit: itemsPerPage)
            .subscribe(
                onNext: { [weak self] response in
                    guard let self = self else { return }
                    
                    var currentItems = isRefresh ? [] : try? self.feedItemsSubject.value() ?? []
                    if isRefresh {
                        currentItems = []
                    }
                    
                    let newItems = response.items.map { item in
                        XHSFeedItem(
                            id: item.id,
                            title: item.title,
                            content: item.content,
                            imageUrl: item.imageUrl,
                            username: item.username,
                            likes: item.likes,
                            comments: item.comments
                        )
                    }
                    
                    currentItems.append(contentsOf: newItems)
                    
                    self.feedItemsSubject.onNext(currentItems)
                    self.currentPage = page
                    self.hasMore = response.hasMore
                    self.isLoading = false
                },
                onError: { [weak self] error in
                    print("Error loading data: \(error)")
                    self?.isLoading = false
                }
            )
            .disposed(by: disposeBag)
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let refreshTrigger: Observable<Void>
        let loadMoreTrigger: Observable<Void>
    }
    
    struct Output {
        let feedItems: Observable<[XHSFeedItem]>
        let refreshComplete: Observable<Void>
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
        avatarImageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0) // 占位颜色
        
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
        imageViewContainer.backgroundColor = UIColor(white: 0.9, alpha: 1.0) // 占位颜色
        
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
        
        // 模拟使用Kingfisher加载图片 (实际需要导入Kingfisher库)
        // 这里使用模拟的异步加载
        loadImageAsync(from: item.imageUrl, into: imageViewContainer)
        loadImageAsync(from: "https://example.com/avatar_\(item.username).jpg", into: avatarImageView)
    }
    
    private func loadImageAsync(from urlString: String, into imageView: UIImageView) {
        // 模拟图片加载
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            imageView.image = nil
            return
        }
        
        // 设置占位图
        imageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        // 模拟异步加载
        DispatchQueue.global().async {
            // 模拟网络请求延迟
            usleep(100000) // 0.1秒
            
            DispatchQueue.main.async {
                // 设置模拟图片
                imageView.backgroundColor = UIColor(hue: CGFloat.random(in: 0...1), saturation: 0.7, brightness: 0.9, alpha: 1.0)
                imageView.image = nil
            }
        }
    }
}