import pdfplumber
import pandas as pd
import os


# Function to extract transaction type from amount
def extract_transaction_type(amount):
    if amount.endswith('Cr'):
        return 'Credit'
    elif amount.endswith('Dr'):
        return 'Debit'
    return None


# Function to clean amount value by removing 'Cr' or 'Dr'
def clean_amount(amount):
    return amount.replace('Cr', '').replace('Dr', '').strip()


# List of PDF file paths (update with your file paths)
pdf_paths = [
    r'C:\Users\schandraraje\OneDrive - DXC Production\Documents\Credit Statements\Axis Myzone.pdf',
    r'C:\Users\schandraraje\OneDrive - DXC Production\Documents\Credit Statements\Axis rupay credit card.pdf',
    r'C:\Users\schandraraje\OneDrive - DXC Production\Documents\Credit Statements\ICICI Credit Card.pdf',
    r'C:\Users\schandraraje\OneDrive - DXC Production\Documents\Credit Statements\RBL Bank Ltd.pdf'
]

transactions = []

# Loop through each PDF file
for pdf_path in pdf_paths:
    credit_card_name = os.path.splitext(os.path.basename(pdf_path))[0]  # Extracts the PDF name for the Credit Card name

    with pdfplumber.open(pdf_path) as pdf:
        for page in pdf.pages:
            text = page.extract_text()
            if text:
                lines = text.split("\n")
                for line in lines:
                    if 'Dr' in line or 'Cr' in line:
                        parts = line.split()

                        # Assuming the structure: Date, Transaction Details, Merchant Category, Amount Dr/Cr
                        date = parts[0]
                        amount = parts[-2] + ' ' + parts[-1]  # Last two parts are amount and type
                        merchant_category = parts[-3]
                        transaction_details = ' '.join(parts[1:-3])  # Join everything between date and amount

                        transaction_type = extract_transaction_type(amount)
                        cleaned_amount = clean_amount(amount)

                        # Only append rows that have a valid transaction type (Credit or Debit)
                        if transaction_type:
                            transactions.append({
                                'Transaction Date': date,
                                'Transaction Details': transaction_details,
                                'Merchant Category': merchant_category,
                                'Transaction Amount': cleaned_amount,
                                'Transaction Type': transaction_type,
                                'Credit Card Name': credit_card_name  # Add credit card name column
                            })

# Create a DataFrame with all transactions
df = pd.DataFrame(transactions)

# Save the consolidated DataFrame to an Excel file
df.to_excel("consolidated_transactions.xlsx", index=False)

print("Consolidated spreadsheet created successfully.")
