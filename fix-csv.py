import csv
import os

def fix_csv(file_path):
    """Fix CSV files with European decimal notation (,) to use periods (.)"""
    # Read the entire file as text first to preserve original formatting
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Replace decimal commas in quoted values: "12,34" → 12.34
    import re
    content = re.sub(r'"(\d+),(\d+)"', r'\1.\2', content)
    
    # Overwrite the original file with the modified content
    with open(file_path, 'w', encoding='utf-8', newline='') as file:
        file.write(content)
    
    print(f"Fixed {file_path}")

# List of CSV files to process
csv_files = [
    "Products.csv",
    "OrderDetails.csv",
    "Orders.csv"
]

for csv_file in csv_files:
    file_path = os.path.join(r"E:\dwh_project\datasets", csv_file)
    fix_csv(file_path)



    FORMAT(UnitPrice, 'N2', 'en-US') AS UnitPrice,