//
//  pslUtil.swift
//
//
//  Created by Keanu Pang on 2021/12/14.
//

import punycode

struct ParseResult {
    let tld: String
    let domain: String
    let subDomain: String
}

public enum pslUtil {
    private static var preload = [String: DomainRule]()

    public static func preload(callback: @escaping (Bool) -> Void) {
        Preload.preload(callback: { result in
            switch result {
                case .success(let data):
                    preload = data
                    callback(true)
                case .failure:
                    preload = [String: DomainRule]()
                    callback(false)
            }
        })
    }

    public static func reload() {
        preload(callback: { _ in })
    }

    public static func parse(_ domain: String) -> ParseResult? {
        guard preload.isEmpty == false else { return nil }
        guard domain.isEmpty == false, domain.hasPrefix(".") == false, domain.contains(".") == true else {
            return nil
        }
        guard let domain = domain.trimmingCharacters(in: .whitespacesAndNewlines).idnaEncoded()?.lowercased() else { return nil
        }

        let base = domain.components(separatedBy: ".")
        for (index, _) in base.enumerated() {
            let subSuffix = Array(base)[index...].joined(separator: ".")
            if let rule = preload[subSuffix] {
                if rule.isSuffix == true {
                    guard domain != rule.suffix else { return nil }

                    return ParseResult(tld: rule.tld, domain: rule.suffix, subDomain: base[0])
                } else {
                    guard subSuffix == rule.suffix else { return nil }

                    return ParseResult(tld: rule.tld, domain: rule.suffix, subDomain: base[0])
                }
            }

            if let maskRule = preload["*.\(subSuffix)"], maskRule.isSuffix == true {
                guard base.count > maskRule.wildcard else { return nil }

                return ParseResult(tld: maskRule.tld, domain: maskRule.suffix, subDomain: base[0])
            }
        }

        return nil
    }

    public static func get(_ domain: String) -> String? {
        return parse(domain)?.domain
    }

    public static func isValid(_ domain: String) -> Bool {
        return get(domain) != nil
    }
}
