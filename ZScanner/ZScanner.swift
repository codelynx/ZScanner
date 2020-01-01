//
//	ZScanner.swift
//	ZScanner
//
//	The MIT License (MIT)
//
//	Copyright (c) 2019 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

import Foundation

extension String {
	subscript (i: Int) -> Character {
		return self[index(startIndex, offsetBy: i)]
	}
	func range(from range: NSRange) -> Range<String.Index>? {
		return Range(range, in: self)
	}
	func range(from range: Range<String.Index>) -> NSRange {
		return NSRange(range, in: self)
	}
	var firstLine: String? {
		var line: String?
		self.enumerateLines {
			line = $0
			$1 = true
		}
		return line
	}
}

struct ZCharacterSet {
	private var characters: Set<Character>
	init(characters: Set<Character>) {
		self.characters = characters
	}
	init(charactersInString: String) {
		self.characters = Set(charactersInString.map { $0 })
	}
	func contains(_ character: Character) -> Bool {
		return self.characters.contains(character)
	}
	mutating func add(_ characters: Set<Character>) {
		self.characters.formUnion(characters)
	}
	func adding(_ characters: Set<Character>) -> ZCharacterSet {
		return ZCharacterSet(characters: self.characters.union(characters))
	}
	mutating func remove(_ characters: Set<Character>) {
		self.characters.subtract(characters)
	}
	func removing(_ characters: Set<Character>) -> ZCharacterSet   {
		return ZCharacterSet(characters: self.characters.subtracting(characters))
	}
}

class ZScanner {

