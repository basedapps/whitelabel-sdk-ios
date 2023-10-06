//
//  DataTask+Ext.swift
//  WhitelabelSDK
//
//  Created by Lika Vorobeva on 21.07.2023.
//

import Foundation
import Alamofire

extension DataTask {
    func handlingError() async throws -> Value {
        if let error = await response.error {
            if let httpResponse = await response.response {
                let error = GenericNetworkError(code: httpResponse.statusCode, message: error.localizedDescription)
                if error.commonError == .unauthorizedDevice {
                    APIStorage.shared.deviceToken = nil
                }
                throw error
            }

            if let urlError = error.underlyingError as? URLError {
                throw GenericNetworkError(code: urlError.errorCode, message: urlError.localizedDescription)
            }
        }

        if let dto = try? await value {
            return dto
        }

        let uknownDescription = CommonAPIError.unknownError.localizedDescription
        throw await GenericNetworkError(code: response.response?.statusCode ?? 400, message: uknownDescription)
    }
}
