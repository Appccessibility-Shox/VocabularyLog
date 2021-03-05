//
//  AddWordSheet.swift
//  VocabularyLog
//
//  Created by Patrick Botros on 3/2/21.
//

import SwiftUI

struct AddWordSheet: View {
    @Binding var showingDetail: Bool
    @State var newWord: String = ""
    @State var newDefinition: String = ""
    @State var newExampleSentence: String = ""
    @State var newSource: String = ""

    var body: some View {
        var vocabularyLog = (try? JSONDecoder().decode([Term].self, from: defaults.object(forKey: "terms") as! Data)) ?? [Term]()
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
                Button("Cancel", action: {
                    showingDetail = false
                }).keyboardShortcut(.cancelAction)
                Button("Save", action: {
                    let newTerm = Term(word: newWord, exampleSentence: newExampleSentence, url: newSource, preferredDef: newDefinition, id: UUID())
                    vocabularyLog.append(newTerm)
                    updateLogInAppStorage(log: vocabularyLog)
                    showingDetail = false
                }).keyboardShortcut(.defaultAction)
                .disabled(newWord.count < 1 || newDefinition.count < 1 || newExampleSentence.count < 1)
            }.padding(10)
        }
        .frame(width: 420)
        .padding(10)
    }
    
    func updateLogInAppStorage(log: [Term]) {
        let encoder = JSONEncoder()
        if let updatedLog = try? encoder.encode(log) {
            defaults.set(updatedLog, forKey: "terms")
        }
    }
}

struct PreviewWrapper: View {
    @State var a = true
    
    var body: some View {
        AddWordSheet(showingDetail: $a)
    }
}
struct AddWordSheet_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
}
