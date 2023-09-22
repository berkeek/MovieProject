//
//  MovieManager.swift
//  ProjeMovie
//
//  Created by Berke Kartal on 19.09.2023.
//

import Foundation

protocol MovieManagerDelegate {
    func updateMovies(_ movieManager : MovieManager, _ movies : MovieData)
}

struct MovieManager {
    
    let api_key = Keys().api_key

    var moviesURL : String{
        "https://api.themoviedb.org/3/movie/top_rated?api_key=\(api_key)&language=en-us&page="
    }
    
    
    var delegate : MovieManagerDelegate?
    
    var pageNum = 1
    
    func fetchMovies() {
        let urlString = "\(moviesURL)\(pageNum)"
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                
                if error != nil {
                    return
                }
                
                if let safeData = data {
                    if let decodedMovies = self.parse(safeData) {
                        self.delegate?.updateMovies(self, decodedMovies)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parse(_ data : Data) -> MovieData?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(MovieData.self, from: data)
            return decodedData
        } catch {
            print(error)
        }
        return nil
    }
    
    
}

struct MovieData : Codable {
    let page : Int
    let results : [MovieModel]
}

struct MovieModel : Codable , Identifiable , Hashable {
    let id : Int
    let title : String
    let poster_path : String
    let vote_average : Double
    let popularity : Double
    let overview : String
}

