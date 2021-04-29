import ReSwift

/// Add notes to the store.
struct AddNotesAction: Action {
    init(notes: [Note]) {
        self.notes = notes
    }

    let notes: [Note]
}
