//
//  extension.swift
//  CountdownSalary
//
//  Created by yook on 2023/09/23.
//

import Foundation
import SwiftUI
 
extension UIApplication {
    func hideKeyboard() {
        guard let window = windows.first else { return }
        let tapRecognizer = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapRecognizer.cancelsTouchesInView = false
        tapRecognizer.delegate = self
        window.addGestureRecognizer(tapRecognizer)
    }
 }
 
extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// 숫자로 변환 가능하며, 0이 아니며, 0의 반복이 아닌지 확인하는 함수
func isNumber(_ text: String) -> Bool {
    if let number = Int(text) {
        return number != 0 && !text.allSatisfy({ $0 == "0" })
    }
    return false
}
