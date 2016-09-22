//
//  AkiraDefaultAPI.swift
//  AkiraRxSwift
//
//  Created by Akira on 9/21/16.
//  Copyright © 2016 Akira Tech. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
    import RxCocoa
#endif
import Alamofire

class AkiraDefaultValidationService: AkiraValidationService {
    
    let API: AkiraAPI
    static let sharedValidationService = AkiraDefaultValidationService(API: AkiraDefaultAPI.sharedAPI)
    init (API: AkiraAPI) {
        self.API = API
    }
    // validation
    
    let minPasswordCount = 6
    
    func validateEmail(_ email: String) -> Observable<ValidationResult> {
        if email.characters.count == 0 {
            return .just(.empty)
        }
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        if !emailPredicate.evaluate(with: email) {
            return .just(.failed(message: "Email không đúng định dạng"))
        }
        return .just(.ok(message: ""))
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Mật khẩu tối thiểu 6 ký tự")
        }
        
        return .ok(message: "")
    }
}

class AkiraDefaultAPI: AkiraAPI {
    
    let URLSession: Foundation.URLSession
    var URL_API = "https://hoc.akira.edu.vn/v3/"
    static let sharedAPI = AkiraDefaultAPI(
        URLSession: Foundation.URLSession.shared
    )
    
    init(URLSession: Foundation.URLSession) {
        self.URLSession = URLSession
    }
    
    func signup(_ email: String, password: String) -> Observable<Bool> {
        // this is also just a mock
        let signupResult = arc4random() % 5 == 0 ? false : true
        return Observable.just(signupResult)
            .concat(Observable.never())
            .throttle(0.4, scheduler: MainScheduler.instance)
            .take(1)
    }
    
    func signin(_ email: String, password: String) -> Observable<Any> {
        return Observable.create({ (observer) -> Disposable in
            let parameters : Parameters = [
                "email" : email,
                "password" : password,
                "end_point" : 404,
                "type_of_device" : 4
            ]
            let request = Alamofire.request(self.URL_API + "signin", method: .post, parameters: parameters).responseJSON(completionHandler: { (response) in
                if let value = response.result.value {
                    observer.onNext(value)
                    observer.onCompleted()
                } else if let error = response.result.error {
                    observer.onError(error)
                }
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }
}
