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


extension PaymentManager: SKProductsRequestDelegate, SKPaymentTransactionObserver{
    /// 获取列表
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard let product = response.products.first else {
            DispatchQueue.main.async {
                self.showToast = false
            }
            return
        }
        
        DispatchQueue.main.async {
            let pament = SKMutablePayment(product: product)
            pament.applicationUsername = "用户名称"
            SKPaymentQueue.default().add(pament)
            SKPaymentQueue.default().add(self)
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        DispatchQueue.main.async {
            self.showToast = false
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for item in transactions {
            switch item.transactionState {
                
            case .purchasing:
                print("购买中")
            case .purchased:
                print("交易完成")
            case .failed:
                print("交易失败")
            case .restored:
                print("恢复购买完成")
            case .deferred:
                print("交易推迟, 等待外部操作")
            @unknown default:
                print("其他")
            }
        }
    }
}
