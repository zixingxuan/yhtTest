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
            viewDidLoad: Observable.just(())
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
    }
}

// MARK: - View Model
class XHSMarketViewModel: XHSBaseViewModel {
    
    override func transform(input: Input) -> Output {
        let products = Observable.just(generateMockData())
        
        return Output(products: products)
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let products: Observable<[XHSProductItem]>
    }
    
    private func generateMockData() -> [XHSProductItem] {
        return [
            XHSProductItem(id: "1", name: "夏日连衣裙", price: 299.0, imageUrl: "", shopName: "时尚小店", sales: 128),
            XHSProductItem(id: "2", name: "美妆套装", price: 199.0, imageUrl: "", shopName: "美妆专营", sales: 256),
            XHSProductItem(id: "3", name: "家居装饰", price: 89.0, imageUrl: "", shopName: "生活家居", sales: 98),
            XHSProductItem(id: "4", name: "数码配件", price: 159.0, imageUrl: "", shopName: "数码潮品", sales: 76),
            XHSProductItem(id: "5", name: "运动装备", price: 399.0, imageUrl: "", shopName: "运动天地", sales: 142),
            XHSProductItem(id: "6", name: "图书文具", price: 49.0, imageUrl: "", shopName: "书香门第", sales: 210)
        ]
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
        
        // 这里应该设置图片，暂时用背景色代替
        productImageView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
    }
}