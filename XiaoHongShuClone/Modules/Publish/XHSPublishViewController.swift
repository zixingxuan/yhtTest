import UIKit
import RxSwift
import RxCocoa
import SnapKit

class XHSPublishViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let titleTextField = UITextField()
    private let contentTextView = UITextView()
    private let imageView = UIImageView()
    private let imagePickerButton = UIButton(type: .system)
    private let publishButton = UIButton(type: .system)
    
    // MARK: - Properties
    private let viewModel = XHSPublishViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "发布"
        
        setupNavigationItem()
        setupScrollView()
        setupSubviews()
        setupConstraints()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        // 创建输入
        let titleInput = titleTextField.rx.text.orEmpty.asObservable()
        let contentInput = contentTextView.rx.text.orEmpty.asObservable()
        let publishTap = publishButton.rx.tap.asObservable()
        
        let input = XHSPublishViewModel.Input(
            title: titleInput,
            content: contentInput,
            publishTap: publishTap
        )
        
        let output = viewModel.transform(input: input)
        
        // 绑定发布按钮状态
        output.isPublishEnabled
            .bind(to: publishButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // 监听发布结果
        output.publishResult
            .subscribe(onNext: { [weak self] success in
                if success {
                    // 发布成功，返回上一页或显示成功提示
                    self?.showPublishSuccess()
                } else {
                    // 发布失败，显示错误提示
                    self?.showPublishError()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "取消",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
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
    
    private func setupSubviews() {
        // 标题
        titleLabel.text = "标题"
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        
        titleTextField.placeholder = "请输入标题"
        titleTextField.borderStyle = .roundedRect
        titleTextField.font = UIFont.systemFont(ofSize: 14)
        
        // 内容
        contentTextView.font = UIFont.systemFont(ofSize: 14)
        contentTextView.layer.borderWidth = 0.5
        contentTextView.layer.borderColor = UIColor.systemGray4.cgColor
        contentTextView.layer.cornerRadius = 8
        contentTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        // 图片选择区域
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        
        imagePickerButton.setTitle("添加图片", for: .normal)
        imagePickerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        imagePickerButton.setTitleColor(.systemBlue, for: .normal)
        
        // 发布按钮
        publishButton.setTitle("发布", for: .normal)
        publishButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        publishButton.backgroundColor = .red
        publishButton.setTitleColor(.white, for: .normal)
        publishButton.layer.cornerRadius = 24
        publishButton.isEnabled = false // 初始状态为禁用
        
        // 添加到视图层级
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(contentTextView)
        contentView.addSubview(imageView)
        contentView.addSubview(imagePickerButton)
        contentView.addSubview(publishButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(40)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(20)
            make.leading.trailing.equalTo(titleLabel)
            make.height.equalTo(150)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(20)
            make.leading.equalTo(titleLabel)
            make.width.height.equalTo(100)
        }
        
        imagePickerButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.trailing.equalTo(titleLabel)
        }
        
        publishButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(40)  // 确保底部有间距
        }
    }
    
    @objc private func cancelButtonTapped() {
        // 返回上一页
        dismiss(animated: true, completion: nil)
    }
    
    private func showPublishSuccess() {
        let alert = UIAlertController(title: "发布成功", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            self.dismiss(animated: true, completion: nil)
        })
        present(alert, animated: true)
    }
    
    private func showPublishError() {
        let alert = UIAlertController(title: "发布失败", message: "请检查网络连接或稍后再试", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - View Model
class XHSPublishViewModel: XHSBaseViewModel {
    
    override func transform(input: Input) -> Output {
        // 验证标题和内容是否为空
        let isPublishEnabled = Observable
            .combineLatest(input.title, input.content)
            .map { title, content in
                return !title.isEmpty && !content.isEmpty
            }
            .startWith(false) // 初始状态为false
        
        // 处理发布事件
        let publishResult = input.publishTap
            .withLatestFrom(isPublishEnabled)
            .filter { $0 } // 只有当发布按钮启用时才处理
            .flatMap { _ in
                // 模拟发布操作
                return self.mockPublishRequest()
            }
            .startWith(nil) // 初始值
            .map { $0 ?? false }
        
        return Output(
            isPublishEnabled: isPublishEnabled,
            publishResult: publishResult
        )
    }
    
    private func mockPublishRequest() -> Observable<Bool> {
        return Observable.create { observer in
            // 模拟网络请求延迟
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // 模拟发布成功
                observer.onNext(true)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    struct Input {
        let title: Observable<String>
        let content: Observable<String>
        let publishTap: Observable<Void>
    }
    
    struct Output {
        let isPublishEnabled: Observable<Bool>
        let publishResult: Observable<Bool>
    }
}