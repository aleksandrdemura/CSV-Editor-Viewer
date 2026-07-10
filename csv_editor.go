// csv_editor.go
package main

import (
	"bufio"
	"encoding/csv"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type CSVEditor struct {
	filename string
	headers  []string
	rows     [][]string
}

func NewCSVEditor(filename string) *CSVEditor {
	e := &CSVEditor{filename: filename}
	if filename != "" {
		if _, err := os.Stat(filename); err == nil {
			e.load(filename)
		} else {
			e.createEmpty()
		}
	} else {
		e.createEmpty()
	}
	return e
}

func (e *CSVEditor) load(filename string) {
	file, err := os.Open(filename)
	if err != nil {
		fmt.Println("Error loading file:", err)
		return
	}
	defer file.Close()
	reader := csv.NewReader(file)
	records, err := reader.ReadAll()
	if err != nil {
		fmt.Println("Error reading CSV:", err)
		return
	}
	if len(records) > 0 {
		e.headers = records[0]
		e.rows = records[1:]
	} else {
		e.headers = []string{}
		e.rows = [][]string{}
	}
}

func (e *CSVEditor) save(filename ...string) {
	fname := e.filename
	if len(filename) > 0 && filename[0] != "" {
		fname = filename[0]
	}
	if fname == "" {
		fmt.Print("Enter filename to save: ")
		scanner := bufio.NewScanner(os.Stdin)
		scanner.Scan()
		fname = strings.TrimSpace(scanner.Text())
		if !strings.HasSuffix(fname, ".csv") {
			fname += ".csv"
		}
	}
	file, err := os.Create(fname)
	if err != nil {
		fmt.Println("Error creating file:", err)
		return
	}
	defer file.Close()
	writer := csv.NewWriter(file)
	defer writer.Flush()
	writer.Write(e.headers)
	for _, row := range e.rows {
		writer.Write(row)
	}
	fmt.Println("Saved.")
}

func (e *CSVEditor) createEmpty() {
	fmt.Println("Creating new CSV file.")
	fmt.Print("Enter column headers (comma-separated): ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	input := strings.TrimSpace(scanner.Text())
	if input == "" {
		e.headers = []string{"Column1", "Column2", "Column3"}
	} else {
		parts := strings.Split(input, ",")
		e.headers = make([]string, len(parts))
		for i, p := range parts {
			e.headers[i] = strings.TrimSpace(p)
		}
	}
	e.rows = [][]string{}
	e.save()
}

func (e *CSVEditor) display() {
	if len(e.headers) == 0 {
		fmt.Println("No data loaded.")
		return
	}
	// Calculate column widths
	colWidths := make([]int, len(e.headers))
	for i, h := range e.headers {
		colWidths[i] = len(h)
	}
	for _, row := range e.rows {
		for i, cell := range row {
			if i < len(colWidths) {
				if len(cell) > colWidths[i] {
					colWidths[i] = len(cell)
				}
			}
		}
	}
	// Build header
	sep := " | "
	fmt.Println()
	for i, h := range e.headers {
		fmt.Printf("%-*s", colWidths[i], h)
		if i < len(e.headers)-1 {
			fmt.Print(sep)
		}
	}
	fmt.Println()
	for i := range colWidths {
		fmt.Print(strings.Repeat("-", colWidths[i]))
		if i < len(colWidths)-1 {
			fmt.Print("-+-")
		}
	}
	fmt.Println()
	for _, row := range e.rows {
		cells := make([]string, len(e.headers))
		copy(cells, row)
		for i := range cells {
			fmt.Printf("%-*s", colWidths[i], cells[i])
			if i < len(cells)-1 {
				fmt.Print(sep)
			}
		}
		fmt.Println()
	}
}

func (e *CSVEditor) addRow() {
	if len(e.headers) == 0 {
		fmt.Println("No headers defined. Please add columns first.")
		return
	}
	row := make([]string, len(e.headers))
	for i, h := range e.headers {
		fmt.Printf("Enter value for '%s': ", h)
		scanner := bufio.NewScanner(os.Stdin)
		scanner.Scan()
		row[i] = strings.TrimSpace(scanner.Text())
	}
	e.rows = append(e.rows, row)
	fmt.Println("Row added.")
}

func (e *CSVEditor) editCell() {
	e.display()
	fmt.Print("Enter row index (1-based): ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	rowIdx, err := strconv.Atoi(strings.TrimSpace(scanner.Text()))
	if err != nil || rowIdx < 1 || rowIdx > len(e.rows) {
		fmt.Println("Invalid row index.")
		return
	}
	rowIdx--
	fmt.Println("Columns:", strings.Join(e.headers, ", "))
	fmt.Print("Enter column name: ")
	scanner.Scan()
	colName := strings.TrimSpace(scanner.Text())
	colIdx := -1
	for i, h := range e.headers {
		if h == colName {
			colIdx = i
			break
		}
	}
	if colIdx == -1 {
		fmt.Println("Column not found.")
		return
	}
	fmt.Printf("Enter new value for '%s': ", colName)
	scanner.Scan()
	newVal := strings.TrimSpace(scanner.Text())
	e.rows[rowIdx][colIdx] = newVal
	fmt.Println("Cell updated.")
}

func (e *CSVEditor) deleteRow() {
	e.display()
	fmt.Print("Enter row index to delete (1-based): ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	rowIdx, err := strconv.Atoi(strings.TrimSpace(scanner.Text()))
	if err != nil || rowIdx < 1 || rowIdx > len(e.rows) {
		fmt.Println("Invalid row index.")
		return
	}
	rowIdx--
	e.rows = append(e.rows[:rowIdx], e.rows[rowIdx+1:]...)
	fmt.Println("Row deleted.")
}

func (e *CSVEditor) filterRows() {
	if len(e.rows) == 0 {
		fmt.Println("No rows to filter.")
		return
	}
	fmt.Println("Columns:", strings.Join(e.headers, ", "))
	fmt.Print("Enter column name to filter: ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	colName := strings.TrimSpace(scanner.Text())
	colIdx := -1
	for i, h := range e.headers {
		if h == colName {
			colIdx = i
			break
		}
	}
	if colIdx == -1 {
		fmt.Println("Column not found.")
		return
	}
	fmt.Print("Enter value to match: ")
	scanner.Scan()
	value := strings.TrimSpace(scanner.Text())
	fmt.Print("Case-sensitive? (y/n): ")
	scanner.Scan()
	caseSensitive := strings.ToLower(strings.TrimSpace(scanner.Text())) == "y"
	var filtered [][]string
	for _, row := range e.rows {
		if colIdx < len(row) {
			cell := row[colIdx]
			match := false
			if caseSensitive {
				match = cell == value
			} else {
				match = strings.ToLower(cell) == strings.ToLower(value)
			}
			if match {
				filtered = append(filtered, row)
			}
		}
	}
	if len(filtered) == 0 {
		fmt.Println("No matching rows.")
		return
	}
	oldRows := e.rows
	e.rows = filtered
	e.display()
	e.rows = oldRows
}

func (e *CSVEditor) sortRows() {
	if len(e.rows) == 0 {
		fmt.Println("No rows to sort.")
		return
	}
	fmt.Println("Columns:", strings.Join(e.headers, ", "))
	fmt.Print("Enter column name to sort by: ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	colName := strings.TrimSpace(scanner.Text())
	colIdx := -1
	for i, h := range e.headers {
		if h == colName {
			colIdx = i
			break
		}
	}
	if colIdx == -1 {
		fmt.Println("Column not found.")
		return
	}
	fmt.Print("Sort descending? (y/n): ")
	scanner.Scan()
	reverse := strings.ToLower(strings.TrimSpace(scanner.Text())) == "y"
	sortFunc := func(i, j int) bool {
		a, b := "", ""
		if colIdx < len(e.rows[i]) {
			a = e.rows[i][colIdx]
		}
		if colIdx < len(e.rows[j]) {
			b = e.rows[j][colIdx]
		}
		if reverse {
			return a > b
		}
		return a < b
	}
	// Simple bubble sort for demonstration (avoid importing sort)
	for i := 0; i < len(e.rows)-1; i++ {
		for j := 0; j < len(e.rows)-i-1; j++ {
			if sortFunc(j, j+1) {
				e.rows[j], e.rows[j+1] = e.rows[j+1], e.rows[j]
			}
		}
	}
	fmt.Println("Rows sorted.")
}

func (e *CSVEditor) addColumn() {
	fmt.Print("Enter new column name: ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	colName := strings.TrimSpace(scanner.Text())
	if colName == "" {
		fmt.Println("Invalid name.")
		return
	}
	for _, h := range e.headers {
		if h == colName {
			fmt.Println("Column already exists.")
			return
		}
	}
	fmt.Print("Enter default value for existing rows (leave empty for empty string): ")
	scanner.Scan()
	defaultVal := strings.TrimSpace(scanner.Text())
	e.headers = append(e.headers, colName)
	for i := range e.rows {
		e.rows[i] = append(e.rows[i], defaultVal)
	}
	fmt.Println("Column added.")
}

func (e *CSVEditor) removeColumn() {
	if len(e.headers) == 0 {
		fmt.Println("No columns to remove.")
		return
	}
	fmt.Println("Columns:", strings.Join(e.headers, ", "))
	fmt.Print("Enter column name to remove: ")
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	colName := strings.TrimSpace(scanner.Text())
	colIdx := -1
	for i, h := range e.headers {
		if h == colName {
			colIdx = i
			break
		}
	}
	if colIdx == -1 {
		fmt.Println("Column not found.")
		return
	}
	e.headers = append(e.headers[:colIdx], e.headers[colIdx+1:]...)
	for i := range e.rows {
		if colIdx < len(e.rows[i]) {
			e.rows[i] = append(e.rows[i][:colIdx], e.rows[i][colIdx+1:]...)
		}
	}
	fmt.Println("Column removed.")
}

func (e *CSVEditor) summary() {
	fmt.Printf("File: %s\n", e.filename)
	fmt.Printf("Rows: %d\n", len(e.rows))
	fmt.Printf("Columns: %d\n", len(e.headers))
	if len(e.headers) > 0 {
		fmt.Println("Headers:", strings.Join(e.headers, ", "))
	}
}

func (e *CSVEditor) run() {
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Println("=== CSV Editor/Viewer ===")
	if e.filename != "" {
		fmt.Printf("Loaded: %s (%d rows, %d columns)\n", e.filename, len(e.rows), len(e.headers))
	} else {
		fmt.Println("No file loaded.")
	}
	for {
		fmt.Println("\nMenu:")
		fmt.Println("1. View table")
		fmt.Println("2. Add row")
		fmt.Println("3. Edit cell")
		fmt.Println("4. Delete row")
		fmt.Println("5. Filter rows")
		fmt.Println("6. Sort rows")
		fmt.Println("7. Add column")
		fmt.Println("8. Remove column")
		fmt.Println("9. Export / Save")
		fmt.Println("10. Show summary")
		fmt.Println("11. Exit")
		fmt.Print("Choose: ")
		scanner.Scan()
		choice := strings.TrimSpace(scanner.Text())
		switch choice {
		case "1":
			e.display()
		case "2":
			e.addRow()
		case "3":
			e.editCell()
		case "4":
			e.deleteRow()
		case "5":
			e.filterRows()
		case "6":
			e.sortRows()
		case "7":
			e.addColumn()
		case "8":
			e.removeColumn()
		case "9":
			e.save()
		case "10":
			e.summary()
		case "11":
			fmt.Print("Save before exit? (y/n): ")
			scanner.Scan()
			if strings.ToLower(strings.TrimSpace(scanner.Text())) == "y" {
				e.save()
			}
			fmt.Println("Goodbye!")
			return
		default:
			fmt.Println("Invalid choice.")
		}
	}
}

func main() {
	var filename string
	if len(os.Args) > 1 {
		filename = os.Args[1]
	}
	editor := NewCSVEditor(filename)
	editor.run()
}
