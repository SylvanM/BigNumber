import XCTest
@testable import BigNumber

final class BigNumberTests: XCTestCase {
    
    let outputFile = URL(fileURLWithPath: "/Users/sylvanm/Programming/Swift/Packages/BigNumber/Tests/BigNumberTests/test_output")
    
    func testExample() {
        
        var bn: BN = [0, 1]
        print(bn.binaryString)
        
        bn >>= 1
        
        
        print(bn.binaryString)
        
    }
    
    func randomStringWithLength(len: Int) -> String {

        let letters: NSString = "0123456789abcdef"

        let randomString: NSMutableString = NSMutableString(capacity: len)

        for _ in 0..<len {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }

        return randomString as String
    }
    
    func clearOutput() {
        try! "".write(to: outputFile, atomically: true, encoding: .utf8)
    }
    
    func write(_ value: Any) {
        let data = "\(value)\n".data(using: .utf8)!
        
        if let fileHandle = FileHandle(forWritingAtPath: outputFile.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        }
        else {
            try! data.write(to: outputFile, options: .atomic)
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
