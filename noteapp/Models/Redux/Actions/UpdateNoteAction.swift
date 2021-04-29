import ReSwift

/// Update a note in the store.
struct UpdateNoteAction: Action {
    init(noteId: String, title: String?, body: String?) {
        self.noteId = noteId
        self.title = title
        self.body = body
    }

    /// The updated note ID.
    let noteId: String

    /// The optional new title.
    let title: String?

    /// The optional new body.
    let body: String?
}
