import UIKit
import RxSwift
import RxCocoa
import SnapKit

class XHSMessageViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    
    // MARK: - Properties
    private let viewModel = XHSMessageViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupUI() {
        super.setupUI()
        title = "消息"
        
        setupTableView()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let input = XHSMessageViewModel.Input(
            viewDidLoad: Observable.just(())
        )
        
        let output = viewModel.transform(input: input)
        
        // 绑定数据到tableView
        output.messageItems
            .bind(to: tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell") ?? XHSMessageTableViewCell(style: .subtitle, reuseIdentifier: "MessageCell")
                cell.configure(with: item)
                return cell
            }
            .disposed(by: disposeBag)
        
        // 处理cell点击事件
        tableView.rx.modelSelected(XHSMessageItem.self)
            .subscribe(onNext: { [weak self] item in
                // 处理点击事件，跳转到聊天页面
                self?.navigateToChat(with: item)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.register(XHSMessageTableViewCell.self, forCellReuseIdentifier: "MessageCell")
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = .systemBackground
    }
    
    private func navigateToChat(with messageItem: XHSMessageItem) {
        // 这里应该跳转到聊天详情页面
        let chatVC = XHSChatViewController()
        chatVC.title = messageItem.senderName
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - View Model
class XHSMessageViewModel: XHSBaseViewModel {
    
    override func transform(input: Input) -> Output {
        let messageItems = Observable.just(generateMockData())
        
        return Output(messageItems: messageItems)
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let messageItems: Observable<[XHSMessageItem]>
    }
    
    private func generateMockData() -> [XHSMessageItem] {
        return [
            XHSMessageItem(id: "1", senderName: "小红书官方", content: "您的账号有新动态", time: "10:30", unreadCount: 5, messageType: .system),
            XHSMessageItem(id: "2", senderName: "时尚达人", content: "谢谢你的点赞和关注", time: "09:45", unreadCount: 2, messageType: .comment),
            XHSMessageItem(id: "3", senderName: "美妆博主", content: "分享了新的笔记", time: "昨天", unreadCount: 0, messageType: .like),
            XHSMessageItem(id: "4", senderName: "旅行家", content: "对你的笔记进行了评论", time: "前天", unreadCount: 0, messageType: .comment),
            XHSMessageItem(id: "5", senderName: "好友A", content: "周末一起去逛街吗？", time: "周六", unreadCount: 1, messageType: .chat),
            XHSMessageItem(id: "6", senderName: "好友B", content: "看到了你发的照片，真漂亮！", time: "周五", unreadCount: 0, messageType: .like)
        ]
    }
}

// MARK: - Models
struct XHSMessageItem {
    let id: String
    let senderName: String
    let content: String
    let time: String
    let unreadCount: Int
    let messageType: MessageType
}

enum MessageType {
    case system    // 系统消息
    case comment   // 评论消息
    case like      // 点赞消息
    case chat      // 聊天消息
}

// MARK: - Views
class XHSMessageTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let contentLabel = UILabel()
    private let timeLabel = UILabel()
    private let unreadCountLabel = UILabel()
    private let messageIndicatorView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        // 设置UI元素
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameLabel.textColor = .label
        
        contentLabel.font = UIFont.systemFont(ofSize: 14)
        contentLabel.textColor = .secondaryLabel
        contentLabel.numberOfLines = 1
        
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .tertiaryLabel
        
        unreadCountLabel.backgroundColor = .red
        unreadCountLabel.textColor = .white
        unreadCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        unreadCountLabel.textAlignment = .center
        unreadCountLabel.layer.cornerRadius = 10
        unreadCountLabel.clipsToBounds = true
        
        messageIndicatorView.layer.cornerRadius = 3
        messageIndicatorView.backgroundColor = .systemBlue
        
        // 添加到视图层级
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(unreadCountLabel)
        contentView.addSubview(messageIndicatorView)
        
        // 使用SnapKit设置约束
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(50)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalTo(timeLabel.snp.leading).inset(-8)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(16)
            make.width.lessThanOrEqualTo(80)
        }
        
        contentLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(16)
        }
        
        unreadCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        messageIndicatorView.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(-6)
            make.bottom.equalTo(avatarImageView).offset(-2)
            make.width.equalTo(12)
            make.height.equalTo(12)
        }
        
        // 隐藏未读消息指示器，当有未读消息时显示
        messageIndicatorView.isHidden = true
    }
    
    func configure(with item: XHSMessageItem) {
        nameLabel.text = item.senderName
        contentLabel.text = item.content
        timeLabel.text = item.time
        
        // 设置头像（暂时用颜色代替）
        avatarImageView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0)
        
        // 配置未读消息
        if item.unreadCount > 0 {
            unreadCountLabel.text = item.unreadCount > 99 ? "99+" : "\(item.unreadCount)"
            unreadCountLabel.isHidden = false
            messageIndicatorView.isHidden = false
        } else {
            unreadCountLabel.isHidden = true
            messageIndicatorView.isHidden = true
        }
    }
}

