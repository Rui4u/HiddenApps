//
//  PaymentManager.swift
//  ScreenLock
//
//  Created by sharui on 2023/1/3.
//

import Foundation
import StoreKit

class PaymentManager: NSObject{
    @Published var message: String = "购买成功"
    @Published var showToast: Bool = false
    func buy() {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        message = "正在获取"
        showToast = true
        let reqeust = SKProductsRequest.init(productIdentifiers: Set(["111111"]))
        reqeust.delegate = self
        reqeust.start()
    }
}


extension PaymentManager: SKProductsRequestDelegate {
    /// 获取列表
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let product = response.products.first else {
            DispatchQueue.main.async {
                self.showToast = false
                self.message = "未获取到产品信息"
                self.showToast = true
            }
            return
        }
        let pament = SKMutablePayment(product: product)
        pament.applicationUsername = "测试"
        SKPaymentQueue.default().add(pament)
    }
}
