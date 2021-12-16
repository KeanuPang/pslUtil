//
//  Preload.swift
//
//
//  Created by Keanu Pang on 2021/12/14.
//

import Foundation
import punycode

struct DomainRule {
    let suffix: String
    let isSuffix: Bool

    var tld: String {
        suffix.components(separatedBy: ".").last ?? ""
    }

    var wildcard: Int {
        guard suffix.contains("*") == true else { return 0 }

        return suffix.split(separator: ".").count
    }
}

enum Preload: String {
    case list = "https://publicsuffix.org/list/public_suffix_list.dat"

    static func preload(callback: @escaping (Result<[String: DomainRule], Error>) -> Void) {
        guard let url = URL(string: Preload.list.rawValue) else { return }

        URLSession(configuration: .default).dataTask(with: url) { data, _, error in
            if let error = error {
                callback(.failure(error))
                return
            }

            if let data = data {
                let listData = Preload.parseListData(String(decoding: data, as: UTF8.self))
                callback(.success(listData))
                return
            }
        }.resume()
    }

    static func parseListData(_ data: String) -> [String: DomainRule] {
        var resultRules = [String: DomainRule]()

        guard data.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else { return resultRules }

        data.components(separatedBy: .newlines).forEach {
            guard var suffix = $0.trimmingCharacters(in: .whitespacesAndNewlines).idnaEncoded()?.lowercased() else { return }

            guard suffix.isEmpty == false else { return }
            guard suffix.starts(with: "// ") == false else { return }

            let isException = suffix.starts(with: "!")
            if isException {
                suffix = String(suffix.suffix(suffix.count - 1))
            }

            resultRules[suffix] = DomainRule(suffix: suffix, isSuffix: isException == false)
        }

        return resultRules
    }
}
