// CsvEditor.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

class CsvEditor
{
    private string filename;
    private List<string> headers;
    private List<List<string>> rows;

    public CsvEditor(string filename)
    {
        this.filename = filename;
        headers = new List<string>();
        rows = new List<List<string>>();
        if (!string.IsNullOrEmpty(filename) && File.Exists(filename))
            Load(filename);
        else
            CreateEmpty();
    }

    private void Load(string filename)
    {
        var lines = File.ReadAllLines(filename, Encoding.UTF8);
        if (lines.Length > 0)
        {
            headers = lines[0].Split(',').Select(h => h.Trim()).ToList();
            for (int i = 1; i < lines.Length; i++)
            {
                if (!string.IsNullOrWhiteSpace(lines[i]))
                    rows.Add(lines[i].Split(',').Select(c => c.Trim()).ToList());
            }
        }
    }

    private void Save(string filename = null)
    {
        if (string.IsNullOrEmpty(filename)) filename = this.filename;
        if (string.IsNullOrEmpty(filename))
        {
            Console.Write("Enter filename to save: ");
            filename = Console.ReadLine().Trim();
            if (!filename.EndsWith(".csv")) filename += ".csv";
        }
        var lines = new List<string>();
        lines.Add(string.Join(",", headers));
        foreach (var row in rows)
            lines.Add(string.Join(",", row));
        File.WriteAllLines(filename, lines, Encoding.UTF8);
        Console.WriteLine("Saved.");
    }

    private void CreateEmpty()
    {
        Console.WriteLine("Creating new CSV file.");
        Console.Write("Enter column headers (comma-separated): ");
        var input = Console.ReadLine()?.Trim() ?? "";
        if (string.IsNullOrEmpty(input))
            headers = new List<string> { "Column1", "Column2", "Column3" };
        else
            headers = input.Split(',').Select(h => h.Trim()).Where(h => !string.IsNullOrEmpty(h)).ToList();
        rows = new List<List<string>>();
        Save();
    }

    private void Display()
    {
        if (headers.Count == 0)
        {
            Console.WriteLine("No data loaded.");
            return;
        }
        var colWidths = headers.Select(h => h.Length).ToArray();
        foreach (var row in rows)
        {
            for (int i = 0; i < row.Count && i < colWidths.Length; i++)
                if (row[i].Length > colWidths[i]) colWidths[i] = row[i].Length;
        }
        var sep = " | ";
        Console.WriteLine();
        var headerLine = string.Join(sep, headers.Select((h, i) => h.PadRight(colWidths[i])));
        Console.WriteLine(headerLine);
        Console.WriteLine(new string('-', headerLine.Length));
        foreach (var row in rows)
        {
            var cells = row.Select((c, i) => i < colWidths.Length ? c.PadRight(colWidths[i]) : "").ToArray();
            Console.WriteLine(string.Join(sep, cells));
        }
    }

    private void AddRow()
    {
        if (headers.Count == 0)
        {
            Console.WriteLine("No headers defined. Please add columns first.");
            return;
        }
        var row = new List<string>();
        foreach (var h in headers)
        {
            Console.Write($"Enter value for '{h}': ");
            row.Add(Console.ReadLine()?.Trim() ?? "");
        }
        rows.Add(row);
        Console.WriteLine("Row added.");
    }

    private void EditCell()
    {
        Display();
        Console.Write("Enter row index (1-based): ");
        if (!int.TryParse(Console.ReadLine(), out int rowIdx) || rowIdx < 1 || rowIdx > rows.Count)
        {
            Console.WriteLine("Invalid row index.");
            return;
        }
        rowIdx--;
        Console.WriteLine("Columns: " + string.Join(", ", headers));
        Console.Write("Enter column name: ");
        var colName = Console.ReadLine()?.Trim();
        var colIdx = headers.IndexOf(colName);
        if (colIdx == -1)
        {
            Console.WriteLine("Column not found.");
            return;
        }
        Console.Write($"Enter new value for '{colName}': ");
        var newVal = Console.ReadLine()?.Trim() ?? "";
        rows[rowIdx][colIdx] = newVal;
        Console.WriteLine("Cell updated.");
    }

    private void DeleteRow()
    {
        Display();
        Console.Write("Enter row index to delete (1-based): ");
        if (!int.TryParse(Console.ReadLine(), out int rowIdx) || rowIdx < 1 || rowIdx > rows.Count)
        {
            Console.WriteLine("Invalid row index.");
            return;
        }
        rows.RemoveAt(rowIdx - 1);
        Console.WriteLine("Row deleted.");
    }

