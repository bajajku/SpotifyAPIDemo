import SwiftUI

struct ContentView: View {
    @State private var searchQuery = ""
    @State private var tracks: [Track] = []
    @State private var errorMessage: String?
    @State private var selectedTrack: Track?

    private var api = SpotifyAPI()

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search tracks...", text: $searchQuery, onCommit: search)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                Button("Search"){
                    search()
                }

                List(tracks) { track in
                    Button(action: {
                        selectedTrack = track
                    }) {
                        HStack {
                            Text(track.name)
                            Spacer()
                            Text(track.artists.map { $0.name }.joined(separator: ", "))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                }
                
                NavigationLink(
                    destination: selectedTrack.map { TrackDetailView(track: $0) },
                    isActive: Binding<Bool>(
                        get: { selectedTrack != nil },
                        set: { isActive in
                            if !isActive { selectedTrack = nil }
                        }
                    )
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Spotify Search")
            .onAppear {
                api.auth.authenticate { result in
                    if case .failure(let error) = result {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
    }

    private func search() {
        api.searchTracks(query: searchQuery) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self.tracks = tracks
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
