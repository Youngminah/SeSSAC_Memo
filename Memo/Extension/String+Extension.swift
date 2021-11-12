//
//  String+Extension.swift
//  Memo
//
//  Created by meng on 2021/11/12.
//

import Foundation

extension String {

    //3자리씩 콤마 찍기
    var insertComma: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let _ = self.range(of: ".") {
            let numberArray = self.components(separatedBy: ".")
            if numberArray.count == 1 {
                var numberString = numberArray[0]
                if numberString.isEmpty {
                    numberString = "0"
                }
                guard let doubleValue = Double(numberString)
                    else { return self }
                return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? self
            } else if numberArray.count == 2 {
                var numberString = numberArray[0]
                if numberString.isEmpty {
                    numberString = "0"
                }
                guard let doubleValue = Double(numberString)
                    else {
                        return self
                }
                return (numberFormatter.string(from: NSNumber(value: doubleValue)) ?? numberString) + ".\(numberArray[1])"
            }
        }
        else {
            guard let doubleValue = Double(self)
                else {
                    return self
            }
            return numberFormatter.string(from: NSNumber(value: doubleValue)) ?? self
        }
        return self
    }
    
    //제목과 내용 분리하기
    var pasringContectText: [String] {
        var array = self.components(separatedBy: "\n")
        if array.count < 2 {
            return array
        }
        var titleContentArray: [String] = []
        titleContentArray.append(array[0])
        array.remove(at: 0)
        var contentString = ""
        array.forEach {
            contentString += ($0 + "\n")
        }
        titleContentArray.append(contentString)
        return titleContentArray
    }
}
