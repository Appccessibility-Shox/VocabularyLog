import Foundation

struct Response: Decodable {
    var word: String!
    var meanings: [Meaning]
}

struct Meaning: Decodable {
    var partOfSpeech: String
    var definitions: [Definition]
}

struct Definition: Decodable {
    var definition: String
}

class Api: ObservableObject {
    func define(word: String, completion: @escaping ([Response]?)->() ) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en_US/\(word)") else {
            print("invalid url")
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, error) in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Response].self, from: data) {
                    DispatchQueue.main.async {
                        completion(decodedResponse)
                    }
                    return
                }
            }
            print("nil \(String(describing: error?.localizedDescription))")
            completion(nil)
        }
        task.resume()
    }
}
