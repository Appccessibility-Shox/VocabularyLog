import SwiftUI

struct AddWordSheet: View {
    @Binding var showingDetail: Bool
    @State var newWord: String = ""
    @State var newDefinition: String = ""
    @State var newExampleSentence: String = ""
    @State var newSource: String = ""

    var body: some View {
        var vocabularyLog = (try? JSONDecoder().decode([Term].self, from: defaults.object(forKey: "terms") as? Data ?? Data())) ?? [Term]()
        Text("Manually Add Term")
            .font(.title2)
            .fontWeight(.bold)
            .foregroundColor(Color.yellow)
            .padding(.top, 20)
        Form {
            Section {
                HStack {
                    Spacer()
                    Text("Term:")
                        .font(.caption)
                    TextField("", text: $newWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                        .frame(width: 300)
                }
                    .padding(.vertical, 2)
                HStack {
                    Spacer()
                    Text("Definition:")
                        .font(.caption)
                    TextField("", text: $newDefinition)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                        .frame(width: 300)
                }
                    .padding(.vertical, 2)
                HStack {
                    Spacer()
                    Text("Example Sentence:")
                        .font(.caption)
                    TextField("", text: $newExampleSentence)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                        .frame(width: 300)
                }
                    .padding(.vertical, 2)
                HStack {
                    Spacer()
                    Text("URL:")
                        .font(.caption)
                    TextField("", text: $newSource)
                        .textFieldStyle(RoundedBorderTextFieldStyle.init())
                        .frame(width: 300)
                }
            }
            .padding(.vertical, 2)
            Divider()
            HStack {
                Spacer()
                Button("Cancel", action: hideSheet)
                    .keyboardShortcut(.cancelAction)
                Button("Save", action: {saveNewWord(to: &vocabularyLog)})
                    .keyboardShortcut(.defaultAction)
                    .disabled(missingFormEntries)
            }.padding(10)
        }
        .frame(width: 420)
        .padding(10)
    }
    
    var missingFormEntries: Bool {
        // true if some form entries are missing. False otherwise.
        return newWord.count < 1 || newDefinition.count < 1 || newExampleSentence.count < 1
    }

    func saveNewWord(to log: inout [Term]) {
        let newTerm = Term(word: newWord, exampleSentence: newExampleSentence, url: newSource, preferredDef: newDefinition, id: UUID())
        log.append(newTerm)
        updateLogInAppStorage(log: log)
        hideSheet()
    }

    func hideSheet() {
        showingDetail = false
    }
}

// Preview Code:
struct PreviewWrapper: View {
    @State var yes = true
    
    var body: some View {
        AddWordSheet(showingDetail: $yes)
    }
}

struct AddWordSheet_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
}
