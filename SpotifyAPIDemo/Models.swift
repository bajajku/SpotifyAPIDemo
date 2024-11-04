import Foundation

struct SearchResponse: Decodable {
    let tracks: TrackResults
}

struct TrackResults: Decodable {
    let items: [Track]
}

struct Track: Decodable, Identifiable {
    let id: String
    let name: String
    let artists: [Artist]
    let album: Album
    let popularity: Int?
    let preview_url: String?
}

struct Album: Decodable {
    let name: String
    let releaseDate: String?
    let images: [AlbumImage]?
}

struct AlbumImage: Decodable {
    let url: String
    let height: Int?
    let width: Int?
}

struct Artist: Decodable {
    let name: String
}
