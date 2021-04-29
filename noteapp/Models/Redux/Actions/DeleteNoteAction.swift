import ReSwift

/// Delete a note in the store.
struct DeleteNoteAction: Action {
    init(noteId: String) {
        self.noteId = noteId
    }

    /// The deleted note ID.
    let noteId: String
}
