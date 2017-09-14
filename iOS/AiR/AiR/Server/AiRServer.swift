//
//  AiRServer.swift
//  AiR
//
//  Created by Brendon Warwick on 13/09/2017.
//  Copyright © 2017 lemoncello. All rights reserved.
//
import Foundation
import UIKit

class Server {
    static let shared = Server()
    let domain = "https://air.xsanda.me/api/v1"
    
    func compatiableDate(_ date: Date!) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    /// Creates a flight on the server and returns a success flag and a payload, which will contain the flight id if successful or an error message otherwise.
    func CreateFlight(flightNumber: String!, flightTime: Date!, completion: @escaping (_ success: Bool, _ payload: String) -> Void){
        print(flightNumber)
        let endpoint = "/register"
        var request = URLRequest(url: URL(string: "\(domain)\(endpoint)")!)
        request.httpMethod = "POST"
        let postString = "date=\(compatiableDate(flightTime))&flightNumber=\(flightNumber!)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completion(false, "Please check your connection and try again.")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                switch httpStatus.statusCode {
                case 200:
                    let responseString = String(data: data!, encoding: .utf8)
                    completion(true, responseString!)
                case 400:
                    do {
                        let responseDict = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                        completion(false, responseDict["string"] as! String)
                    } catch {
                        completion(false, "Error whilst parsing JSON.")
                    }
                default:
                    completion(false, "Error: \(httpStatus.statusCode)")
                }
            }
        }
        task.resume()
    }
    
    ///Fetch all of the associated data for a given flight
    func FetchData(id: String, completion: @escaping (_ data: Any?, _ error: String?) -> Void){
        let endpoint = "/fetch/\(id)"
        var request = URLRequest(url: URL(string: domain + endpoint)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, error!.localizedDescription)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                switch httpStatus.statusCode {
                case 403:
                    completion(nil, "Error with flight ID.")
                case 503:
                    do {
                        let response = try JSONSerialization.jsonObject(with: data!) as! [String : Any]
                        let progress = response["progress"] as! Float
                        completion(nil, "Data is not ready yet. It is \(progress * 100)% completed")
                    } catch {
                        completion(nil, "Error whilst parsing JSON")
                    }
                case 200:
                    do {
                        let response = try JSONSerialization.jsonObject(with: data!) as! [[String : Any]]
                        completion(response, nil)
                    } catch {
                        completion(nil, "Error whilst parsing JSON")
                    }
                default:
                    completion(nil, "\(httpStatus.statusCode) error. ")
                }
            } else {
                completion(nil, "Error with HTTP Response")
            }
        }.resume()
    }
    
    ///Request that the data for a given flight is recalculated
    func RequestReload(id: String, completion: @escaping (_ success: Bool, _ error: String?) -> Void ){
        let endpoint = "/reload/\(id)"
        var request = URLRequest(url: URL(string: domain + endpoint)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(false, error!.localizedDescription)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                switch httpStatus.statusCode {
                case 202:
                    completion(true, nil)
                case 403:
                    completion(false, "Bad request: id is not valid.")
                default:
                    completion(false, "Error \(httpStatus.statusCode)")
                }
            } else {
                completion(false, "Error whilst parsing HTTP Response")
            }
        }.resume()
    }
    
    ///Fetch rerequested data for a given flight
    func RefetchData(id: String, completion: @escaping (_ response: Any?, _ error: String?) -> Void){
        let endpoint = "/refetch/\(id)"
        var request = URLRequest(url: URL(string: domain + endpoint)!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                completion(nil, error!.localizedDescription)
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse {
                switch httpStatus.statusCode {
                case 403:
                    completion(nil, "Error with flight ID.")
                case 503:
                    do {
                        let response = try JSONSerialization.jsonObject(with: data!) as! [String : Any]
                        let progress = response["progress"] as! Float
                        completion(nil, "Data is not ready yet. It is \(progress * 100)% completed")
                    } catch {
                        completion(nil, "Error whilst parsing JSON")
                    }
                case 200:
                    do {
                        let response = try JSONSerialization.jsonObject(with: data!) as! [String : Any]
                        completion(response, nil)
                    } catch {
                        completion(nil, "Error whilst parsing JSON")
                    }
                default:
                    completion(nil, "\(httpStatus.statusCode) error. ")
                }
            } else {
                completion(nil, "Error with HTTP Response")
            }
        }.resume()
    }
    
    func downloadImage(url: String, completion: @escaping (_ image: UIImage?, _ error: String?) -> Void){
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard error == nil else {
                completion(nil, "Could not connect to server")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    guard data != nil else {
                        completion(nil, "No Data to retrieve")
                        return
                    }
                    completion(UIImage(data: data!), nil)
                default:
                    completion(nil, "Error: \(httpResponse.statusCode)")
                }
            } else {
                completion(nil, "Error whilst parsing response")
            }
        }
    }
}
