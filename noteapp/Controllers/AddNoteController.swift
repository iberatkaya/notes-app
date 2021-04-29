import ReSwift
import UIKit

class AddNoteController: UIViewController, StoreSubscriber {
    // MARK: Properties

    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var bodyTextField: UITextView!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var errorMessageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Create Note"
        progressView.isHidden = true
        errorMessageLabel.isHidden = true
        addDoneButtonOnKeyboard()
    }

    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        titleTextField.inputAccessoryView = doneToolbar
        
        bodyTextField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        titleTextField.resignFirstResponder()
        bodyTextField.resignFirstResponder()
    }

    /// Set the UI to a loading state.
    func setLoading() {
        UIView.transition(with: submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
            self.submitButton.isHidden = true
            self.progressView.isHidden = false
            updateProgressBar(progressView: self.progressView)
        }, completion: { _ in })
    }

    /// Hide and redisplay the UI elements, set the user, and navigate to the Home Page.
    /// -  Parameters:
    ///     - note: The created note that will be added to the store.
    func setSuccess(note: Note) {
        DispatchQueue.main.async {
            UIView.transition(with: self.submitButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
                self.errorMessageLabel.isHidden = true
                self.submitButton.isHidden = false
                self.progressView.isHidden = true
                mainStore.dispatch(AddNotesAction(notes: [note]))
            }, completion: { _ in })
            self.navigationController?.popViewController(animated: true)
        }
    }

    /// Set the UI to display the error.
    /// -  Parameters:
    ///     - error: The error message.
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

    // MARK: Redux

    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
    }

    func newState(state: AppState) {}

    // MARK: Actions

    @IBAction func buttonClicked(_ sender: UIButton) {
        guard let user = mainStore.state.user else {
            return
        }
        guard let title = titleTextField.text, let body = bodyTextField.text else {
            return
        }

        setLoading()

        let noteService = NoteService(user: user)
        noteService.createNote(title: title, body: body, completed: { note in
            self.setSuccess(note: note)
        }, onError: { err in
            self.setError(error: err)
        })
    }
}
