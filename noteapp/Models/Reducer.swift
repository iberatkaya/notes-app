import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
        case let act as SetUserAction:
            state.user = act.user
        case _ as SignOutAction:
            state.user = nil
        default:
            break
    }

    return state
}
