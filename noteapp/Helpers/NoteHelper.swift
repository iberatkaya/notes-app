func addNoteArray(_ notes: [Note], addedNotes: [Note]) -> [Note] {
    var resultArray = notes

    for note in addedNotes {
        if let noteIndex = resultArray.firstIndex(where: { $0.id == note.id }) {
            resultArray[noteIndex] = note
        }
        else {
            resultArray.append(note)
        }
    }
    resultArray.sort(by: { a, b in a.date.compare(b.date) == .orderedDescending })
    return resultArray
}