// MARK: - Chat View Controller
class XHSChatViewController: XHSBaseViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let messageInputView = XHSMessageInputView()
    
    // MARK: - Properties
    private let viewModel = XHSChatViewModel()
    private let disposeBag = DisposeBag()
    
    override func setupUI() {
        super.setupUI()
        
        setupTableView()
        setupMessageInputView()
        setupConstraints()
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        let input = XHSChatViewModel.Input(
            viewDidLoad: Observable.just(()),
            sendMessage: messageInputView.sendButton.rx.tap.asObservable()
                .withLatestFrom(messageInputView.messageTextField.rx.text.orEmpty)
                .filter { !$0.isEmpty }
        )
        
        let output = viewModel.transform(input: input)
        
        // 绑定消息数据
        output.messages
            .bind(to: tableView.rx.items) { tableView, row, message in
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") ?? XHSChatTableViewCell(style: .default, reuseIdentifier: "ChatCell")
                cell.configure(with: message)
                return cell
            }
            .disposed(by: disposeBag)
        
        // 发送消息后清空输入框
        input.sendMessage
            .subscribe(onNext: { [weak self] _ in
                self?.messageInputView.messageTextField.text = ""
            })
            .disposed(by: disposeBag)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.register(XHSChatTableViewCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    }
    
    private func setupMessageInputView() {
        view.addSubview(messageInputView)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(messageInputView.snp.top)
        }
        
        messageInputView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
    }
}

// MARK: - Chat View Model
class XHSChatViewModel: XHSBaseViewModel {
    
    override func transform(input: Input) -> Output {
        let messages = Observable.just(generateMockData())
        
        return Output(messages: messages)
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let sendMessage: Observable<String>
    }
    
    struct Output {
        let messages: Observable<[XHSChatMessage]>
    }
    
    private func generateMockData() -> [XHSChatMessage] {
        return [
            XHSChatMessage(id: "1", senderId: "other", content: "你好！看到你分享的内容了，很棒！", timestamp: Date().addingTimeInterval(-3600), isFromCurrentUser: false),
            XHSChatMessage(id: "2", senderId: "current", content: "谢谢！很高兴你喜欢", timestamp: Date().addingTimeInterval(-3500), isFromCurrentUser: true),
            XHSChatMessage(id: "3", senderId: "other", content: "请问这个是在哪里买的？", timestamp: Date().addingTimeInterval(-3400), isFromCurrentUser: false),
            XHSChatMessage(id: "4", senderId: "current", content: "这个是在市集里找到的，很特别吧", timestamp: Date().addingTimeInterval(-3300), isFromCurrentUser: true)
        ]
    }
}

// MARK: - Chat Models
struct XHSChatMessage {
    let id: String
    let senderId: String
    let content: String
    let timestamp: Date
    let isFromCurrentUser: Bool
}

// MARK: - Chat Views
class XHSMessageInputView: UIView {
    
    // MARK: - UI Elements
    let messageTextField = UITextField()
    let sendButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        
        messageTextField.placeholder = "输入消息..."
        messageTextField.borderStyle = .roundedRect
        messageTextField.font = UIFont.systemFont(ofSize: 14)
        
        sendButton.setTitle("发送", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        sendButton.backgroundColor = .red
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.layer.cornerRadius = 4
        
        addSubview(messageTextField)
        addSubview(sendButton)
        
        messageTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(sendButton.snp.leading).inset(-8)
            make.height.equalTo(36)
        }
        
        sendButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
    }
}

class XHSChatTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    private let messageLabel = UILabel()
    private let bubbleView = UIView()
    
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
        
        bubbleView.layer.cornerRadius = 8
        bubbleView.backgroundColor = .systemGray5
        
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 0
        
        contentView.addSubview(bubbleView)
        contentView.addSubview(messageLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 根据消息类型调整布局
        if let message = messageLabel.text, message.count > 0 {
            let isFromCurrentUser = (messageLabel.superview?.superview as? XHSChatTableViewCell)?.tag == 1
            
            if isFromCurrentUser {
                // 当前用户消息在右侧
                bubbleView.snp.remakeConstraints { make in
                    make.trailing.equalToSuperview().inset(16)
                    make.top.bottom.equalToSuperview().inset(4)
                    make.width.lessThanOrEqualTo(contentView.frame.width * 0.7)
                    make.leading.greaterThanOrEqualTo(contentView.snp.centerX)
                }
                
                messageLabel.snp.remakeConstraints { make in
                    make.trailing.equalTo(bubbleView).inset(12)
                    make.top.bottom.equalTo(bubbleView).inset(8)
                    make.leading.greaterThanOrEqualTo(contentView.snp.centerX)
                }
            } else {
                // 其他用户消息在左侧
                bubbleView.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().inset(16)
                    make.top.bottom.equalToSuperview().inset(4)
                    make.width.lessThanOrEqualTo(contentView.frame.width * 0.7)
                    make.trailing.lessThanOrEqualTo(contentView.snp.centerX)
                }
                
                messageLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(bubbleView).inset(12)
                    make.top.bottom.equalTo(bubbleView).inset(8)
                    make.trailing.lessThanOrEqualTo(contentView.snp.centerX)
                }
            }
        }
    }
    
    func configure(with message: XHSChatMessage) {
        messageLabel.text = message.content
        tag = message.isFromCurrentUser ? 1 : 0  // 用tag标识消息来源
        setNeedsLayout()
    }
}