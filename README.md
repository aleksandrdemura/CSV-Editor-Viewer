# 📊 CSV Editor/Viewer – Multi‑Language Edition

A powerful **CSV file editor and viewer** that allows you to view, edit, filter, sort, add/remove rows and columns, and export data in various formats.  
Built in **7 programming languages** – perfect for data manipulation, learning, or integration.

## ✨ Features
- **View CSV** – display the entire table with formatted columns (auto‑width).
- **Add rows** – insert new rows with data validation.
- **Edit cells** – modify individual cell values.
- **Delete rows** – remove rows by index.
- **Filter rows** – show only rows where a column matches a value (case‑sensitive/insensitive).
- **Sort rows** – sort the table by a selected column (ascending/descending).
- **Add/remove columns** – insert or delete columns by name.
- **Export** – save the modified data back to CSV.
- **Summary** – display row count, column count, and column headers.
- **Interactive CLI** – intuitive numbered menu.

## 🗂 Languages & Files
| Language          | File               |
|-------------------|--------------------|
| Python            | `csv_editor.py`    |
| Go                | `csv_editor.go`    |
| JavaScript        | `csv_editor.js`    |
| C#                | `CsvEditor.cs`     |
| Java              | `CsvEditor.java`   |
| Ruby              | `csv_editor.rb`    |
| Swift             | `csv_editor.swift` |

## 🚀 How to Run
Each file is standalone – run it with the appropriate interpreter/compiler:

| Language | Command |
|----------|---------|
| Python   | `python csv_editor.py [filename.csv]` |
| Go       | `go run csv_editor.go [filename.csv]` |
| JavaScript | `node csv_editor.js [filename.csv]` |
| C#       | `dotnet run -- [filename.csv]` (or compile and run) |
| Java     | `javac CsvEditor.java && java CsvEditor [filename.csv]` |
| Ruby     | `ruby csv_editor.rb [filename.csv]` |
| Swift    | `swift csv_editor.swift [filename.csv]` |

If no filename is provided, the program prompts for one or creates a new empty CSV.

## 📊 Example Session
=== CSV Editor/Viewer ===
Loaded: data.csv (5 rows, 3 columns)
Columns: ID, Name, Age

Menu:

View table

Add row

Edit cell

Delete row

Filter rows

Sort rows

Add column

Remove column

Export / Save

Show summary

Exit
Choose: 1

Table:
ID | Name | Age
1 | Alice | 25
2 | Bob | 30
3 | Charlie | 35

text

## 🔧 Features Detail
- **View** – displays the entire table with aligned columns.
- **Add row** – prompts for values for each column (or skips empty lines).
- **Edit cell** – asks for row index and column name, then new value.
- **Delete row** – removes a row by its index.
- **Filter** – choose a column, a value, and whether to match exactly or partially.
- **Sort** – select a column and order (ascending/descending).
- **Add column** – specify a new column name and optional default value.
- **Remove column** – delete a column by name.
- **Export** – saves the current table to the original file (or a new file).

## 🤝 Contributing
Add support for TSV, JSON export, or GUI – PRs welcome!

## 📜 License
MIT – use freely.
