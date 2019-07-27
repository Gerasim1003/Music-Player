//
//  QueryService.swift
//  Music Player
//
//  Created by Gerasim Israyelyan on 7/23/19.
//  Copyright © 2019 Gerasim Israyelyan. All rights reserved.
//

import UIKit

class QueryService {
    var tracks: [Track] = []

    func getSearchResults(searchTerm: String, completion: @escaping ([Track]?) -> ()) {
        let baseUrl = URL(string: "https://itunes.apple.com/search")
        let queries: [String: String] = [
            "media": "music",
            "entity": "song",
            "term": searchTerm
        ]
        
        let url = (baseUrl?.withQueries(queries))!
        
        let dataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                
                self.updateSearchResults(data)
                
                DispatchQueue.main.async {
                    completion(self.tracks)
                }
            }
        }
        
        dataTask.resume()
    }
    
    func updateSearchResults(_ data: Data) {
        tracks.removeAll()
        
        guard let response: [String: Any] = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return
        }
        
        guard let array = response["results"] as? [Any] else {
            return
        }
        
        var index = 0
        for trackDictionary in array {
            if let trackDictionary = trackDictionary as? [String: Any],
                let previewURLString = trackDictionary["previewUrl"] as? String,
                let imageURLString = trackDictionary["artworkUrl100"] as? String,
                let previewURL = URL(string: previewURLString),
                let imageURL = URL(string: imageURLString),
                let name = trackDictionary["trackName"] as? String,
                let artist = trackDictionary["artistName"] as? String {
                let data = try? Data(contentsOf: imageURL)
                let image = UIImage(data: data!)
                tracks.append(Track(name: name, artist: artist, previewURL: previewURL, image: image, index: index))
                index += 1
            }
        }
       
    }
}

extension URL {
    func withQueries(_ query: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = query.map {
            URLQueryItem(name: $0.0, value: $0.1)
        }
        
        return components?.url
    }
}
