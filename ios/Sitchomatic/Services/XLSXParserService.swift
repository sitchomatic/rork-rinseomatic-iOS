import Foundation
import ZIPFoundation

nonisolated struct XLSXParserService: Sendable {
    static func parseToCSV(url: URL) -> String? {
        guard let archive = try? Archive(url: url, accessMode: .read) else { return nil }

        let sharedStrings = parseSharedStrings(from: archive)
        guard let sheetXML = extractEntry(named: "xl/worksheets/sheet1.xml", from: archive) else { return nil }

        let parser = SheetXMLParser(sharedStrings: sharedStrings)
        let xmlParser = XMLParser(data: sheetXML)
        xmlParser.delegate = parser
        guard xmlParser.parse() else { return nil }

        let rows = parser.rows
        guard !rows.isEmpty else { return nil }

        let maxCol = rows.values.flatMap(\.keys).max() ?? 0
        var csvLines: [String] = []

        for rowIndex in rows.keys.sorted() {
            guard let row = rows[rowIndex] else { continue }
            var cells: [String] = []
            for col in 0...maxCol {
                cells.append(escapeCSVField(row[col] ?? ""))
            }
            csvLines.append(cells.joined(separator: ","))
        }

        let result = csvLines.joined(separator: "\n")
        return result.isEmpty ? nil : result
    }

    private static func parseSharedStrings(from archive: Archive) -> [String] {
        guard let data = extractEntry(named: "xl/sharedStrings.xml", from: archive) else { return [] }
        let parser = SharedStringsXMLParser()
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = parser
        xmlParser.parse()
        return parser.strings
    }

    private static func extractEntry(named path: String, from archive: Archive) -> Data? {
        guard let entry = archive[path] else { return nil }
        var result = Data()
        do {
            _ = try archive.extract(entry) { chunk in
                result.append(chunk)
            }
        } catch {
            return nil
        }
        return result
    }

    private static func escapeCSVField(_ field: String) -> String {
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            let escaped = field.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }
        return field
    }
}

nonisolated private final class SharedStringsXMLParser: NSObject, XMLParserDelegate, @unchecked Sendable {
    var strings: [String] = []
    private var currentText = ""
    private var insideT = false

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        if elementName == "t" {
            insideT = true
            currentText = ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if insideT {
            currentText += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "t" {
            insideT = false
        } else if elementName == "si" {
            strings.append(currentText)
            currentText = ""
        }
    }
}

nonisolated private final class SheetXMLParser: NSObject, XMLParserDelegate, @unchecked Sendable {
    let sharedStrings: [String]
    var rows: [Int: [Int: String]] = [:]

    private var currentRow: Int = 0
    private var currentCol: Int = 0
    private var currentCellType: String?
    private var currentValue = ""
    private var insideV = false
    private var insideIs = false
    private var inlineText = ""

    init(sharedStrings: [String]) {
        self.sharedStrings = sharedStrings
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        switch elementName {
        case "row":
            if let r = attributeDict["r"], let num = Int(r) {
                currentRow = num
            }
        case "c":
            currentCellType = attributeDict["t"]
            currentValue = ""
            inlineText = ""
            if let ref = attributeDict["r"] {
                currentCol = columnIndex(from: ref)
            }
        case "v":
            insideV = true
            currentValue = ""
        case "is":
            insideIs = true
            inlineText = ""
        case "t":
            if insideIs {
                inlineText = ""
            }
        default:
            break
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if insideV {
            currentValue += string
        } else if insideIs {
            inlineText += string
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "v":
            insideV = false
        case "is":
            insideIs = false
        case "c":
            let resolved: String
            if currentCellType == "s", let idx = Int(currentValue), idx < sharedStrings.count {
                resolved = sharedStrings[idx]
            } else if currentCellType == "inlineStr" || !inlineText.isEmpty {
                resolved = inlineText
            } else {
                resolved = currentValue
            }
            if rows[currentRow] == nil { rows[currentRow] = [:] }
            rows[currentRow]?[currentCol] = resolved
        default:
            break
        }
    }

    private func columnIndex(from ref: String) -> Int {
        var col = 0
        for ch in ref {
            guard ch.isLetter else { break }
            col = col * 26 + (Int(ch.asciiValue ?? 65) - 64)
        }
        return max(0, col - 1)
    }
}
