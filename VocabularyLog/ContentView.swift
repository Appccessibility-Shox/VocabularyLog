import SwiftUI

let defaults = UserDefaults.init(suiteName: "L27L4K8SQU.VocabularyLog")!


struct ContentView: View {

    @AppStorage("terms", store: defaults) var vocabularyLogAsData = try! JSONEncoder().encode([Term]())

    var body: some View {

        var vocabularyLog = (try? JSONDecoder().decode([Term].self, from: vocabularyLogAsData)) ?? [Term]()

        HStack {
            Text("Vocabulary Log 􀌀")
                .font(Font.custom("SF Compact Rounded", size: 33))
                .fontWeight(.bold)
                .foregroundColor(Color.yellow)
                .padding(.init(top: 15, leading: 20, bottom: -0.5, trailing: 0))
            Spacer()
        }
        
        List {
            ForEach(Array((vocabularyLog).enumerated()), id: \.1.id) { (index, term) in
                TermItem(term: term, index: index)
            }.onDelete(perform: { indexSet in
                vocabularyLog.remove(atOffsets: indexSet)
                updateLogInAppStorage(log: vocabularyLog)
            })
            .onMove(perform: { indices, newOffset in
                vocabularyLog.move(fromOffsets: indices, toOffset: newOffset)
                updateLogInAppStorage(log: vocabularyLog)
            })
        }
        .toolbar(content: {
            Spacer()
            Button(action: {}, label: {
                Image(systemName: "plus")
            })
        })
        .frame(minWidth: 450, minHeight: 450)

    }

    func updateLogInAppStorage(log: [Term]) {
        let encoder = JSONEncoder()
        if let updatedLog = try? encoder.encode(log) {
            defaults.set(updatedLog, forKey: "terms")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