	let string: String
	var location: Int = 0
	init(string: String) {
		self.string = string
	}
	var isAtEnd: Bool {
		return self.location >= self.string.count
	}
	@discardableResult func scanUpTo(characterSet: ZCharacterSet) -> String? {
		var location = self.location
		var characters = String()
		while location < self.string.count {
			let character = self.string[location]
			if characterSet.contains(character) {
				characters.append(character)
				self.location = location
				location += 1
			}
			else {
				return characters.count > 0 ? characters : nil
			}
		}
		return characters.count > 0 ? characters : nil
	}
	@discardableResult func scan(characterSet: ZCharacterSet) -> Character? {
		if self.location < self.string.count {
			let character = self.string[self.location]
			if characterSet.contains(character) {
				self.location += 1
				return character
			}
		}
		return nil
	}
	@discardableResult func scan(characterSet: ZCharacterSet) -> String? {
		var characters = String()
		while let character: Character = self.scan(characterSet: characterSet) {
			characters.append(character)
		}
		return characters.count > 0 ? characters : nil
	}
	@discardableResult func scan(character: Character, options: NSString.CompareOptions = NSString.CompareOptions(rawValue: 0)) -> Character? {
		let characterString = String(character)
		if self.location < self.string.count {
			if characterString.compare(String(self.string[self.location]), options: options, range: nil, locale: nil) == .orderedSame {
				self.location += 1
				return character
			}
		}
		return nil
	}
	@discardableResult func scan(string: String, options: NSString.CompareOptions = NSString.CompareOptions(rawValue: 0)) -> String? {
		let savepoint = self.location
		var characters = String()
		for character in string {
			if let character = self.scan(character: character, options: options) {
				characters.append(character)
			}
			else {
				return nil
			}
		}
		if self.location < self.string.count {
			if let last = string.last, last.isLetter, self.string[self.location].isLetter {
				self.location = savepoint
				return nil
			}
		}
		if characters.count > 0 {
			return characters
		}
		self.location = savepoint
		return nil
	}
	func scan(strings: [String], options: NSString.CompareOptions = NSString.CompareOptions(rawValue: 0)) -> String? {
		for string in strings {
			if let string = self.scan(string: string, options: options) {
				return string
			}
		}
		return nil
	}
	func scanSign() -> Int? {
		return self.scan(dictionary: ["+": 1, "-": -1])
	}
	lazy var decimalDictionary: [String: Int] = { return [
		"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9
	] }()
	func scanDigit() -> Int? {
		return self.scan(dictionary: self.decimalDictionary)
	}
	func scanDigits() -> [Int]? {
		var digits = [Int]()
		while let digit = self.scanDigit() {
			digits.append(digit)
		}
		if digits.count > 0 { return digits }
		else { return nil }
	}
	func scanUnsignedInteger<T: UnsignedInteger>() -> T? {
		self.scanWhitespaces()
		if let digits = self.scanDigits() {
			return digits.reduce(T(0)) { ($0 * 10) + T($1) }
		}
		return nil
	}
	func scanInteger<T: SignedInteger>() -> T? {
		let savepoint = self.location
		var value: T?
		self.scanWhitespaces()
		if let sign = self.scanSign() {
			if let digits = self.scanDigits() {
				value = T(sign) * digits.reduce(T(0)) { ($0 * 10) + T($1) }
			}
			else {
				self.location = savepoint
				value = nil
			}
		}
		else if let digits = self.scanDigits() {
			value = digits.reduce(T(0)) { ($0 * 10) + T($1) }
		}
		return value
	}
	lazy var hexadecimalDictionary: [Character: Int] = { return [
		"0": 0, "1": 1, "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
		"a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f": 15,
		"A": 10, "B": 11, "C": 12, "D": 13, "E": 14, "F": 15,
	] }()
	func scanHexadecimalInteger<T: UnsignedInteger>() -> T? {
		let hexadecimals = "0123456789abcdefABCDEF"
		var value: T = 0
		var count = 0
		while let character: Character = self.scan(characterSet: ZCharacterSet(charactersInString: hexadecimals)) {
			guard let digit = self.hexadecimalDictionary[character] else { fatalError() }
			value = value * T(16) + T(digit)
			count += 1
		}
		return count > 0 ? value : nil
	}
	func scanFloatinPoint<T: FloatingPoint>() -> T? {
		let savepoint = self.location
		self.scanWhitespaces()
		var a = T(0)
		var e = 0
		if let value = self.scan(dictionary: ["inf": T.infinity, "nan": T.nan], options: [.caseInsensitive]) {
			return value
		}
		else if let fractions = self.scanDigits() {
			a = fractions.reduce(T(0)) { ($0 * T(10)) + T($1) }
			if let _ = self.scan(string: ".") {
				if let exponents = self.scanDigits() {
					a = exponents.reduce(a) { ($0 * T(10)) + T($1) }
					e = -exponents.count
				}
			}
			if let _ = self.scan(string: "e", options: [.caseInsensitive]) {
				var s = 1
				if let sign = self.scanSign() {
					s = sign
				}
				if let digits = self.scanDigits() {
					let i = digits.reduce(0) { ($0 * 10) + $1 }
					e += (i * s)
				}
				else {
					self.location = savepoint
					return nil
				}
			}
			// prefer refactoring:
			let i = (0 ..< abs(e)).reduce(1) { (a, b) in a * 10 }
			a = (e > 0) ? a * T(i) : (e < 0) ? a / T(i) : a
			return a
		}
		else { return nil }
	}
	static let lowercaseAlphabets = "abcdefghijklmnopqrstuvwxyz"
	static let uppercaseAlphabets = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	static let digits = "0123456789"
	static let hexadecimalDigits = "0123456789abcdefABCDEF"
	static var identifierFirstCharacters: String { Self.lowercaseAlphabets + Self.uppercaseAlphabets + "_" }
	static var identifierFollowingCharacters: String { Self.lowercaseAlphabets + Self.uppercaseAlphabets + Self.digits + "_" }
	func scanIdentifier() -> String? {
		var identifier: String?
		let savepoint = self.location
		let firstCharacterSet = ZCharacterSet(charactersInString: Self.identifierFirstCharacters)
		if let character: Character = self.scan(characterSet: firstCharacterSet) {
			identifier = (identifier ?? "").appending(String(character))
			let followingCharacterSet = ZCharacterSet(charactersInString: Self.identifierFollowingCharacters)
			while let character: Character = self.scan(characterSet: followingCharacterSet) {
				identifier = (identifier ?? "").appending(String(character))
			}
			return identifier
		}
		self.location = savepoint
		return nil
	}
	func scanWhitespaces() {
		let whitespaces = ZCharacterSet(charactersInString: " \r\t\n")
		_ = self.scan(characterSet: whitespaces) as String?
	}
	func scan<T>(dictionary: [String: T], options: NSString.CompareOptions = []) -> T? {
		for (key, value) in dictionary {
			if let string = self.scan(string: key, options: options) {
				assert(string == key)
				return value
			}
		}
		return nil
	}
	func scan<T: ZScannable>() -> T? {
		let savepoint = self.location
		if let scannable = T(self) {
			return scannable
		}
		self.location = savepoint
		return nil
	}
	func scan<T: ZScannable>() -> [T]? {
		var savepoint = self.location
		var scannables = [T]()
		while let scannable = T(self) {
			savepoint = self.location
			scannables.append(scannable)
		}
		self.location = savepoint
		if scannables.count > 0 { return scannables }
		return nil
	}
}


protocol ZScannable {
	init?(_ scanner: ZScanner)
}

extension Int {
	init?(_ scanner: ZScanner) {
		if let value: Int = scanner.scanInteger() { self = value }
		else { return nil }
	}
}

extension UInt {
	init?(_ scanner: ZScanner) {
		if let value: UInt = scanner.scanUnsignedInteger() { self = value }
		else { return nil }
	}
}

extension Float {
	init?(_ scanner: ZScanner) {
		if let value: Float = scanner.scanFloatinPoint() { self = value }
		else { return nil }
	}
}

extension Double {
	init?(_ scanner: ZScanner) {
		if let value: Double = scanner.scanFloatinPoint() { self = value }
		else { return nil }
	}
}

extension Bool {
	init?(_ scanner: ZScanner) {
		scanner.scanWhitespaces()
		if let value: Bool = scanner.scan(dictionary: ["true": true, "false": false], options: [.caseInsensitive]) { self = value }
		else { return nil }
	}
}
