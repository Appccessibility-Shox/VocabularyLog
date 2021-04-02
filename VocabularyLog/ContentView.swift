import SwiftUI

struct ContentView: View {

    @AppStorage("terms", store: defaults) var vocabularyLogAsData = try! JSONEncoder().encode([Term]())
    @AppStorage("forceClickActivated", store: defaults) var forceClickActivated = false
    @State var showingDetail = false
    @State var showingAlert = false
    @State private var isImporting: Bool = false
    @AppStorage("alertHasShownBefore", store: defaults) var alertHasShownBefore = true
    
    var body: some View {

        var vocabularyLog = (try? JSONDecoder().decode([Term].self, from: vocabularyLogAsData)) ?? [Term]()

        HStack {
            Text("Vocabulary Log")
                .font(Font.custom("SF Compact Rounded", size: 33))
                .fontWeight(.bold)
                .foregroundColor(Color.yellow)
                .padding(.init(top: 15, leading: 20, bottom: -0.5, trailing: 0))
            Spacer()
        }
        .toolbar(content: {
            Spacer()
            Button(action: {
                isImporting = true
            }, label: {
                Label("Import", systemImage: "square.and.arrow.down")
                    .foregroundColor(Color.yellow)
            })
            Button(action: {
                // note: Apparently, setting a preferred definition doesn't immediately make vocabularyLog reflect that here (even though it does for termitem). So get it directly from storage.
                let storageLog = try? JSONDecoder().decode([Term].self, from: vocabularyLogAsData)
                writeLogToDownloads(log: storageLog ?? vocabularyLog)
            }, label: {
                Label("Export Log", systemImage: "square.and.arrow.up")
                    .foregroundColor(vocabularyLog.count == 0 ? Color.gray : Color.yellow)
            }).disabled(vocabularyLog.count == 0)
            Button(action: {
                showingAlert = true
                forceClickActivated.toggle()
            }, label: {
                Label("Add Term on Force Click", systemImage: "cursorarrow.motionlines.click")
                    .foregroundColor(forceClickActivated ? Color.yellow : Color.gray)
            })
                .alert(isPresented:
                        Binding(get: {!self.alertHasShownBefore && showingAlert}, set: {newValue in self.showingAlert = newValue}),
                    content: {
                        Alert(title: Text("Add Term on Force Click"), message: Text("Force clicking on a word in Safari will now add the term to your log."), dismissButton: .default(Text("Got it!"), action: {
                            alertHasShownBefore = true
                        }))
                    }
                )
            addWordButton
        })
        .sheet(isPresented: $showingDetail) {
            AddWordSheet(showingDetail: $showingDetail)
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else {
                    print("couldn't get url")
                    return
                }
                let importedData = try Data(contentsOf: selectedFile)
                let importedLog = try? JSONDecoder().decode([Term].self, from: importedData)
                vocabularyLog += importedLog!
                var alreadyThere = Set<Term>()
                let uniqueTerms = vocabularyLog.compactMap { term -> Term? in
                    guard !alreadyThere.contains(term) else { return nil }
                    alreadyThere.insert(term)
                    return term
                }
                vocabularyLog = uniqueTerms
                updateLogInAppStorage(log: vocabularyLog)
                print(vocabularyLog)

            } catch {
                print("failure")
            }
        }
        
        if vocabularyLog.count > 0 {
            List {
                ForEach(Array((vocabularyLog).enumerated()), id: \.1.id) { (index, term) in
                    TermItem(term: term, index: index)
                        .padding(.vertical, 5)
                }
                .onDelete(perform: { indexSet in
                    vocabularyLog.remove(atOffsets: indexSet)
                    updateLogInAppStorage(log: vocabularyLog)
                })
            }
            .frame(minWidth: 450, minHeight: 425, maxHeight: .infinity)
        } else {
            Text("No Terms Logged")
                .font(.largeTitle)
                .foregroundColor(Color.gray.opacity(0.5))
                .frame(minWidth: 450, minHeight: 425, maxHeight: .infinity)
        }

    }

    var addWordButton: some View {
        Button(action: {
            showingDetail.toggle()
        }, label: {
            Label("Manually Add Term", systemImage: "plus")
                .foregroundColor(Color.gray)
        })
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func updateLogInAppStorage(log: [Term]) {
    let encoder = JSONEncoder()
    if let updatedLog = try? encoder.encode(log) {
        defaults.set(updatedLog, forKey: "terms")
    }
}

func getDownloadsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
    return paths[0]
}

func writeLogToDownloads(log: [Term]) {
    let url = getDownloadsDirectory().appendingPathComponent("Vocabulary Log Archive \(getTodayString()).json")
    if let logJSON = try? JSONEncoder().encode(log) {
        do {
            try logJSON.write(to: url)
        } catch {
            print(error.localizedDescription)
        }
    } else {
        print("encoding failure")
    }
}

func getTodayString() -> String{

    let date = Date()
    let calender = Calendar.current
    let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)

    let year = components.year
    let month = components.month
    let day = components.day
    let hour = components.hour
    let minute = components.minute
    let second = components.second

    let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " at " + String(hour!)  + "." + String(minute!) + "." +  String(second!)

    return today_string
}
