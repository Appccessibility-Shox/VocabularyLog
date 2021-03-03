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

enum NetworkError: Error {
    case badURL, requestFailed, decodingError, unknown
}

class Api: ObservableObject {
    func define(word: String, completion: @escaping (Result<[Definition],NetworkError>)->() ) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en_US/\(word)") else {
            completion(.failure(.badURL))
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, error) in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Response].self, from: data) {
                    DispatchQueue.main.async {
                        var definitions = [Definition]()
                        for interpretation in decodedResponse {
                            for meaning in interpretation.meanings {
                                definitions.append(contentsOf: meaning.definitions)
                            }
                        }
                        if definitions.count > 0 {
                            completion(.success(definitions))
                        } else {
                            completion(.failure(.decodingError))
                        }
                    }
                } else {
                    completion(.failure(.decodingError))
                }
            } else if error != nil {
                completion(.failure(.requestFailed))
            } else {
                completion(.failure(.unknown))
            }
        }
        task.resume()
    }
}
