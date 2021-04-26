import ReSwift

///The main store instance.
let mainStore = Store<AppState>(
    reducer: appReducer,
    state: AppState()
)
