import SafariServices

let defaults = UserDefaults.init(suiteName: "L27L4K8SQU.VocabularyLog")!

class SafariExtensionHandler: SFSafariExtensionHandler {

    override func contextMenuItemSelected(withCommand command: String, in page: SFSafariPage, userInfo: [String : Any]? = nil) {

        // Turn the userInfo from page into a Term object.
        let word = userInfo!["term"] as! String
        let exampleSentence = userInfo!["exampleSentence"] as! String
        let url = userInfo!["url"] as! String
        let term = Term(word: word, exampleSentence: exampleSentence, url: url)
        var vocabularyLog: [Term]

        if defaults.object(forKey: "terms") != nil {
            let decoder = JSONDecoder()
            vocabularyLog = (try? decoder.decode([Term].self, from: defaults.object(forKey: "terms") as! Data)) ?? [Term]()
        } else {
            vocabularyLog = [Term]()
        }
        // Append the new Term to the dictionary.
        vocabularyLog.append(term)

        // Reencode and save the dictionary
        let encoder = JSONEncoder()
        if let appendedDictionary = try? encoder.encode(vocabularyLog) {
            defaults.set(appendedDictionary, forKey: "terms")
        }

    }

}
