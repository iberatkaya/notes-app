import ReSwift
import UIKit

class HomeController: UIViewController, StoreSubscriber, UITableViewDataSource {
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

    // MARK: Properties

    var notes = [Note]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }

    func addNoteArray(_ notes: [Note], addedNotes: [Note]) -> [Note] {
        var resultArray = notes

        for note in addedNotes {
            if let noteIndex = resultArray.firstIndex(where: { $0.id == note.id }) {
                resultArray[noteIndex] = note
            } else {
                resultArray.append(note)
            }
        }
        resultArray.sort(by: { a, b in a.date.compare(b.date) == .orderedDescending })
        return resultArray
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "Notes"
        _setupButton()
        _setupTable()
        _fetchData()
    }

    override func viewDidAppear(_ animated: Bool) {
        // Used to fetch data when the page is being popped to.
        if !(isMovingToParent || isBeingPresented) {
            page = 0
            _fetchData()
        }
    }

    /// Used for pull to refresh.
    @objc func refresh(_ sender: AnyObject) {
        _fetchData()
    }

    /// Fetch notes from the server.
    func _fetchData() {
        guard let user = mainStore.state.user else {
            return
        }

        let noteService = NoteService(user: user)
        noteService.fetchNotes(page: page, completed: { data in
            DispatchQueue.main.async {
                if data.count == 0 {
                    self.canFetchMore = false
                }
                self.notes = self.addNoteArray(self.notes, addedNotes: data)
                self.refreshControl.endRefreshing()
            }
        }, onError: { err in
            DispatchQueue.main.async { 
                self.refreshControl.endRefreshing()
            }
        })
    }

    // MARK: UI Setup

    ///Setup the table view.
    func _setupTable() {
        tableView?.dataSource = self
        tableView?.tableFooterView = UIView()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }

    ///Set up the add note button.
    func _setupButton() {
        plusButton.layer.cornerRadius = plusButton.bounds.size.height/2
        plusButton.layer.shadowColor = UIColor.black.cgColor
        plusButton.layer.shadowOffset = CGSize(width: 0.0, height: 4.0)
        plusButton.layer.shadowRadius = plusButton.bounds.size.height/2
        plusButton.layer.shadowOpacity = 0.25
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
        //Navigate to the `AddNote` page.
        let storyboard = UIStoryboard(name: "AddNote", bundle: nil)

        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddNote") as? AddNoteController else {
            return
        }

        navigationController?.pushViewController(vc, animated: true)
    }
}
