import KeychainSwift
import ReSwift
import UIKit

class SignUpController: UIViewController, StoreSubscriber {
    // MARK: Properties

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageLabel.isHidden = true
        progressView.isHidden = true
    }
    
    // MARK: Redux
    
    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
    }

    func newState(state: AppState) {}
    
    // MARK: Utils
    
    /// Set the UI to a loading state.
    func setLoading() {
        UIView.transition(with: submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
            self.submitButton.isHidden = true
            self.progressView.isHidden = false
            updateProgressBar(progressView: self.progressView)
        }, completion: { _ in })
    }
    
    /// Hide and redisplay the UI elements, set the user, and navigate to the Home Page.
    /// - Parameters:
    ///     - user: The user instance.
    func setSuccess(user: User) {
        DispatchQueue.main.async {
            UIView.transition(with: self.submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
                self.errorMessageLabel.isHidden = true
                self.submitButton.isHidden = false
                self.progressView.isHidden = true
            }, completion: { _ in })
            
            // Navigate to the Home Page.
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "Home")
            vc.modalPresentationStyle = .fullScreen
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
            // Set the password in the keychain.
            let keychain = KeychainSwift()
            keychain.set(user.password, forKey: "password")
            
            // Set the user in the Redux State.
            mainStore.dispatch(SetUserAction(user: user))
        }
    }
    
    /// Set the UI to display the error.
    /// - Parameters
    ///     - error: The error string.
    func setError(error: String) {
        DispatchQueue.main.async {
            UIView.transition(with: self.submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
                self.errorMessageLabel.isHidden = false
                self.errorMessageLabel.text = error
                self.submitButton.isHidden = false
                self.progressView.isHidden = true
            }, completion: { _ in })
        }
    }

    // MARK: Actions

    @IBAction func submitButtonAction(_ sender: UIButton) {
        // Get the input texts from the text fields.
        guard let nameText = nameTextField.text, let emailText = emailTextField.text, let passwordText = passwordTextField.text else {
            return
        }
        
        // Set the UI to a loading state.
        setLoading()

        // Sign up the user.
        let authService = AuthService()
        authService.signUp(name: nameText, email: emailText, password: passwordText, completed: { user in
            self.setSuccess(user: user)
        }, onError: { err in
            self.setError(error: err)
        })
    }
}
