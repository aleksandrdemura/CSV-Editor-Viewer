// csv_editor.swift
import Foundation

class CSVEditor {
    var filename: String?
    var headers: [String] = []
    var rows: [[String]] = []

    init(filename: String?) {
        self.filename = filename
        if let name = filename, FileManager.default.fileExists(atPath: name) {
            load(name)
        } else if filename != nil {
            createEmpty()
        } else {
            createEmpty()
        }
    }

    func load(_ filename: String) {
        guard let content = try? String(contentsOfFile: filename, encoding: .utf8) else { return }
        let lines = content.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        if lines.isEmpty { return }
        headers = lines[0].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for i in 1..<lines.count {
            let row = lines[i].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            rows.append(row)
        }
    }

    func save(_ filename: String? = nil) {
        let name = filename ?? self.filename
        guard let fname = name else {
            print("No filename provided.")
            return
        }
        var lines: [String] = []
        lines.append(headers.joined(separator: ","))
        for row in rows {
            lines.append(row.joined(separator: ","))
        }
        let content = lines.joined(separator: "\n")
        try? content.write(toFile: fname, atomically: true, encoding: .utf8)
        print("Saved.")
    }

    func createEmpty() {
        print("Creating new CSV file.")
        print("Enter column headers (comma-separated): ", terminator: "")
        guard let input = readLine() else { return }
        headers = input.isEmpty ? ["Column1", "Column2", "Column3"] : input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        rows = []
        save(filename ?? "new.csv")
    }

    func display() {
        if headers.isEmpty {
            print("No data loaded.")
            return
        }
        var colWidths = headers.map { $0.count }
        for row in rows {
            for (i, cell) in row.enumerated() {
                if i < colWidths.count && cell.count > colWidths[i] {
                    colWidths[i] = cell.count
                }
            }
        }
        let sep = " | "
        print()
        let headerLine = headers.enumerated().map { (i, h) -> String in
            return h.padding(toLength: colWidths[i], withPad: " ", startingAt: 0)
        }.joined(separator: sep)
        print(headerLine)
        print(String(repeating: "-", count: headerLine.count))
        for row in rows {
            let cells = headers.enumerated().map { (i, _) -> String in
                let cell = i < row.count ? row[i] : ""
                return cell.padding(toLength: colWidths[i], withPad: " ", startingAt: 0)
            }.joined(separator: sep)
            print(cells)
        }
    }

    func addRow() {
        if headers.isEmpty {
            print("No headers defined. Please add columns first.")
            return
        }
        var row: [String] = []
        for h in headers {
            print("Enter value for '\(h)': ", terminator: "")
            if let val = readLine() {
                row.append(val.trimmingCharacters(in: .whitespaces))
            } else {
                row.append("")
            }
        }
        rows.append(row)
        print("Row added.")
    }

    func editCell() {
        display()
        print("Enter row index (1-based): ", terminator: "")
        guard let rowIdxStr = readLine(), let rowIdx = Int(rowIdxStr), rowIdx >= 1, rowIdx <= rows.count else {
            print("Invalid row index.")
            return
        }
        let idx = rowIdx - 1
        print("Columns: \(headers.joined(separator: ", "))")
        print("Enter column name: ", terminator: "")
        guard let colName = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
        guard let colIdx = headers.firstIndex(of: colName) else {
            print("Column not found.")
            return
        }
        print("Enter new value for '\(colName)': ", terminator: "")
        guard let newVal = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
        rows[idx][colIdx] = newVal
        print("Cell updated.")
    }

    func deleteRow() {
        display()
        print("Enter row index to delete (1-based): ", terminator: "")
        guard let rowIdxStr = readLine(), let rowIdx = Int(rowIdxStr), rowIdx >= 1, rowIdx <= rows.count else {
            print("Invalid row index.")
            return
        }
        rows.remove(at: rowIdx - 1)
        print("Row deleted.")
    }

