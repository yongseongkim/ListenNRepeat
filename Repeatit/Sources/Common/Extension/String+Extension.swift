//
//  String+Extension.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/28.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Foundation

extension String {
    func substring(with range: NSRange) -> String {
        guard range.location != NSNotFound else { return "" }
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }

    func split(usingRegex pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return []}
        let matches = regex.matches(in: self, range: NSRange(0..<utf16.count))
        let ranges = [startIndex..<startIndex] + matches.map { Range($0.range, in: self)! } + [endIndex..<endIndex]
        return (0...matches.count).map {String(self[ranges[$0].upperBound..<ranges[$0+1].lowerBound])}
    }

    func parseYouTubeID() -> String? {
        if URL(string: self) == nil {
            return nil
        }
        let splits = split(usingRegex: "(vi\\/|v=|\\/v\\/|youtu\\.be\\/|\\/embed\\/)")
        if splits.count > 1 {
            let splits2 = splits[1].split(usingRegex: "[^0-9A-Za-z_\\-]")
            return splits2[0]
        } else {
            return splits[0]
        }
    }
}
