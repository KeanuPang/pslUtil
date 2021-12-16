//
//  pslUtilTests.swift
//
//
//  Created by Keanu Pang on 2021/12/14.
//

@testable import pslUtil
import XCTest

final class pslUtilTests: XCTestCase {
    private func getPreloadTask() -> XCTestExpectation {
        return expectation(description: "Preload.preload")
    }

    func testPreloadFromList() {
        let expectation = getPreloadTask()

        Preload.preload(callback: { result in
            expectation.fulfill()

            switch result {
                case .success(let data):
                    XCTAssertNotNil(data, "preload list should not be nil")
                case .failure(let error):
                    XCTFail("preload list has error: \(error)")
            }
        })

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("preload expectation failed: \(error)")
            }
        }
    }

    func testParseValidDomains() {
        let expectation = getPreloadTask()

        pslUtil.preload(callback: { _ in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("preload expectation failed: \(error)")
                return
            }

            self.getValidTestList().forEach {
                XCTAssertTrue(pslUtil.isValid($0), "invalid domain: \($0)")
            }
        }
    }

    func testParseInvalidDomains() {
        let expectation = getPreloadTask()

        pslUtil.preload(callback: { _ in
            expectation.fulfill()
        })

        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("preload expectation failed: \(error)")
                return
            }

            self.getInvalidTestList().forEach {
                XCTAssertFalse(pslUtil.isValid($0), "valid domain: \($0)")
            }
        }
    }

    private func getValidTestList() -> [String] {
        return [
            "example.COM",
            "WwW.example.COM",
            "example.com",
            "a.example.com",
            "a.b.example.com",
            "domain.biz",
            "a.domain.biz",
            "a.b.domain.biz",
            "domain.biz",
            "a.domain.biz",
            "a.b.domain.biz",
            "example.uk.com",
            "a.example.uk.com",
            "a.b.example.uk.com",
            "test.ac",
            "b.c.mm",
            "a.b.c.mm",
            "test.jp",
            "www.test.jp",
            "test.ac.jp",
            "www.test.ac.jp",
            "test.kyoto.jp",
            "b.ide.kyoto.jp",
            "a.b.ide.kyoto.jp",
            "b.c.kobe.jp",
            "a.b.c.kobe.jp",
            "city.kobe.jp",
            "www.city.kobe.jp",
            "b.test.ck",
            "a.b.test.ck",
            "www.ck",
            "www.www.ck",
            "test.us",
            "www.test.us",
            "test.ak.us",
            "www.test.ak.us",
            "test.k12.ak.us",
            "www.test.k12.ak.us",
            "食狮.com.cn",
            "食狮.公司.cn",
            "www.食狮.公司.cn",
            "shishi.公司.cn",
            "食狮.中国",
            "www.食狮.中国",
            "shishi.中国",
            "xn--85x722f.com.cn",
            "xn--85x722f.xn--55qx5d.cn",
            "www.xn--85x722f.xn--55qx5d.cn",
            "shishi.xn--55qx5d.cn",
            "xn--85x722f.xn--fiqs8s",
            "www.xn--85x722f.xn--fiqs8s",
            "shishi.xn--fiqs8s",
        ]
    }

    private func getInvalidTestList() -> [String] {
        return [
            "COM",
            ".com",
            ".example",
            ".example.com",
            ".example.example",
            "example",
            "biz",
            "uk.com",
            "mm",
            "c.mm",
            "jp",
            "ac.jp",
            "kyoto.jp",
            "ide.kyoto.jp",
            "c.kobe.jp",
            "ck",
            "test.ck",
            "us",
            "ak.us",
            "k12.ak.us",
            "公司.cn",
            "中国",
            "xn--55qx5d.cn",
            "xn--fiqs8s",
        ]
    }
}