    func filterRows() {
        if rows.isEmpty {
            print("No rows to filter.")
            return
        }
        print("Columns: \(headers.joined(separator: ", "))")
        print("Enter column name to filter: ", terminator: "")
        guard let colName = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
        guard let colIdx = headers.firstIndex(of: colName) else {
            print("Column not found.")
            return
        }
        print("Enter value to match: ", terminator: "")
        guard let value = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
        print("Case-sensitive? (y/n): ", terminator: "")
        let caseSensitive = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() == "y"
        let filtered = rows.filter { row in
            guard colIdx < row.count else { return false }
            let cell = row[colIdx]
            return caseSensitive ? cell == value : cell.lowercased() == value.lowercased()
        }
        if filtered.isEmpty {
            print("No matching rows.")
        } else {
            let oldRows = rows
            rows = filtered
            display()
            rows = oldRows
        }
    }

    func sortRows() {
        if rows.isEmpty {
            print("No rows to sort.")
            return
        }
        print("Columns: \(headers.joined(separator: ", "))")
        print("Enter column name to sort by: ", terminator: "")
        guard let colName = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
        guard let colIdx = headers.firstIndex(of: colName) else {
            print("Column not found.")
            return
        }
        print("Sort descending? (y/n): ", terminator: "")
        let reverse = readLine()?.trimmingCharacters(in: .whitespaces).lowercased() == "y"
        rows.sort { (a, b) -> Bool in
            let va = colIdx < a.count ? a[colIdx] : ""
            let vb = colIdx < b.count ? b[colIdx] : ""
            return reverse ? va > vb : va < vb
        }
        print("Rows sorted.")
    }

    func addColumn() {
        print("Enter new column name: ", terminator: "")
        guard let colName = readLine()?.trimmingCharacters(in: .whitespaces), !colName.isEmpty else {
            print("Invalid name.")
            return
        }
        if headers.contains(colName) {
            print("Column already exists.")
            return
        }
        print("Enter default value for existing rows (leave empty for empty string): ", terminator: "")
        let defaultVal = readLine()?.trimmingCharacters(in: .whitespaces) ?? ""
        headers.append(colName)
        for i in 0..<rows.count {
            rows[i].append(defaultVal)
        }
        print("Column added.")
    }

    func removeColumn() {
        if headers.isEmpty {
            print("No columns to remove.")
            return
        }
        print("Columns: \(headers.joined(separator: ", "))")
        print("Enter column name to remove: ", terminator: "")
        guard let colName = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
        guard let colIdx = headers.firstIndex(of: colName) else {
            print("Column not found.")
            return
        }
        headers.remove(at: colIdx)
        for i in 0..<rows.count {
            if colIdx < rows[i].count {
                rows[i].remove(at: colIdx)
            }
        }
        print("Column removed.")
    }

    func summary() {
        print("File: \(filename ?? "(new)")")
        print("Rows: \(rows.count)")
        print("Columns: \(headers.count)")
        if !headers.isEmpty {
            print("Headers: \(headers.joined(separator: ", "))")
        }
    }

    func run() {
        print("=== CSV Editor/Viewer ===")
        if let name = filename {
            print("Loaded: \(name) (\(rows.count) rows, \(headers.count) columns)")
        } else {
            print("No file loaded.")
        }
        while true {
            print("\nMenu:")
            print("1. View table")
            print("2. Add row")
            print("3. Edit cell")
            print("4. Delete row")
            print("5. Filter rows")
            print("6. Sort rows")
            print("7. Add column")
            print("8. Remove column")
            print("9. Export / Save")
            print("10. Show summary")
            print("11. Exit")
            print("Choose: ", terminator: "")
            guard let choice = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
            switch choice {
            case "1": display()
            case "2": addRow()
            case "3": editCell()
            case "4": deleteRow()
            case "5": filterRows()
            case "6": sortRows()
            case "7": addColumn()
            case "8": removeColumn()
            case "9": save()
            case "10": summary()
            case "11":
                print("Save before exit? (y/n): ", terminator: "")
                if readLine()?.trimmingCharacters(in: .whitespaces).lowercased() == "y" {
                    save()
                }
                print("Goodbye!")
                return
            default: print("Invalid choice.")
            }
        }
    }
}

let filename = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : nil
let editor = CSVEditor(filename: filename)
editor.run()