    private void FilterRows()
    {
        if (rows.Count == 0)
        {
            Console.WriteLine("No rows to filter.");
            return;
        }
        Console.WriteLine("Columns: " + string.Join(", ", headers));
        Console.Write("Enter column name to filter: ");
        var colName = Console.ReadLine()?.Trim();
        var colIdx = headers.IndexOf(colName);
        if (colIdx == -1)
        {
            Console.WriteLine("Column not found.");
            return;
        }
        Console.Write("Enter value to match: ");
        var value = Console.ReadLine()?.Trim() ?? "";
        Console.Write("Case-sensitive? (y/n): ");
        var caseSensitive = Console.ReadLine()?.Trim().ToLower() == "y";
        var filtered = rows.Where(row => colIdx < row.Count &&
            (caseSensitive ? row[colIdx] == value : row[colIdx].ToLower() == value.ToLower())).ToList();
        if (filtered.Count == 0)
            Console.WriteLine("No matching rows.");
        else
        {
            var oldRows = rows;
            rows = filtered;
            Display();
            rows = oldRows;
        }
    }

    private void SortRows()
    {
        if (rows.Count == 0)
        {
            Console.WriteLine("No rows to sort.");
            return;
        }
        Console.WriteLine("Columns: " + string.Join(", ", headers));
        Console.Write("Enter column name to sort by: ");
        var colName = Console.ReadLine()?.Trim();
        var colIdx = headers.IndexOf(colName);
        if (colIdx == -1)
        {
            Console.WriteLine("Column not found.");
            return;
        }
        Console.Write("Sort descending? (y/n): ");
        var reverse = Console.ReadLine()?.Trim().ToLower() == "y";
        if (reverse)
            rows = rows.OrderByDescending(row => colIdx < row.Count ? row[colIdx] : "").ToList();
        else
            rows = rows.OrderBy(row => colIdx < row.Count ? row[colIdx] : "").ToList();
        Console.WriteLine("Rows sorted.");
    }

    private void AddColumn()
    {
        Console.Write("Enter new column name: ");
        var colName = Console.ReadLine()?.Trim();
        if (string.IsNullOrEmpty(colName))
        {
            Console.WriteLine("Invalid name.");
            return;
        }
        if (headers.Contains(colName))
        {
            Console.WriteLine("Column already exists.");
            return;
        }
        Console.Write("Enter default value for existing rows (leave empty for empty string): ");
        var defaultVal = Console.ReadLine()?.Trim() ?? "";
        headers.Add(colName);
        foreach (var row in rows)
            row.Add(defaultVal);
        Console.WriteLine("Column added.");
    }

    private void RemoveColumn()
    {
        if (headers.Count == 0)
        {
            Console.WriteLine("No columns to remove.");
            return;
        }
        Console.WriteLine("Columns: " + string.Join(", ", headers));
        Console.Write("Enter column name to remove: ");
        var colName = Console.ReadLine()?.Trim();
        var colIdx = headers.IndexOf(colName);
        if (colIdx == -1)
        {
            Console.WriteLine("Column not found.");
            return;
        }
        headers.RemoveAt(colIdx);
        foreach (var row in rows)
            if (colIdx < row.Count) row.RemoveAt(colIdx);
        Console.WriteLine("Column removed.");
    }

    private void Summary()
    {
        Console.WriteLine($"File: {filename ?? "(new)"}");
        Console.WriteLine($"Rows: {rows.Count}");
        Console.WriteLine($"Columns: {headers.Count}");
        if (headers.Count > 0)
            Console.WriteLine("Headers: " + string.Join(", ", headers));
    }

    public void Run()
    {
        Console.WriteLine("=== CSV Editor/Viewer ===");
        if (!string.IsNullOrEmpty(filename))
            Console.WriteLine($"Loaded: {filename} ({rows.Count} rows, {headers.Count} columns)");
        while (true)
        {
            Console.WriteLine("\nMenu:");
            Console.WriteLine("1. View table");
            Console.WriteLine("2. Add row");
            Console.WriteLine("3. Edit cell");
            Console.WriteLine("4. Delete row");
            Console.WriteLine("5. Filter rows");
            Console.WriteLine("6. Sort rows");
            Console.WriteLine("7. Add column");
            Console.WriteLine("8. Remove column");
            Console.WriteLine("9. Export / Save");
            Console.WriteLine("10. Show summary");
            Console.WriteLine("11. Exit");
            Console.Write("Choose: ");
            var choice = Console.ReadLine()?.Trim();
            switch (choice)
            {
                case "1": Display(); break;
                case "2": AddRow(); break;
                case "3": EditCell(); break;
                case "4": DeleteRow(); break;
                case "5": FilterRows(); break;
                case "6": SortRows(); break;
                case "7": AddColumn(); break;
                case "8": RemoveColumn(); break;
                case "9": Save(); break;
                case "10": Summary(); break;
                case "11":
                    Console.Write("Save before exit? (y/n): ");
                    if (Console.ReadLine()?.Trim().ToLower() == "y") Save();
                    Console.WriteLine("Goodbye!");
                    return;
                default: Console.WriteLine("Invalid choice."); break;
            }
        }
    }

    static void Main(string[] args)
    {
        var filename = args.Length > 0 ? args[0] : null;
        var editor = new CsvEditor(filename);
        editor.Run();
    }
}
