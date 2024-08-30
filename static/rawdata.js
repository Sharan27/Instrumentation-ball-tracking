document.getElementById('excelFileInput').addEventListener('change', handleFile);

function handleFile(event) {
  const file = event.target.files[0];
  const reader = new FileReader();

  reader.onload = function(e) {
    const data = new Uint8Array(e.target.result);

    // Use `XLSX.read` to parse the Excel data
    const workbook = XLSX.read(data, { type: 'array' });

    // Ensure sheet name retrieval is robust
    const sheetName = workbook.SheetNames[0] || 'Sheet1'; // Default to 'Sheet1' if not found
    const sheet = workbook.Sheets[sheetName];

    // Convert Excel sheet to JSON using `XLSX.utils.sheet_to_json`
    const jsonData = XLSX.utils.sheet_to_json(sheet);

    // Display extracted data in the table
    displayData(jsonData);
  };

  reader.readAsArrayBuffer(file);
}

function displayData(data) {
  const table = document.getElementById('dataDisplay').querySelector('table');
  const tbody = document.getElementById('dataDisplay').querySelector('tbody');

  // Clear existing data (optional, based on your requirement)
  tbody.innerHTML = '';

  // Check if data is empty
  if (!data || data.length === 0) {
    const emptyRow = document.createElement('tr');
    const emptyCell = document.createElement('td');
    emptyCell.textContent = 'No data found in the Excel sheet.';
    emptyCell.colSpan = 10; // Set colspan to match the number of table columns
    emptyRow.appendChild(emptyCell);
    tbody.appendChild(emptyRow);
    return;
  }

  const headers = Object.keys(data[0]);

  // Create table headers if they don't exist
  if (!table.querySelector('thead')) {
    const thead = document.createElement('thead');
    const headerRow = document.createElement('tr');
    headers.forEach(header => {
      const th = document.createElement('th');
      th.textContent = header;
      headerRow.appendChild(th);
    });
    thead.appendChild(headerRow);
    table.appendChild(thead);
  }

  // Create table rows and populate with data
  data.forEach(rowData => {
    const row = document.createElement('tr');
    headers.forEach(header => {
      const td = document.createElement('td');
      td.textContent = rowData[header];
      row.appendChild(td);
    });
    tbody.appendChild(row);
  });
  document.getElementById('clearDataButton').addEventListener('click', clearDisplayedData);
}
function clearDisplayedData() {
    const tbody = document.getElementById('dataDisplay').querySelector('tbody');
    tbody.innerHTML = '';
}

