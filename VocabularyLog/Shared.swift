import Foundation

struct Term: Codable, Hashable {
    var word: String
    var exampleSentence: String
    var url: String?
    var preferredDef: String?
    var id = UUID()

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(left:Term, right:Term) -> Bool {
        return left.id == right.id
    }
}

let appGroupID = "L27L4K8SQU.VocabularyLog"
let defaults = UserDefaults.init(suiteName: appGroupID)!
