import ReSwift
import UIKit
import KeychainSwift

class SignUpController: UIViewController, StoreSubscriber {
    // MARK: Properties

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!

    var timer: Timer?
    
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
    
    /// Update the progress bar value repeatedly.
    func updateProgressBar() {
        Timer.scheduledTimer(withTimeInterval: 1 / 200, repeats: true) { timer in
            DispatchQueue.main.async {
                if self.progressView.isHidden {
                    self.progressView.setProgress(0, animated: false)
                    timer.invalidate()
                    return
                }
                
                var newProgress = self.progressView.progress + 0.01
                
                if newProgress >= 1 {
                    newProgress = 0
                }
                self.progressView.setProgress(newProgress, animated: false)
            }
        }
    }

    ///Set the UI to a loading state.
    func setLoading() {
        UIView.transition(with: submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
            self.submitButton.isHidden = true
            self.progressView.isHidden = false
            self.updateProgressBar()
        }, completion: { _ in })
    }
    
    ///Hide and redisplay the UI elements, set the user, and navigate to the Home Page.
    func setSuccess(name: String, email: String, password: String) {
        DispatchQueue.main.async {
            UIView.transition(with: self.submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
                self.errorMessageLabel.isHidden = true
                self.submitButton.isHidden = false
                self.progressView.isHidden = true
            }, completion: { _ in })
            
            //Navigate to the Home Page.
            let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeController")
            vc.modalPresentationStyle = .fullScreen
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
            //Set the password in the keychain.
            let keychain = KeychainSwift()
            keychain.set(password, forKey: "password")
            
            //Set the user in the Redux State.
            mainStore.dispatch(SetUserAction(user: User(name: name, email: email, password: password)))
        }
    }
    
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
        //Get the input texts from the text fields.
        guard let nameText = nameTextField.text, let emailText = emailTextField.text, let passwordText = passwordTextField.text else {
            return
        }
        
        //Set the UI to a loading state.
        setLoading()

        //Sign up the user.
        let authService = AuthService()
        authService.signUp(name: nameText, email: emailText, password: passwordText, completed: {
            self.setSuccess(name: nameText, email: emailText, password: passwordText)
        }, onError: { err in
            self.setError(error: err)
        })
    }
}
