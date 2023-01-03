//
//  PaymentManager.swift
//  ScreenLock
//
//  Created by sharui on 2023/1/3.
//

import Foundation
import StoreKit

class PaymentManager: NSObject{

    
    func buy() {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        
        let reqeust = SKProductsRequest.init(productIdentifiers: Set(["950012"]))
        reqeust.delegate = self
        reqeust.start()
    }
}


extension PaymentManager: SKProductsRequestDelegate {
    /// 获取列表
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let product = response.products.first else {
            return
        }
        let pament = SKMutablePayment(product: product)
        pament.applicationUsername = "测试"
        SKPaymentQueue.default().add(pament)
    }
}
