// csv_editor.js
const fs = require('fs');
const readline = require('readline');

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

class CSVEditor {
    constructor(filename) {
        this.filename = filename;
        this.headers = [];
        this.rows = [];
        if (filename && fs.existsSync(filename)) {
            this.load(filename);
        } else if (filename) {
            this.createEmpty();
        } else {
            this.createEmpty();
        }
    }

    load(filename) {
        const content = fs.readFileSync(filename, 'utf8');
        const lines = content.split('\n').filter(line => line.trim() !== '');
        if (lines.length > 0) {
            this.headers = lines[0].split(',').map(h => h.trim());
            this.rows = lines.slice(1).map(line => line.split(',').map(c => c.trim()));
        } else {
            this.headers = [];
            this.rows = [];
        }
    }

    save(filename) {
        if (!filename) filename = this.filename;
        if (!filename) {
            console.log('No filename provided.');
            return;
        }
        const lines = [];
        lines.push(this.headers.join(','));
        this.rows.forEach(row => lines.push(row.join(',')));
        fs.writeFileSync(filename, lines.join('\n'), 'utf8');
        console.log('Saved.');
    }

    createEmpty() {
        console.log('Creating new CSV file.');
        this.askQuestion('Enter column headers (comma-separated): ', (answer) => {
            const parts = answer.split(',').map(h => h.trim()).filter(h => h);
            this.headers = parts.length ? parts : ['Column1', 'Column2', 'Column3'];
            this.rows = [];
            this.save(this.filename || 'new.csv');
            this.run();
        });
    }

    askQuestion(question, callback) {
        rl.question(question, callback);
    }

    display() {
        if (this.headers.length === 0) {
            console.log('No data loaded.');
            return;
        }
        const colWidths = this.headers.map(h => h.length);
        this.rows.forEach(row => {
            row.forEach((cell, i) => {
                if (i < colWidths.length && cell.length > colWidths[i]) {
                    colWidths[i] = cell.length;
                }
            });
        });
        const sep = ' | ';
        console.log();
        console.log(this.headers.map((h, i) => h.padEnd(colWidths[i])).join(sep));
        console.log(colWidths.map(w => '-'.repeat(w)).join('-+-'));
        this.rows.forEach(row => {
            const cells = row.map((c, i) => (i < colWidths.length ? c : '').padEnd(colWidths[i] || 0));
            console.log(cells.join(sep));
        });
    }

    addRow() {
        if (this.headers.length === 0) {
            console.log('No headers defined. Please add columns first.');
            return;
        }
        const row = [];
        const askNext = (index) => {
            if (index >= this.headers.length) {
                this.rows.push(row);
                console.log('Row added.');
                this.run();
                return;
            }
            this.askQuestion(`Enter value for '${this.headers[index]}': `, (val) => {
                row.push(val.trim());
                askNext(index + 1);
            });
        };
        askNext(0);
    }

    editCell() {
        this.display();
        this.askQuestion('Enter row index (1-based): ', (rowIdxStr) => {
            const rowIdx = parseInt(rowIdxStr) - 1;
            if (isNaN(rowIdx) || rowIdx < 0 || rowIdx >= this.rows.length) {
                console.log('Invalid row index.');
                this.run();
                return;
            }
            console.log('Columns:', this.headers.join(', '));
            this.askQuestion('Enter column name: ', (colName) => {
                const colIdx = this.headers.indexOf(colName.trim());
                if (colIdx === -1) {
                    console.log('Column not found.');
                    this.run();
                    return;
                }
                this.askQuestion(`Enter new value for '${colName}': `, (newVal) => {
                    this.rows[rowIdx][colIdx] = newVal.trim();
                    console.log('Cell updated.');
                    this.run();
                });
            });
        });
    }

    deleteRow() {
        this.display();
        this.askQuestion('Enter row index to delete (1-based): ', (idxStr) => {
            const idx = parseInt(idxStr) - 1;
            if (isNaN(idx) || idx < 0 || idx >= this.rows.length) {
                console.log('Invalid row index.');
                this.run();
                return;
            }
            this.rows.splice(idx, 1);
            console.log('Row deleted.');
            this.run();
        });
    }

