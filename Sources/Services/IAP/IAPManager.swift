//
//  IAPManager.swift
//  ALog
//
//  Created by Xin Du on 2023/07/27.
//

import Foundation
import StoreKit
import XLog

class IAPManager: NSObject, ObservableObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    enum State {
        case loading
        case loaded(SKProduct)
        case failed(Error?)
        case purchasing
        case purchased
        case deferred
    }
    
    enum IAPError: Error {
        case missingProduct, invalidIdentifiers
    }
    
    @Published var state = State.loading {
        didSet {
            XLog.debug("Request state → \(state)", source: "IAP")
        }
    }
    
    private let request: SKProductsRequest
    private var products = [SKProduct]()
    
    override init() {
        let IDs = Set([Constants.IAP.premiumProductId])
        request = SKProductsRequest(productIdentifiers: IDs)
        super.init()
        
        if AppState.shared.isPremium {
            return
        }
        
        SKPaymentQueue.default().add(self)
        request.delegate = self
        request.start()
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        DispatchQueue.main.async {
            for transaction in transactions {
                switch transaction.transactionState {
                case .purchased, .restored:
                    AppState.shared.isPremium = true
                    self.state = .purchased
                    queue.finishTransaction(transaction)
                case .failed:
                    if let product = self.products.first {
                        self.state = .loaded(product)
                    } else {
                        self.state = .failed(transaction.error)
                    }
                    queue.finishTransaction(transaction)
                case .deferred:
                    self.state = .deferred
                case .purchasing:
                    self.state = .purchasing
                @unknown default:
                    break
                }
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
            
            guard let pro = self.products.first else {
                self.state = .failed(IAPError.missingProduct)
                return
            }
            
            if !response.invalidProductIdentifiers.isEmpty {
                XLog.error("Invalid product identifiers: \(response.invalidProductIdentifiers)", source: "IAP")
                self.state = .failed(IAPError.invalidIdentifiers)
                return
            }
            
            self.state = .loaded(pro)
        }
    }
    
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
}
