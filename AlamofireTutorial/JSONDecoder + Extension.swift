//
//  JSONDecoder + Extension.swift
//  AlamofireTutorial
//
//  Created by Het Song on 11/04/2019.
//  Copyright © 2019 Het Song. All rights reserved.
//

import Alamofire

extension JSONDecoder {
    
    // Alamofire의 DataResponse를 Decode하는 전용 디코더
    func decodeAFResponse<T:Decodable>(from response: DataResponse<Data>) -> Result<T> {
        // 응답에러 처리
        if let error = response.error {
            return .failure(error)
        }
        // 빈 데이터 처리
        guard let data = response.data else {
            let error = NSError(domain: "No Contents", code: 204, userInfo: [:])
            return .failure(error)
        }
        // json 디코드 결과 처리
        do {
            let item = try decode(T.self, from: data)
            return .success(item)
        } catch {
            return .failure(error)
        }
    }
    
}
