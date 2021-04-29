import ReSwift
import UIKit

class NoteDetailController: UIViewController, StoreSubscriber {
    // MARK: Properties

    var note: Note!

    @IBOutlet var titleView: UITextView!
    @IBOutlet var bodyView: UITextView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var editButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        titleView.text = note.title
        bodyView.text = note.body
        dateLabel.text = formatDateTime(date: note.date)
    }

    // MARK: UI Utils

    /// Set up the view for note editing.
    func _enableEditingView() {
        UIView.transition(with: editButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
            self.titleView.isEditable = true
            self.bodyView.isEditable = true
            let checkImage = UIImage(systemName: "checkmark.circle")?.withTintColor(.orange, renderingMode: .alwaysOriginal)
            self.editButton.setImage(checkImage, for: .normal)
        }, completion: { _ in })
    }

    /// Disable the view for note editing.
    func _disableEditingView() {
        UIView.transition(with: editButton, duration: 0.4, options: .transitionCrossDissolve, animations: { () -> Void in
            DispatchQueue.main.async {
                self.titleView.isEditable = false
                self.bodyView.isEditable = false
                let checkImage = UIImage(systemName: "pencil.circle")?.withTintColor(.blue, renderingMode: .alwaysOriginal)
                self.editButton.setImage(checkImage, for: .normal)
            }
        }, completion: { _ in })
    }

    // MARK: Fetching

    func _updateNote(completed: @escaping () -> Void, onError: @escaping (String) -> Void) {
        guard let user = mainStore.state.user else {
            return
        }

        let noteService = NoteService(user: user)

        noteService.editNote(id: note.id, title: titleView.text, body: bodyView.text, completed: completed, onError: onError)
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

    @IBAction func editButtonPressed(_ sender: UIButton) {
        if bodyView.isEditable {
            _disableEditingView()
            _updateNote(completed: {
                DispatchQueue.main.async {
                    self._disableEditingView()
                    mainStore.dispatch(UpdateNoteAction(noteId: self.note.id, title: self.titleView.text, body: self.bodyView.text))
                }
            }, onError: { _ in })
        }
        else {
            _enableEditingView()
        }
    }
}
