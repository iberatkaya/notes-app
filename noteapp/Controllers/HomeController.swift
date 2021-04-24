import UIKit
import ReSwift

class HomeController: UIViewController, StoreSubscriber {
    
    // MARK: Properties

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.title = "Notes"
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
        //Sign out the user from the Redux State.
        mainStore.dispatch(SignOutAction())
        
        //Navigate to the Sign Up Page.
        let vc = UIStoryboard(name: "SignUp", bundle: nil).instantiateViewController(withIdentifier: "SignUpController")
        vc.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)

    }
}
