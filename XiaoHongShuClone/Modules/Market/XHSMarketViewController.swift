import UIKit
import RxSwift
import RxCocoa
import SnapKit

class XHSMarketViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private let refreshControl = UIRefreshControl()
    
    // MARK: - Properties
    private let viewModel = XHSMarketViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "市集"
        
        setupCollectionView()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let input = XHSMarketViewModel.Input(
            viewDidLoad: Observable.just(()),
            refreshTrigger: refreshControl.rx.controlEvent(.valueChanged).asObservable(),
            loadMoreTrigger: collectionView.rx.willDisplayCell.asObservable()
                .filter { [weak self] _ in
                    guard let self = self else { return false }
                    
                    let visibleItems = self.collectionView.indexPathsForVisibleItems
                    let numberOfItems = self.collectionView.numberOfItems(inSection: 0)
                    
                    guard numberOfItems > 0 else { return false }
                    
                    if let lastVisibleIndex = visibleItems.max(by: { $0.item < $1.item }) {
                        return lastVisibleIndex.item >= numberOfItems - 2 // 接近底部时触发加载更多
                    }
                    
                    return false
                }
                .map { _ in () } // 将结果转换为Void
        )
        
        let output = viewModel.transform(input: input)
        
        // 绑定数据到collectionView
        output.products
            .bind(to: collectionView.rx.items) { collectionView, row, item in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "ProductCell",
                    for: indexPath
                ) as! XHSMarketProductCell
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
        collectionView.rx.modelSelected(XHSProductItem.self)
            .subscribe(onNext: { [weak self] item in
                // 处理点击事件
                print("点击了商品: \(item.name)")
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        collectionView.register(
            XHSMarketProductCell.self,
            forCellWithReuseIdentifier: "ProductCell"
        )
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: (view.frame.width - 30) / 2, height: 200)
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        collectionView.backgroundColor = .systemBackground
        
        // 添加下拉刷新
        collectionView.refreshControl = refreshControl
    }
}

// MARK: - View Model
class XHSMarketViewModel: XHSBaseViewModel {
    
    private let networkService = XHSNetworkService.shared
    private let productsSubject = BehaviorSubject<[XHSProductItem]>(value: [])
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
            products: productsSubject.asObservable(),
            refreshComplete: input.refreshTrigger.map { _ in () }
        )
    }
    
    private func loadData(page: Int, isRefresh: Bool) {
        guard !isLoading else { return }
        isLoading = true
        
        networkService.fetchMarketProducts(page: page, limit: itemsPerPage)
            .subscribe(
                onNext: { [weak self] response in
                    guard let self = self else { return }
                    
                    var currentItems = isRefresh ? [] : try? self.productsSubject.value() ?? []
                    if isRefresh {
                        currentItems = []
                    }
                    
                    let newItems = response.items.map { item in
                        XHSProductItem(
                            id: item.id,
                            name: item.name,
                            price: item.price,
                            imageUrl: item.imageUrl,
                            shopName: item.shopName,
                            sales: item.sales
                        )
                    }
                    
                    currentItems.append(contentsOf: newItems)
                    
                    self.productsSubject.onNext(currentItems)
                    self.currentPage = page
                    self.hasMore = response.hasMore
                    self.isLoading = false
                },
                onError: { [weak self] error in
                    print("Error loading market data: \(error)")
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
        let products: Observable<[XHSProductItem]>
        let refreshComplete: Observable<Void>
    }
}

// MARK: - Models
struct XHSProductItem {
    let id: String
    let name: String
    let price: Double
    let imageUrl: String
    let shopName: String
    let sales: Int
}

// MARK: - Views
class XHSMarketProductCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    private let productImageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let shopNameLabel = UILabel()
    private let salesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 8
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.systemGray5.cgColor
        
        // 设置UI元素
        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = UIColor(white: 0.9, alpha: 1.0) // 占位颜色
        
        nameLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2
        
        priceLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        priceLabel.textColor = .red
        priceLabel.text = "¥0.00"
        
        shopNameLabel.font = UIFont.systemFont(ofSize: 12)
        shopNameLabel.textColor = .secondaryLabel
        
        salesLabel.font = UIFont.systemFont(ofSize: 12)
        salesLabel.textColor = .secondaryLabel
        
        // 添加到视图层级
        contentView.addSubview(productImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(shopNameLabel)
        contentView.addSubview(salesLabel)
        
        // 使用SnapKit设置约束
        productImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
            make.height.equalTo(120)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(productImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(8)
        }
        
        shopNameLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(8)
        }
        
        salesLabel.snp.makeConstraints { make in
            make.top.equalTo(shopNameLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configure(with item: XHSProductItem) {
        nameLabel.text = item.name
        priceLabel.text = "¥\(item.price)"
        shopNameLabel.text = item.shopName
        salesLabel.text = "销量 \(item.sales)"
        
        // 模拟使用Kingfisher加载图片 (实际需要导入Kingfisher库)
        // 这里使用模拟的异步加载
        loadImageAsync(from: item.imageUrl, into: productImageView)
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