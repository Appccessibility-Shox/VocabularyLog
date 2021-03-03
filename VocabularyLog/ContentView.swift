import SwiftUI

let defaults = UserDefaults.init(suiteName: "L27L4K8SQU.VocabularyLog")!


extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()

    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}

struct ContentView: View {

    @AppStorage("terms", store: defaults) var vocabularyLogAsData = try! JSONEncoder().encode([Term]())
    @State var showingDetail = false

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
        .sheet(isPresented: $showingDetail) {
            AddWordSheet(showingDetail: $showingDetail)
        }
        
        List {
            ForEach(Array((vocabularyLog).enumerated()), id: \.1.id) { (index, term) in
                TermItem(term: term, index: index)
            }
            .onDelete(perform: { indexSet in
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
            Button(action: {
                showingDetail.toggle()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(Color.init("BW"))
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