    filterRows() {
        if (this.rows.length === 0) {
            console.log('No rows to filter.');
            this.run();
            return;
        }
        console.log('Columns:', this.headers.join(', '));
        this.askQuestion('Enter column name to filter: ', (colName) => {
            const colIdx = this.headers.indexOf(colName.trim());
            if (colIdx === -1) {
                console.log('Column not found.');
                this.run();
                return;
            }
            this.askQuestion('Enter value to match: ', (value) => {
                this.askQuestion('Case-sensitive? (y/n): ', (caseSens) => {
                    const sensitive = caseSens.trim().toLowerCase() === 'y';
                    const filtered = this.rows.filter(row => {
                        if (colIdx >= row.length) return false;
                        const cell = row[colIdx];
                        return sensitive ? cell === value : cell.toLowerCase() === value.toLowerCase();
                    });
                    if (filtered.length === 0) {
                        console.log('No matching rows.');
                    } else {
                        const oldRows = this.rows;
                        this.rows = filtered;
                        this.display();
                        this.rows = oldRows;
                    }
                    this.run();
                });
            });
        });
    }

    sortRows() {
        if (this.rows.length === 0) {
            console.log('No rows to sort.');
            this.run();
            return;
        }
        console.log('Columns:', this.headers.join(', '));
        this.askQuestion('Enter column name to sort by: ', (colName) => {
            const colIdx = this.headers.indexOf(colName.trim());
            if (colIdx === -1) {
                console.log('Column not found.');
                this.run();
                return;
            }
            this.askQuestion('Sort descending? (y/n): ', (reverseStr) => {
                const reverse = reverseStr.trim().toLowerCase() === 'y';
                this.rows.sort((a, b) => {
                    const valA = colIdx < a.length ? a[colIdx] : '';
                    const valB = colIdx < b.length ? b[colIdx] : '';
                    if (reverse) return valB.localeCompare(valA);
                    return valA.localeCompare(valB);
                });
                console.log('Rows sorted.');
                this.run();
            });
        });
    }

    addColumn() {
        this.askQuestion('Enter new column name: ', (colName) => {
            colName = colName.trim();
            if (!colName) {
                console.log('Invalid name.');
                this.run();
                return;
            }
            if (this.headers.includes(colName)) {
                console.log('Column already exists.');
                this.run();
                return;
            }
            this.askQuestion('Enter default value for existing rows (leave empty for empty string): ', (defaultVal) => {
                this.headers.push(colName);
                this.rows.forEach(row => row.push(defaultVal.trim()));
                console.log('Column added.');
                this.run();
            });
        });
    }

    removeColumn() {
        if (this.headers.length === 0) {
            console.log('No columns to remove.');
            this.run();
            return;
        }
        console.log('Columns:', this.headers.join(', '));
        this.askQuestion('Enter column name to remove: ', (colName) => {
            const colIdx = this.headers.indexOf(colName.trim());
            if (colIdx === -1) {
                console.log('Column not found.');
                this.run();
                return;
            }
            this.headers.splice(colIdx, 1);
            this.rows.forEach(row => row.splice(colIdx, 1));
            console.log('Column removed.');
            this.run();
        });
    }

    summary() {
        console.log(`File: ${this.filename || '(new)'}`);
        console.log(`Rows: ${this.rows.length}`);
        console.log(`Columns: ${this.headers.length}`);
        if (this.headers.length) console.log('Headers:', this.headers.join(', '));
        this.run();
    }

    run() {
        console.log('\n=== CSV Editor/Viewer ===');
        if (this.filename) {
            console.log(`Loaded: ${this.filename} (${this.rows.length} rows, ${this.headers.length} columns)`);
        } else {
            console.log('No file loaded.');
        }
        console.log('\nMenu:');
        console.log('1. View table');
        console.log('2. Add row');
        console.log('3. Edit cell');
        console.log('4. Delete row');
        console.log('5. Filter rows');
        console.log('6. Sort rows');
        console.log('7. Add column');
        console.log('8. Remove column');
        console.log('9. Export / Save');
        console.log('10. Show summary');
        console.log('11. Exit');
        this.askQuestion('Choose: ', (choice) => {
            switch (choice.trim()) {
                case '1': this.display(); this.run(); break;
                case '2': this.addRow(); break;
                case '3': this.editCell(); break;
                case '4': this.deleteRow(); break;
                case '5': this.filterRows(); break;
                case '6': this.sortRows(); break;
                case '7': this.addColumn(); break;
                case '8': this.removeColumn(); break;
                case '9': this.save(); this.run(); break;
                case '10': this.summary(); break;
                case '11':
                    this.askQuestion('Save before exit? (y/n): ', (save) => {
                        if (save.trim().toLowerCase() === 'y') this.save();
                        console.log('Goodbye!');
                        rl.close();
                    });
                    break;
                default: console.log('Invalid choice.'); this.run(); break;
            }
        });
    }
}

function main() {
    const filename = process.argv[2];
    const editor = new CSVEditor(filename);
    // If createEmpty was called, it calls run internally; otherwise we start run.
    // But the constructor calls createEmpty which calls run, so we don't call again.
}

main();
