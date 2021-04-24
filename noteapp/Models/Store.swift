import ReSwift

let mainStore = Store<AppState>(
    reducer: appReducer,
    state: AppState()
)
