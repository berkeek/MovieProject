//
//  ContentView.swift
//  ProjeMovie
//
//  Created by Berke Kartal on 18.09.2023.
//

import SwiftUI


let backgroundGradient = LinearGradient(colors: [.red, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)

struct MoviesListView: View {
    
    
    @State private var isList = false
    @State private var searchBarInput = ""
    @State private var movies = [MovieModel]()
    @State var movieManager = MovieManager()
    
    var searchedMovies : [MovieModel]{
        if searchBarInput.count < 3 {
            return movies
        }
        return movies.filter { movie in
            movie.title.localizedCaseInsensitiveContains(searchBarInput)
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack{
                showMovies()
                    .navigationDestination(for: MovieModel.self) {
                        showDetail($0)
                    }
                    .searchable(text: $searchBarInput,prompt: "Search Movies")
                    .toolbar {
                        ToolbarItem (placement: .navigationBarTrailing){
                            Button {
                                isList.toggle()
                            } label: {
                                Image(systemName: getIcon())
                                    .padding(.horizontal)
                            }
                        }
                    }
                Button {
                    if movieManager.delegate == nil {
                        movieManager.delegate = self
                    }
                    movieManager.fetchMovies()
                } label: {
                    Text("Load More")
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            }
        }
    }
    func getIcon() ->String {
        if isList {
            return "square.grid.2x2.fill"
        }
        return "rectangle.grid.1x2.fill"
    }
    
    func showDetail(_ movie: MovieModel) ->AnyView {
        return AnyView(
            ZStack{
                
                backgroundGradient
                    .opacity(0.6)
                    .ignoresSafeArea()
                
                VStack (alignment: .leading){
                    
                    HStack (spacing: 20){
                        
                        MoviePoster(movie: movie, width: 160, height: 240)
                        
                        VStack(alignment: .leading){
                            Spacer()
                            Text("Popularity : \(String(format: "%2.f", movie.popularity))")
                            Spacer()
                            Text("Average Vote : \(String(format: "%3.f", movie.vote_average))/10")
                            Spacer()
                        }
                    }
                    .frame(height : 240)
                    
                    Spacer()
                    
                    Text("Overview:")
                        .font(.title2)
                    Text(movie.overview)
                    
                    Spacer()
                }
                    .padding()
                    .navigationTitle(movie.title)
                    .navigationBarTitleDisplayMode(.inline)
                
                
            }
        )
    }
    
    func showMovies() ->AnyView {
        if !isList {
            let columns = [GridItem(.flexible(), alignment: .top),GridItem(.flexible(), alignment: .top)]
            return AnyView(ScrollView{
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(searchedMovies) { movie in
                        NavigationLink(value: movie) {
                            LazyVStack {
                                MoviePoster(movie: movie, width: 120, height: 180)
                                Text(movie.title)
                                    .padding()
                            }
                        }
                    }
                }
            })
        }
        return AnyView(List(searchedMovies) { movie in
            NavigationLink(value: movie) {
                HStack(spacing:20){
                    MoviePoster(movie: movie, width: 50, height: 75)
                        .foregroundColor(.blue)
                    Text(movie.title)
                }
            }
        })
    }
}

extension MoviesListView : MovieManagerDelegate {
    func updateMovies(_ movieManager : MovieManager, _ movieData: MovieData) {
        DispatchQueue.main.async {
            self.movies.append(movieData.results[movies.count%20])
            if movies.count % 20 == 0 {
                self.movieManager.pageNum += 1
            }
        }
        
    }
    
}

struct MoviePoster : View {
    
    let movie : MovieModel
    let width : CGFloat
    let height : CGFloat
    var body: some View {
        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(movie.poster_path)")) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFit()
            } else if phase.error != nil {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
            } else {
                ProgressView()
            }
        }
        .frame(width: width , height : height)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesListView()
    }
}

