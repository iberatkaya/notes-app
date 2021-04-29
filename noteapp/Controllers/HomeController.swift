import ReSwift
import UIKit

class HomeController: UIViewController, StoreSubscriber, UITableViewDataSource, UITableViewDelegate {
    // MARK: UITableViewDataSource Protocol

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Used for pagination.
        // Check if last cell.
        if indexPath.row == notes.count - 1 {
            // Check if there is more notes to fetch.
            if canFetchMore {
                page += 1
                _fetchData()
            }
        }

        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell_id_\(indexPath.row)")
        cell.textLabel?.text = notes[indexPath.row].title
        cell.detailTextLabel?.text = notes[indexPath.row].body
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let user = mainStore.state.user else {
                return
            }
            let deletedNote = notes[indexPath.item]
            let noteService = NoteService(user: user)
            noteService.deleteNote(noteId: deletedNote.id, completed: {
                DispatchQueue.main.async {
                    self.notes.remove(at: indexPath.item)
                    mainStore.dispatch(DeleteNoteAction(noteId: deletedNote.id))
                }
            }, onError: { err in
                self.errorLabel.text = err
            })
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.item

        let storyboard = UIStoryboard(name: "NoteDetail", bundle: nil)

        guard let vc = storyboard.instantiateViewController(withIdentifier: "NoteDetail") as? NoteDetailController else {
            return
        }

        vc.note = notes[section]

        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: Properties

    /// The user's notes.
    var notes = [Note]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }

    /// The page of the request.
    var page = 0

    /// Check if more notes can be fetched.
    var canFetchMore = true

    /// The refresh control for pull to refresh.
    var refreshControl = UIRefreshControl()

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var plusButton: UIButton!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var helperLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Notes"
        _setupButton()
        _setupTable()
        _fetchData()
        _setupHelperLabel()
    }

    // MARK: Fetching

    /// Used for pull to refresh.
    @objc func refresh(_ sender: AnyObject) {
        _fetchData()
    }

    /// Fetch notes from the server.
    func _fetchData() {
        guard let user = mainStore.state.user else {
            return
        }

        if !helperLabel.isHidden {
            progressView.isHidden = false
        }

        updateProgressBar(progressView: progressView)

        let noteService = NoteService(user: user)
        noteService.fetchNotes(page: page, completed: { data in
            DispatchQueue.main.async {
                if data.count == 0 {
                    self.canFetchMore = false
                    if self.page > 0 {
                        self.page -= 1
                    }
                }

                mainStore.dispatch(AddNotesAction(notes: data))

                if !self.helperLabel.isHidden {
                    self.progressView.isHidden = true
                    self.helperLabel.isHidden = true
                    self._userIsActive()
                }

                self.refreshControl.endRefreshing()
                self.errorLabel.text = ""

                if self.notes.count == 0 {
                    self.helperLabel.isHidden = false
                    self.helperLabel.text = "Add some notes!"
                }
            }
        }, onError: { err, status in
            DispatchQueue.main.async {
                if status == 401 {
                    self._userIsInactive()
                }
                else {
                    self._userIsActive()
                }

                if !self.helperLabel.isHidden {
                    self.progressView.isHidden = true
                }

                self.refreshControl.endRefreshing()
                self.errorLabel.text = err
            }
        })
    }

    // MARK: UI Utils

    /// Setup the table view.
    func _setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    /// Set up the add note button.
    func _setupButton() {
        plusButton.layer.cornerRadius = plusButton.bounds.size.height/2
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        plusButton.layer.shadowRadius = plusButton.bounds.size.height/2
        plusButton.layer.shadowOpacity = 0.25
    }

    /// Set the user as verified and updated UI.
    func _userIsActive() {
        tableView.isHidden = false
        helperLabel.isHidden = true
        // Set the user verification status as active.
        if var user = mainStore.state.user, !user.active {
            user.active = true
            mainStore.dispatch(SetUserAction(user: user))
        }
    }

    /// Set the UI as unverified.
    func _userIsInactive() {
        tableView.isHidden = true
        helperLabel.isHidden = false
        helperLabel.text = "Please verify your email. Click to refresh."
    }

    /// Setup the helper label as a tappable.
    func _setupHelperLabel() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(helperLabelTap))
        helperLabel.isUserInteractionEnabled = true
        helperLabel.addGestureRecognizer(labelTap)
        progressView.isHidden = true
    }

    @objc func helperLabelTap(_ sender: UITapGestureRecognizer) {
        _fetchData()
    }

    // MARK: Redux

    override func viewWillAppear(_ animated: Bool) {
        mainStore.subscribe(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        mainStore.unsubscribe(self)
    }

    func newState(state: AppState) {
        nameLabel.text = state.user?.name
        emailLabel.text = state.user?.email

        notes = state.notes

        if state.user != nil && state.user!.active {
            _userIsActive()
        }
        else {
            _userIsInactive()
        }
    }

    // MARK: Actions

    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        // Sign out the user from the Redux State.
        mainStore.dispatch(SignOutAction())

        // Navigate to the Sign Up Page.
        let vc = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
        vc.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }

    @IBAction func plusButtonPressed(_ sender: UIButton) {
        // Navigate to the `AddNote` page.
        let storyboard = UIStoryboard(name: "AddNote", bundle: nil)

        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddNote") as? AddNoteController else {
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
