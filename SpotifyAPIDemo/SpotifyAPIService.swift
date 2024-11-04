import Foundation

class SpotifyAPI {
    private let baseURL = "https://api.spotify.com/v1"
    public var auth = SpotifyAuth()

    private func makeRequest(endpoint: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let accessToken = auth.accessToken else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "No access token"])))
            return
        }

        guard let url = URL(string: "\(baseURL)\(endpoint)") else { return }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "DataError", code: -1, userInfo: nil)))
                return
            }
            completion(.success(data))
        }.resume()
    }

    func searchTracks(query: String, completion: @escaping (Result<[Track], Error>) -> Void) {
        let endpoint = "/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=track&limit=10"
        
        makeRequest(endpoint: endpoint) { result in
            switch result {
            case .success(let data):
                do {
                    let json = try JSONDecoder().decode(SearchResponse.self, from: data)
                    let tracks = json.tracks.items
                    completion(.success(tracks))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
