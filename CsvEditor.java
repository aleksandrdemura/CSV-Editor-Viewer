// CsvEditor.java
import java.io.*;
import java.nio.file.*;
import java.util.*;

public class CsvEditor {
    private String filename;
    private List<String> headers;
    private List<List<String>> rows;
    private Scanner scanner;

    public CsvEditor(String filename) {
        this.filename = filename;
        headers = new ArrayList<>();
        rows = new ArrayList<>();
        scanner = new Scanner(System.in);
        if (filename != null && !filename.isEmpty() && Files.exists(Paths.get(filename)))
            load(filename);
        else
            createEmpty();
    }

    private void load(String filename) {
        try (BufferedReader br = new BufferedReader(new FileReader(filename))) {
            String line;
            if ((line = br.readLine()) != null) {
                headers = Arrays.asList(line.split(","));
                headers.replaceAll(String::trim);
            }
            while ((line = br.readLine()) != null) {
                if (!line.trim().isEmpty()) {
                    List<String> row = Arrays.asList(line.split(","));
                    row.replaceAll(String::trim);
                    rows.add(new ArrayList<>(row));
                }
            }
        } catch (IOException e) {
            System.out.println("Error loading file: " + e.getMessage());
        }
    }

    private void save(String filename) {
        if (filename == null || filename.isEmpty()) filename = this.filename;
        if (filename == null || filename.isEmpty()) {
            System.out.print("Enter filename to save: ");
            filename = scanner.nextLine().trim();
            if (!filename.endsWith(".csv")) filename += ".csv";
        }
        try (PrintWriter pw = new PrintWriter(new FileWriter(filename))) {
            pw.println(String.join(",", headers));
            for (List<String> row : rows)
                pw.println(String.join(",", row));
            System.out.println("Saved.");
        } catch (IOException e) {
            System.out.println("Error saving: " + e.getMessage());
        }
    }

    private void createEmpty() {
        System.out.println("Creating new CSV file.");
        System.out.print("Enter column headers (comma-separated): ");
        String input = scanner.nextLine().trim();
        if (input.isEmpty()) {
            headers = Arrays.asList("Column1", "Column2", "Column3");
        } else {
            headers = Arrays.asList(input.split(","));
            headers.replaceAll(String::trim);
        }
        rows = new ArrayList<>();
        save(filename != null ? filename : "new.csv");
    }

