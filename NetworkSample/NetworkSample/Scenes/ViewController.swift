import UIKit

final class ViewController: UIViewController {
    private let mainButton: UIButton = {
        let button = UIButton()
        button.setTitle("Make Request", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let service: SomeServiceProtocol

    init(service: SomeServiceProtocol = SomeService()) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViewStyle()
    }

    private func setupViewStyle() {
        setupViewHierarchy()
        setupViewConstraints()

        view.backgroundColor = .white

        mainButton.addTarget(self, action: #selector(didTapMainButton), for: .touchUpInside)
    }

    private func setupViewHierarchy() {
        view.addSubview(mainButton)
    }

    private func setupViewConstraints() {
        NSLayoutConstraint.activate([
            mainButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetch() {
        service.request(SomeServiceRoute.prepare) { [weak self] response in
            switch response {
            case let .success(result):
                self?.presentAlert(title: "Success", message: "Response: \(result.someString)")

            case let .failure(error):
                self?.presentAlert(title: "Error", message: "Error: \(error.localizedDescription)")
            }
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Actions

    @objc private func didTapMainButton() {
        fetch()
    }
}
