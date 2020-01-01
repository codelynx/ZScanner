#  ZScanner

`ZScanner` aims enhancement or replacement of `Scanner` in Foundation framework.  

### Basic Usage

```.swift
let scanner = ZScanner(string: "1.25e+5,125000,1024,512")
let a = scanner.scanFloatinPoint() // 1.25e+5
scanner.scan(string: ",")
let b = scanner.scanFloatinPoint() // 125000
scanner.scan(string: ",")
let x = scanner.scanInteger() // 1024
scanner.scan(string: ",")
let y = scanner.scanInteger() // 512
```

When you are expecting one of some keyword, you may use array of strings to scan.

```.swift
let scanner = ZScanner(string: "true")
let a = scanner.scan(strings: ["true", "false"]) 
a // true
```

If you like to scan associated indirect value, you may use dictionary to scan, and it returns its associated value instad of direct keyword. 

```.swift
let scanner = ZScanner(string: "JST 15:00")
if let offset = scanner.scan(dictionary: ["JST": 9, "EST": -5, "MST": -6, "PST": -8, "GMT": 0]) {
	scanner.scanWhitespaces()
	if let hour: Int = scanner.scanInteger(), let _ = scanner.scan(string: ":"), let minute: Int = scanner.scanInteger() {
		// offset: 9
		// hour: 15
		// minute: 0
	}
}
```

If you like to more sophisticated things to scan, you may provide a class or a struct confoms to ZScannable.

```.swift
protocol ZScannable {
	init?(_ scanner: ZScanner)
}
```

Here is an example of providing extension of `Bool`. 

```.swift
extension Bool {
	init?(_ scanner: ZScanner) {
		scanner.scanWhitespaces()
		if let value: Bool = scanner.scan(dictionary: ["true": true, "false": false]) { self = value }
		else { return nil }
	}
}
```

Then you may scan boolean value.

```.swift
let scanner = ZScanner(string: "false")
let value: Bool? = Bool(scanner) // false
```

You may scan an identifier.

```.swift
let scanner = ZScanner(string: "not_found_404")
let value = scanner.scanIdentifier() // "not_found_404"
```

Be aware that when you scan a keyword, it won't scan that keyword partially.

```.swift
let scanner = ZScanner(string: "helloworld")
let hello = scanner.scan(string: "hello") // nil
let world = scanner.scan(string: "helloworld") // "helloworld"
```

```.swift
let scanner = ZScanner(string: "hello world")
let hello = scanner.scan(string: "hello") // "hello"
let world = scanner.scan(string: "world") // "world"
```

You may have to pay attension to whitespaces to scan.

```.swift
let scanner = ZScanner(string: "  hello")
let hello1 = scanner.scan(string: "hello") // nil
scanner.scanWhitespaces()
let hello2 = scanner.scan(string: "hello") // "hello"
```

You may use `options` to scan case insensitive keyword. 

```.swift
let scanner = ZScanner(string: "hElLo")
let hello2 = scanner.scan(string: "hello", options: [.caseInsensitive]) // "hElLo"
```

#### License
MIT License