    private void display() {
        if (headers.isEmpty()) {
            System.out.println("No data loaded.");
            return;
        }
        int[] colWidths = headers.stream().mapToInt(String::length).toArray();
        for (List<String> row : rows) {
            for (int i = 0; i < row.size() && i < colWidths.length; i++) {
                if (row.get(i).length() > colWidths[i]) colWidths[i] = row.get(i).length();
            }
        }
        String sep = " | ";
        System.out.println();
        StringBuilder headerLine = new StringBuilder();
        for (int i = 0; i < headers.size(); i++) {
            headerLine.append(String.format("%-" + colWidths[i] + "s", headers.get(i)));
            if (i < headers.size() - 1) headerLine.append(sep);
        }
        System.out.println(headerLine);
        System.out.println("-".repeat(headerLine.length()));
        for (List<String> row : rows) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < headers.size(); i++) {
                String cell = i < row.size() ? row.get(i) : "";
                sb.append(String.format("%-" + colWidths[i] + "s", cell));
                if (i < headers.size() - 1) sb.append(sep);
            }
            System.out.println(sb);
        }
    }

    private void addRow() {
        if (headers.isEmpty()) {
            System.out.println("No headers defined. Please add columns first.");
            return;
        }
        List<String> row = new ArrayList<>();
        for (String h : headers) {
            System.out.print("Enter value for '" + h + "': ");
            row.add(scanner.nextLine().trim());
        }
        rows.add(row);
        System.out.println("Row added.");
    }

    private void editCell() {
        display();
        System.out.print("Enter row index (1-based): ");
        int rowIdx;
        try {
            rowIdx = Integer.parseInt(scanner.nextLine().trim()) - 1;
            if (rowIdx < 0 || rowIdx >= rows.size()) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            System.out.println("Invalid row index.");
            return;
        }
        System.out.println("Columns: " + String.join(", ", headers));
        System.out.print("Enter column name: ");
        String colName = scanner.nextLine().trim();
        int colIdx = headers.indexOf(colName);
        if (colIdx == -1) {
            System.out.println("Column not found.");
            return;
        }
        System.out.print("Enter new value for '" + colName + "': ");
        String newVal = scanner.nextLine().trim();
        rows.get(rowIdx).set(colIdx, newVal);
        System.out.println("Cell updated.");
    }

    private void deleteRow() {
        display();
        System.out.print("Enter row index to delete (1-based): ");
        int rowIdx;
        try {
            rowIdx = Integer.parseInt(scanner.nextLine().trim()) - 1;
            if (rowIdx < 0 || rowIdx >= rows.size()) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            System.out.println("Invalid row index.");
            return;
        }
        rows.remove(rowIdx);
        System.out.println("Row deleted.");
    }

    private void filterRows() {
        if (rows.isEmpty()) {
            System.out.println("No rows to filter.");
            return;
        }
        System.out.println("Columns: " + String.join(", ", headers));
        System.out.print("Enter column name to filter: ");
        String colName = scanner.nextLine().trim();
        int colIdx = headers.indexOf(colName);
        if (colIdx == -1) {
            System.out.println("Column not found.");
            return;
        }
        System.out.print("Enter value to match: ");
        String value = scanner.nextLine().trim();
        System.out.print("Case-sensitive? (y/n): ");
        boolean caseSensitive = scanner.nextLine().trim().equalsIgnoreCase("y");
        List<List<String>> filtered = new ArrayList<>();
        for (List<String> row : rows) {
            if (colIdx < row.size()) {
                String cell = row.get(colIdx);
                boolean match = caseSensitive ? cell.equals(value) : cell.equalsIgnoreCase(value);
                if (match) filtered.add(row);
            }
        }
        if (filtered.isEmpty()) {
            System.out.println("No matching rows.");
        } else {
            List<List<String>> oldRows = rows;
            rows = filtered;
            display();
            rows = oldRows;
        }
    }

    private void sortRows() {
        if (rows.isEmpty()) {
            System.out.println("No rows to sort.");
            return;
        }
        System.out.println("Columns: " + String.join(", ", headers));
        System.out.print("Enter column name to sort by: ");
        String colName = scanner.nextLine().trim();
        int colIdx = headers.indexOf(colName);
        if (colIdx == -1) {
            System.out.println("Column not found.");
            return;
        }
        System.out.print("Sort descending? (y/n): ");
        boolean reverse = scanner.nextLine().trim().equalsIgnoreCase("y");
        rows.sort((a, b) -> {
            String va = colIdx < a.size() ? a.get(colIdx) : "";
            String vb = colIdx < b.size() ? b.get(colIdx) : "";
            return reverse ? vb.compareTo(va) : va.compareTo(vb);
        });
        System.out.println("Rows sorted.");
    }

    private void addColumn() {
        System.out.print("Enter new column name: ");
        String colName = scanner.nextLine().trim();
        if (colName.isEmpty()) {
            System.out.println("Invalid name.");
            return;
        }
        if (headers.contains(colName)) {
            System.out.println("Column already exists.");
            return;
        }
        System.out.print("Enter default value for existing rows (leave empty for empty string): ");
        String defaultVal = scanner.nextLine().trim();
        headers.add(colName);
        for (List<String> row : rows) row.add(defaultVal);
        System.out.println("Column added.");
    }

    private void removeColumn() {
        if (headers.isEmpty()) {
            System.out.println("No columns to remove.");
            return;
        }
        System.out.println("Columns: " + String.join(", ", headers));
        System.out.print("Enter column name to remove: ");
        String colName = scanner.nextLine().trim();
        int colIdx = headers.indexOf(colName);
        if (colIdx == -1) {
            System.out.println("Column not found.");
            return;
        }
        headers.remove(colIdx);
        for (List<String> row : rows) row.remove(colIdx);
        System.out.println("Column removed.");
    }

    private void summary() {
        System.out.println("File: " + (filename != null ? filename : "(new)"));
        System.out.println("Rows: " + rows.size());
        System.out.println("Columns: " + headers.size());
        if (!headers.isEmpty()) System.out.println("Headers: " + String.join(", ", headers));
    }

    public void run() {
        System.out.println("=== CSV Editor/Viewer ===");
        if (filename != null && !filename.isEmpty())
            System.out.println("Loaded: " + filename + " (" + rows.size() + " rows, " + headers.size() + " columns)");
        while (true) {
            System.out.println("\nMenu:");
            System.out.println("1. View table");
            System.out.println("2. Add row");
            System.out.println("3. Edit cell");
            System.out.println("4. Delete row");
            System.out.println("5. Filter rows");
            System.out.println("6. Sort rows");
            System.out.println("7. Add column");
            System.out.println("8. Remove column");
            System.out.println("9. Export / Save");
            System.out.println("10. Show summary");
            System.out.println("11. Exit");
            System.out.print("Choose: ");
            String choice = scanner.nextLine().trim();
            switch (choice) {
                case "1": display(); break;
                case "2": addRow(); break;
                case "3": editCell(); break;
                case "4": deleteRow(); break;
                case "5": filterRows(); break;
                case "6": sortRows(); break;
                case "7": addColumn(); break;
                case "8": removeColumn(); break;
                case "9": save(null); break;
                case "10": summary(); break;
                case "11":
                    System.out.print("Save before exit? (y/n): ");
                    if (scanner.nextLine().trim().equalsIgnoreCase("y")) save(null);
                    System.out.println("Goodbye!");
                    return;
                default: System.out.println("Invalid choice.");
            }
        }
    }

    public static void main(String[] args) {
        String filename = args.length > 0 ? args[0] : null;
        CsvEditor editor = new CsvEditor(filename);
        editor.run();
    }
}
