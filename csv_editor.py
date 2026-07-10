# csv_editor.py
import csv
import sys
import os
from typing import List, Dict, Any, Optional

class CSVEditor:
    def __init__(self, filename: Optional[str] = None):
        self.filename = filename
        self.headers: List[str] = []
        self.rows: List[List[str]] = []
        self.delimiter = ','
        if filename and os.path.exists(filename):
            self.load(filename)
        elif filename:
            # Create empty CSV with headers from user input
            self.create_empty()

    def load(self, filename: str):
        with open(filename, 'r', newline='', encoding='utf-8') as f:
            reader = csv.reader(f)
            rows = list(reader)
            if not rows:
                self.headers = []
                self.rows = []
                return
            self.headers = rows[0]
            self.rows = rows[1:]

    def save(self, filename: Optional[str] = None):
        if filename is None:
            filename = self.filename
        if not filename:
            filename = input("Enter filename to save: ").strip()
            if not filename.endswith('.csv'):
                filename += '.csv'
        with open(filename, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            writer.writerow(self.headers)
            writer.writerows(self.rows)

    def create_empty(self):
        print("Creating new CSV file.")
        headers = input("Enter column headers (comma-separated): ").strip()
        self.headers = [h.strip() for h in headers.split(',') if h.strip()]
        if not self.headers:
            self.headers = ['Column1', 'Column2', 'Column3']
        self.rows = []
        self.save()

    def display(self):
        if not self.headers:
            print("No data loaded.")
            return
        # Calculate column widths
        col_widths = [len(h) for h in self.headers]
        for row in self.rows:
            for i, cell in enumerate(row):
                if i < len(col_widths):
                    col_widths[i] = max(col_widths[i], len(str(cell)))
                elif i < len(self.headers):
                    col_widths.append(len(str(cell)))
        # Build header
        sep = ' | '
        header_line = sep.join(f"{h:<{col_widths[i]}}" for i, h in enumerate(self.headers))
        print("\n" + header_line)
        print('-' * len(header_line))
        for row in self.rows:
            cells = row + [''] * (len(self.headers) - len(row))
            print(sep.join(f"{cells[i]:<{col_widths[i]}}" for i in range(len(self.headers))))

    def add_row(self):
        if not self.headers:
            print("No headers defined. Please add columns first.")
            return
        row = []
        for i, h in enumerate(self.headers):
            val = input(f"Enter value for '{h}': ").strip()
            row.append(val)
        self.rows.append(row)
        print("Row added.")

    def edit_cell(self):
        self.display()
        try:
            row_idx = int(input("Enter row index (1-based): ")) - 1
            if row_idx < 0 or row_idx >= len(self.rows):
                print("Invalid row index.")
                return
            print("Columns:", ', '.join(self.headers))
            col_name = input("Enter column name: ").strip()
            if col_name not in self.headers:
                print("Column not found.")
                return
            col_idx = self.headers.index(col_name)
            new_val = input(f"Enter new value for '{col_name}': ").strip()
            self.rows[row_idx][col_idx] = new_val
            print("Cell updated.")
        except ValueError:
            print("Invalid input.")

    def delete_row(self):
        self.display()
        try:
            row_idx = int(input("Enter row index to delete (1-based): ")) - 1
            if row_idx < 0 or row_idx >= len(self.rows):
                print("Invalid row index.")
                return
            del self.rows[row_idx]
            print("Row deleted.")
        except ValueError:
            print("Invalid input.")

    def filter_rows(self):
        if not self.rows:
            print("No rows to filter.")
            return
        print("Columns:", ', '.join(self.headers))
        col_name = input("Enter column name to filter: ").strip()
        if col_name not in self.headers:
            print("Column not found.")
            return
        col_idx = self.headers.index(col_name)
        value = input("Enter value to match: ").strip()
        case_sensitive = input("Case-sensitive? (y/n): ").strip().lower() == 'y'
        filtered = []
        for row in self.rows:
            if col_idx < len(row):
                cell = row[col_idx]
                if case_sensitive:
                    match = cell == value
                else:
                    match = cell.lower() == value.lower()
                if match:
                    filtered.append(row)
        if not filtered:
            print("No matching rows.")
            return
        # Display filtered rows
        old_rows = self.rows
        self.rows = filtered
        self.display()
        self.rows = old_rows

    def sort_rows(self):
        if not self.rows:
            print("No rows to sort.")
            return
        print("Columns:", ', '.join(self.headers))
        col_name = input("Enter column name to sort by: ").strip()
        if col_name not in self.headers:
            print("Column not found.")
            return
        col_idx = self.headers.index(col_name)
        reverse = input("Sort descending? (y/n): ").strip().lower() == 'y'
        self.rows.sort(key=lambda row: row[col_idx] if col_idx < len(row) else '', reverse=reverse)
        print("Rows sorted.")

    def add_column(self):
        col_name = input("Enter new column name: ").strip()
        if not col_name:
            print("Invalid name.")
            return
        if col_name in self.headers:
            print("Column already exists.")
            return
        default_val = input("Enter default value for existing rows (leave empty for empty string): ").strip()
        self.headers.append(col_name)
        for row in self.rows:
            row.append(default_val)
        print("Column added.")

    def remove_column(self):
        if not self.headers:
            print("No columns to remove.")
            return
        print("Columns:", ', '.join(self.headers))
        col_name = input("Enter column name to remove: ").strip()
        if col_name not in self.headers:
            print("Column not found.")
            return
        col_idx = self.headers.index(col_name)
        del self.headers[col_idx]
        for row in self.rows:
            if col_idx < len(row):
                del row[col_idx]
        print("Column removed.")

    def summary(self):
        print(f"File: {self.filename or '(new)'}")
        print(f"Rows: {len(self.rows)}")
        print(f"Columns: {len(self.headers)}")
        if self.headers:
            print("Headers:", ', '.join(self.headers))

    def run(self):
        print("=== CSV Editor/Viewer ===")
        if self.filename:
            print(f"Loaded: {self.filename} ({len(self.rows)} rows, {len(self.headers)} columns)")
        else:
            print("No file loaded.")
        while True:
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
            choice = input("Choose: ").strip()
            if choice == '1':
                self.display()
            elif choice == '2':
                self.add_row()
            elif choice == '3':
                self.edit_cell()
            elif choice == '4':
                self.delete_row()
            elif choice == '5':
                self.filter_rows()
            elif choice == '6':
                self.sort_rows()
            elif choice == '7':
                self.add_column()
            elif choice == '8':
                self.remove_column()
            elif choice == '9':
                self.save()
                print("Saved.")
            elif choice == '10':
                self.summary()
            elif choice == '11':
                if input("Save before exit? (y/n): ").strip().lower() == 'y':
                    self.save()
                print("Goodbye!")
                break
            else:
                print("Invalid choice.")

def main():
    filename = sys.argv[1] if len(sys.argv) > 1 else None
    editor = CSVEditor(filename)
    editor.run()

if __name__ == '__main__':
    main()
