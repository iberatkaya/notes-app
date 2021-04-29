import ReSwift

func appReducer(action: Action, state: AppState?) -> AppState {
    var state = state ?? AppState()

    switch action {
        case let act as SetUserAction:
            state.user = act.user
        case _ as SignOutAction:
            state.user = nil
        case let act as AddNotesAction:
            state.notes = addNoteArray(state.notes, addedNotes: act.notes)
        case let act as UpdateNoteAction:
            if let index = state.notes.firstIndex(where: { $0.id == act.noteId }) {
                if let title = act.title {
                    state.notes[index].title = title
                }
                if let body = act.body {
                    state.notes[index].body = body
                }
            }
        case let act as DeleteNoteAction:
            state.notes.removeAll(where: { $0.id == act.noteId })
        default:
            break
    }

    return state
}
