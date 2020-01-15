//
//	ZScanner_iosTests.swift
//	ZScanner-iosTests
//
//	Created by Kaz Yoshikawa on 11/11/19.
//

import XCTest
@testable import ZScanner_ios

class ZScanner_iosTests: XCTestCase {
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func test1() {
		let scanner = ZScanner(string: "aaa   bbb   ccc")
		let aaa: String? = scanner.scan(characterSet: ZCharacterSet(charactersInString: "a"))
		_ = scanner.scan(characterSet: ZCharacterSet(charactersInString: " ")) as String?
		let bbb: String? = scanner.scan(characterSet: ZCharacterSet(charactersInString: "b"))
		_ = scanner.scan(characterSet: ZCharacterSet(charactersInString: " ")) as String?
		let ccc: String? = scanner.scan(characterSet: ZCharacterSet(charactersInString: "c"))
		XCTAssert(aaa == "aaa")
		XCTAssert(bbb == "bbb")
		XCTAssert(ccc == "ccc")
	}

	func test2() {
		let scanner = ZScanner(string: "\t12345 \n1a2b3c \r98765")
		scanner.scanWhitespaces()
		let a: UInt? = scanner.scanUnsignedInteger()
		scanner.scanWhitespaces()
		let b: UInt? = scanner.scanHexadecimalInteger()
		scanner.scanWhitespaces()
		let c: UInt? = scanner.scanUnsignedInteger()
		XCTAssert(a == 12345)
		XCTAssert(b == 0x1a2b3c)
		XCTAssert(c == 98765)
	}

	func test3() {
		let scanner = ZScanner(string: "hello world")
		XCTAssert(scanner.location == 0)
		let hello = scanner.scan(string: "hello")
		XCTAssert(scanner.location == 5)
		scanner.scanWhitespaces()
		let world = scanner.scan(string: "world")
		XCTAssert(hello == "hello")
		XCTAssert(world == "world")
	}

	func test4() {
		let scanner = ZScanner(string: "JST 15:00")
		if let offset = scanner.scan(dictionary: ["JST": 9, "EST": -5, "MST": -6, "PST": -8, "GMT": 0]) {
			scanner.scanWhitespaces()
			if let hour: Int = scanner.scanInteger(), let _ = scanner.scan(string: ":"), let minute: Int = scanner.scanInteger() {
				XCTAssert(offset == 9)
				XCTAssert(hour == 15)
				XCTAssert(minute == 0)
			}
			else { XCTAssert(false) }
		}
		else { XCTAssert(false) }
	}

	func testFloat1() {
		let a = Float("1e-06")
		let b = Float("0.000001")
		XCTAssert(a == b)
		let scanner = ZScanner(string: "1e-06 0.000001")
		let c: Float? = scanner.scanFloatinPoint()
		let d: Float? = scanner.scanFloatinPoint()
		XCTAssert(a == c)
		XCTAssert(b == d)
		XCTAssert(c == d)
	}

	func testFloat2() {
		let a = Float("1.25e+5")
		let b = Float("125000")
		XCTAssert(a == b)
		let scanner = ZScanner(string: "1.25e+5,125000")
		let c: Float? = scanner.scanFloatinPoint()
		scanner.scan(string: ",")
		let d: Float? = scanner.scanFloatinPoint()
		XCTAssert(a == c)
		XCTAssert(b == d)
		XCTAssert(c == d)
	}
	
	func testBool() {
		let scanner = ZScanner(string: "true false TRUE FALSE tRuE FaLsE")
		let a: Bool? = Bool(scanner)
		let b: Bool? = Bool(scanner)
		let c: Bool? = Bool(scanner)
		let d: Bool? = Bool(scanner)
		let e: Bool? = Bool(scanner)
		let f: Bool? = Bool(scanner)
		XCTAssert(a == true)
		XCTAssert(b == false)
		XCTAssert(c == true)
		XCTAssert(d == false)
		XCTAssert(e == true)
		XCTAssert(f == false)
	}

	func testString() {
		let scanner = ZScanner(string: "keyword")
		let a = scanner.scan(string: "key")
		let b = scanner.scan(string: "keyword")
		XCTAssertNil(a)
		XCTAssert(b == "keyword")
	}

	func testIdentifier() {
		let scanner = ZScanner(string: "not_found_404")
		let a = scanner.scanIdentifier()
		XCTAssert(a == "not_found_404")
	}

	func testTokens() {
		let scanner = ZScanner(string: """
			func doubling(value: Float) -> Float {
				return value * 2
			}
			""")
		let token1 = scanner.scan(token: "func")
		let fname1 = scanner.scanIdentifier()
		let _ = scanner.scan(token: "(")
		let variable1 = scanner.scanIdentifier()
		let _ = scanner.scan(string: ":")
		let type1 = scanner.scan(tokens: ["Float", "Int"])
		let _ = scanner.scan(token: ")")
		let _ = scanner.scan(token: "->")
		let type2 = scanner.scan(tokens: ["Float", "Int"])
		let _ = scanner.scan(token: "{")
		let return1 = scanner.scan(token: "return")
		let variable2 = scanner.scanIdentifier()
		let _ = scanner.scan(token: "*")
		let value2 = scanner.scanInteger() as Int?
		let _ = scanner.scan(token: "}")
		XCTAssert(token1 == "func")
		XCTAssert(fname1 == "doubling")
		XCTAssert(variable1 == "value" && variable2 == "value")
		XCTAssert(type1 == "Float" && type2 == "Float")
		XCTAssert(return1 == "return")
		XCTAssert(value2 == 2)
	}

	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measure {
			// Put the code you want to measure the time of here.
		}
	}
	
}
