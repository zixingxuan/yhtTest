import UIKit

class XHSBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: - Subclasses should override
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
    
    func bindViewModel() {
        // 子类重写以绑定ViewModel
    }
}