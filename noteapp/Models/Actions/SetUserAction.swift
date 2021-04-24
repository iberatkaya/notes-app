import ReSwift

///Set the user.
struct SetUserAction: Action {
    init(user: User) {
        self.user = user
    }
    
    let user: User
    
}
