import SwiftUI
import CoreServices.DictionaryServices

struct TermItem: View {
    @AppStorage("terms", store: defaults) var vocabularyLogAsData = try! JSONEncoder().encode([Term]())

    @State var preferredDefinition: String = ""
    @State var definitions: [Definition]?
    @State var apiErrorDescription: String?

    var term: Term
    var index: Int

    var body: some View {

        var vocabularyLog = (try? JSONDecoder().decode([Term].self, from: vocabularyLogAsData)) ?? [Term]()
        let word: String = term.word
        let source: String? = term.url
        let example: String = term.exampleSentence
        let termPreferredDef: String? = term.preferredDef

        VStack(alignment: .leading) {
            HStack {
                Text("\(word):")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.yellow)
                    .fixedSize()
                if termPreferredDef != nil { // no need to pick anything.
                    Text(preferredDefinition)
                        .italic()
                    Spacer()
                }
                else if definitions?.count ?? 0 > 0 {
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
                }
                else if apiErrorDescription != nil {
                    TextField("\(apiErrorDescription ?? " ")Please type a definition.", text: $preferredDefinition, onCommit: {
                        vocabularyLog[index].preferredDef = self.preferredDefinition
                        updateLogInAppStorage(log: vocabularyLog)
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle.init())
                }
                else {
                    Text("􀙇 Fetching Definitions...")
                        .foregroundColor(.blue)
                    Spacer()
                }
            }.onAppear {
                print(termPreferredDef ?? "🏎")
                if (index >= 0 && vocabularyLog.count > index) {
                    preferredDefinition = termPreferredDef ?? ""
                }
            }
            Text("\""+example+"\"")
                .fixedSize(horizontal: false, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                .padding(1)
            if source != nil {
                LinkView(source: source!)
            }
        }
        .padding(10)
        .background(Color.init("bubbleColor"))
        .cornerRadius(8)
        .onAppear {
            Api().define(word: word) { result in
                switch result {
                case.success(let defs):
                    apiErrorDescription = nil
                    definitions = defs
                case.failure(.badURL):
                    print("2")
                    apiErrorDescription = "􀙥 Invalid Fetch URL: "
                case.failure(.decodingError):
                    print("3")
                    apiErrorDescription = "􀄢 Unknown Word: "
                case.failure(.requestFailed):
                    print("4")
                    apiErrorDescription = "􀙥 Connection Failure: "
                case.failure(.unknown):
                    print("5")
                    apiErrorDescription = "􀒉 Unknown Error: "
                }
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
        TermItem(term: Term(word: "Percolate", exampleSentence: "You'll meet a girl and find out later, she smells just like a percolator.", url: "google", preferredDef: "to filter"), index: 1)
    }
}

struct LinkView: View {
    var source: String
    var body: some View {
        if source != "" {
            Link(destination: URL(string: source)!, label: {
                HStack {
                    Image(systemName: "safari")
                    Text(URL(string: source)!.host ?? "Source Link")
                        .font(.callout)
                        .offset(x: -4)
                }
                .foregroundColor(Color.init("BW"))
                .padding(6)
                .background(Color.init("LinkColor"))
                .cornerRadius(9)
            })
        }
    }
}
