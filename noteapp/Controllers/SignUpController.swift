import UIKit

class SignUpController: UIViewController {
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
    
    // MARK: Utils
    func setLoading() {
        UIView.transition(with: submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
            self.submitButton.isHidden = true
            self.progressView.isHidden = false
            self.updateProgressBar()
        }, completion: { _ in })
    }
    
    func setSuccess() {
        DispatchQueue.main.async {
            UIView.transition(with: self.submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
                self.errorMessageLabel.isHidden = true
                self.submitButton.isHidden = false
                self.progressView.isHidden = true
            }, completion: { _ in })
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
        guard let nameText = nameTextField.text, let emailText = emailTextField.text, let passwordText = passwordTextField.text else {
            return
        }
        let authService = AuthService()
        setLoading()
        authService.signUp(name: nameText, email: emailText, password: passwordText, completed: {
            self.setSuccess()
        }, onError: { err in
            self.setError(error: err)
        })
    }
}
