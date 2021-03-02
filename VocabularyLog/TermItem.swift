import SwiftUI
import CoreServices.DictionaryServices

struct TermItem: View {
    @AppStorage("terms", store: defaults) var vocabularyLogAsData = try! JSONEncoder().encode([Term]())

    @State var preferredDefinition: String = ""
    @State var definitions: [Definition]?

    var term: String
    var index: Int
    var source: String
    var example: String

    var body: some View {
        var vocabularyLog = (try? JSONDecoder().decode([Term].self, from: vocabularyLogAsData)) ?? [Term]()
        VStack(alignment: .leading) {
            HStack {
                Text("\(term):")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.yellow)
                    .fixedSize()
                Picker("Select", selection: Binding(get: {
                    preferredDefinition
                }, set: { newValue in
                    vocabularyLog[index].preferredDef = newValue
                    updateLogInAppStorage(log: vocabularyLog)
                    preferredDefinition = newValue
                })) {
                    ForEach(definitions ?? [], id: \.definition) { definition in
                        Text(definition.definition)
                    }
                }.labelsHidden()
            }.onAppear {
                print(index)
                if (index >= 0 && vocabularyLog.count > index) {
                    preferredDefinition = vocabularyLog[index].preferredDef
                }
            }
            Text("\""+example+"\"")
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .padding(1)
            Link(destination: URL(string: source)!, label: {
                HStack {
                    Image(systemName: "safari")
                    Text(URL(string: source)!.host ?? "Source Link")
                        .foregroundColor(.white)
                }.padding(5)
                .background(Color.gray)
                .cornerRadius(6)
            })
        }
        .background(Color.init("mg"))
        .cornerRadius(8)
        .onAppear {
            Api().define(word: term) { (results) in
                definitions = results?.first?.meanings.first?.definitions ?? [Definition(definition: (vocabularyLog[index].preferredDef))]
            }
        }
    }

    func updateLogInAppStorage(log: [Term]) {
        let encoder = JSONEncoder()
        if let updatedLog = try? encoder.encode(log) {
            defaults.set(updatedLog, forKey: "terms")
        }
    }

}

struct TermItem_Previews: PreviewProvider {
    static var previews: some View {
        TermItem(term: "Percolate", index: 1, source: "wikipedia.com", example: "You'll meet a girl and find out later / she smells just like a percolator.")
    }
}

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}
