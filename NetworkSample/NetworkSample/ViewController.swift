import UIKit

final class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        SomeService().request(SomeServiceRoute.prepare) { [weak self] response in
            print(response)

            switch response {
            case .success(let result):
                self?.presentAlert(title: "Success", message: "Response: \(result.object.someString)")

            case .failure(let error):
                self?.presentAlert(title: "Error", message: "Error: \(error.localizedDescription)")
            }

        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
