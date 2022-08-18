//
//  NetworkRequest.swift
//  Bookie
//
//  Created by Michael Sebsbe on 7/5/22.
//

import Foundation
import UIKit

struct NetworkRequest {
    
    static func fetchBook(for searchString: String) async throws -> [BookSearch] {
        var bookSearch =  [BookSearch]()
        
        let url = createISBNSearchURL(from: searchString)
        
        let (data, reponse) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = reponse as? HTTPURLResponse,
           httpResponse.statusCode == 200{
            
            let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
            
            if searchResponse.docs.isEmpty {
                bookSearch = []
                
            } else if searchResponse.docs.count < 10 {
                for doc in searchResponse.docs {
                
                    let bookFromSearch = BookSearch(title: doc.title, author: doc.author_name?.joined(separator: ", "), isbn: doc.isbn?.last)
                    bookSearch.append(bookFromSearch)
                }
            } else {
                // only get 10 the first ten results
                for i in 0...9 {
                    
                    let bookFromSearch = BookSearch(title: searchResponse.docs[i].title, author: searchResponse.docs[i].author_name?.joined(separator: ", "), isbn: searchResponse.docs[i].isbn?.last)
                    bookSearch.append(bookFromSearch)
                }
            }
            
        } else {
            print("Error fetching URL data")
        }
        
        return bookSearch
    }
    
    
    static func fetchImage(for iSBN: String) async throws -> UIImage? {
        var image: UIImage?
        guard let url = createImageURL(iSBN: iSBN) else {return UIImage(systemName: "book")}

        let (data, reponse) = try await URLSession.shared.data(from: url)
            
        if let httpResponse = reponse as? HTTPURLResponse,
               httpResponse.statusCode == 200{
            image = UIImage(data: data)?.resizableImage(withCapInsets: .zero, resizingMode: .stretch)
        } else {
            print("Error Fetching for Image")
        }
        
        return image
    }
    
    
    //HELPER Fucntions
    static private func createImageURL(iSBN: String) -> URL? {
        return URL(string: "https://covers.openlibrary.org/b/isbn/\(iSBN)-M.jpg")
    }
    
    static private func createISBNSearchURL(from searchString: String) -> URL {
        let searchString = String(searchString.map { $0 == " " ? "+" : $0})
        
        return URL(string: "https://openlibrary.org/search.json?title=\(searchString)")!
    }
    
}
