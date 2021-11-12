//
//  Date+Extension.swift
//  Memo
//
//  Created by meng on 2021/11/12.
//

import Foundation
import SwiftUI

extension Date {
    static func from(date: Date) -> String {
        let formatter = DateFormatter()
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_kr")
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.timeZone = TimeZone(abbreviation: "KST")
        //형태 변환
        var result = String()
        let isToday = calendar.isDateInToday(date)
        let isInWeek = date.isInThisWeek
        if isToday {
            formatter.dateFormat = "\na hh:mm"
            formatter.amSymbol = "오전"
            formatter.pmSymbol = "오후"
            result = formatter.string(from: date)
        } else if isInWeek {
            let weekday = Calendar.current.component(.weekday, from: date)
            //print(weekday)
            result = Weekday(rawValue: weekday)!.description
        } else {
            formatter.dateFormat = "yyyy년 MM월 dd일\na hh:mm"
            formatter.amSymbol = "오전"
            formatter.pmSymbol = "오후"
            result = formatter.string(from: date)
        }
        return result
    }
    
    var isInThisWeek: Bool {
        guard let thisWeek = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else { return false }
        if self.compare(thisWeek) == .orderedDescending {
            return true
        }
        return false
    }
}

enum Weekday: Int {
    
    case 월요일 = 0, 화요일 = 1, 수요일, 목요일, 금요일, 토요일, 일요일
    
    var description: String {
        switch self {
        case .월요일:
            return "월요일"
        case .화요일:
            return "화요일"
        case .수요일:
            return "수요일"
        case .목요일:
            return "목요일"
        case .금요일:
            return "금요일"
        case .토요일:
            return "토요일"
        case .일요일:
            return "일요일"
        }
    }
}
