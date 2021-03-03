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
    func define(word: String, completion: @escaping (Result<[Response]?,NetworkError>)->() ) {
        guard let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en_US/\(word)") else {
            completion(.failure(.badURL))
            return
        }
        let session = URLSession.shared
        let task = session.dataTask(with: url) { (data, _, error) in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([Response].self, from: data) {
                    DispatchQueue.main.async {
                        //resultObject?.first?.meanings.first?.definitions
                        if decodedResponse.first?.meanings.first?.definitions.count ?? 0 > 0 {
                            completion(.success(decodedResponse))
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
