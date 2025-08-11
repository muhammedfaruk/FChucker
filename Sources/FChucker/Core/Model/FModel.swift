//
//  FModel.swift
//  FChucker
//
//  Created by Muhammed Faruk Söğüt on 10.08.2025.
//
import Foundation

final class FModel: Equatable {
    var id = UUID()
    var method: String?
    var url: String?
    var timestamp: Date?
    var requestBodyData: Data?
    var statusCode: Int?
    var responseData: Data?
    var headers: [String:Any]?

    func saveRequest(request: URLRequest) {
        self.method = request.httpMethod ?? ""
        self.url = request.url?.absoluteString ?? ""
        self.timestamp = Date()
        self.requestBodyData = request.readBodyStream()
        self.headers = request.getHeaders()
    }
    
    func saveResponse(responseData: Data, response: URLResponse) {
        self.statusCode = response.getStatusCode()
        self.responseData = responseData
    }
    
    // Equatable conformance
    static func == (lhs: FModel, rhs: FModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func generateCurlCommand() -> String? {
        guard let method = self.method, let url = self.url else {
            return nil
        }
        
        var curlCommand = "curl -X \(method) \"\(url)\""
        
        
        if let headers = self.headers {
            for (key, value) in headers {
                if let valueString = value as? String {
                    curlCommand += " -H \"\(key): \(valueString)\""
                }
            }
        }
        
        
        if let requestBodyData = self.requestBodyData, let bodyString = String(data: requestBodyData, encoding: .utf8) {
            curlCommand += " -d \"\(bodyString)\""
        }
        
        return curlCommand
    }
}
