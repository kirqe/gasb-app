//
//  BaseRequest.swift
//  gasb
//
//  Created by Kirill Beletskiy on 06/01/2021.
//  Copyright © 2021 kirqe. All rights reserved.
//

// https://stackoverflow.com/a/41082782/1231365

import Foundation


//APPError enum which shows all possible errors
enum APPError: Error {
    case networkError(Error)
    case dataNotFound
    case jsonParsingError(Error)
    case invalidStatusCode(Int)
}

//Result enum to show success or failure
enum Result<T> {
    case success(T)
    case failure(APPError)
}

//dataRequest which sends request to given URL and convert to Decodable Object
func dataRequest<T: Decodable>(with url: String, httpMethod: String, headers:Dictionary<String, String> = [:], httpBody: String = String(), objectType: T.Type, completion: @escaping (Result<T>) -> Void) {

    //create the url with NSURL
    let dataURL = URL(string: url)! //change the url

    //create the session object
    let session = URLSession.shared

    //now create the URLRequest object using the url object
    var request = URLRequest(url: dataURL, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 3)
    
    request.httpMethod = httpMethod
    
    if headers.count > 0 {
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    if httpMethod == "POST" {
        request.httpBody = httpBody.data(using: String.Encoding.utf8, allowLossyConversion: false)
    }
    
    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request, completionHandler: { data, response, error in

        guard error == nil else {
            completion(Result.failure(APPError.networkError(error!)))
            return
        }

        guard let data = data else {
            completion(Result.failure(APPError.dataNotFound))
            return
        }
        
        let decoder = JSONDecoder()
        do {
//            print("REQ: \(String(decoding: data, as: UTF8.self))")
            let decodedObject = try decoder.decode(objectType.self, from: data)
            completion(Result.success(decodedObject))
        } catch let error {
            completion(Result.failure(APPError.jsonParsingError(error as! DecodingError)))
        }
    })

    task.resume()
}
