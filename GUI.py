import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import mysql.connector
from datetime import datetime

class NovaPharmacyApp:
    def __init__(self, root):
        self.root = root
        self.root.title("NOVA Pharmacy Management System")
        self.root.geometry("1000x700")
        
        # Set up dark mode theme
        self.setup_dark_theme()
        
        # Database connection
        self.conn = None
        self.cursor = None
        
        # Create main frames
        self.create_frames()
        
        #Create widgets
        self.create_widgets()
        
        # Connect to database
        self.connect_to_database()

    def setup_dark_theme(self):
        # Define dark theme colors
        self.bg_color = "#000000"  # Dark background
        self.fg_color = "#ffffff"  # White text
        self.accent_color = "#3f51b5"  # Purple-blue accent
        self.success_color = "#4CAF50"  # Green for success actions
        self.frame_bg = "#000000"  # Slightly lighter grey for frames
        self.entry_bg = "#333333"  # Medium grey for entry fields
        self.hover_color = "#5c6bc0"  # Lighter accent for hover effects
        
        # Configure root with dark theme
        self.root.configure(bg=self.bg_color)
        
        # Configure ttk style
        self.style = ttk.Style()
        self.style.configure("TFrame", background=self.bg_color)
        self.style.configure("TLabel", background=self.bg_color, foreground=self.fg_color)
        self.style.configure("TLabelframe", background=self.bg_color, foreground=self.fg_color)
        self.style.configure("TLabelframe.Label", background=self.bg_color, foreground=self.fg_color)
        
        # Configure combobox style
        self.style.map('TCombobox', fieldbackground=[('readonly', self.entry_bg)])
        self.style.map('TCombobox', selectbackground=[('readonly', self.entry_bg)])
        self.style.map('TCombobox', selectforeground=[('readonly', self.fg_color)])
        
        # Configure dropdown menu colors
        self.root.option_add("*TCombobox*Listbox*Background", self.entry_bg)
        self.root.option_add("*TCombobox*Listbox*Foreground", self.fg_color)

    def connect_to_database(self):
        try:
            self.conn = mysql.connector.connect(
                host="",
                port=3306,
                user="",
                password="",  # Replace with your MySQL password
                database="nova"
            )
            self.cursor = self.conn.cursor(buffered=True)
            messagebox.showinfo("Connection", "Successfully connected to the database!")
        except mysql.connector.Error as err:
            messagebox.showerror("Database Connection Error", f"Error: {err}")

    def create_frames(self):
        # Top frame for database operations
        self.top_frame = tk.Frame(self.root, bg=self.bg_color, pady=10)
        self.top_frame.pack(fill=tk.X)
        
        # Middle frame for input fields
        self.middle_frame = tk.Frame(self.root, bg=self.bg_color, pady=10)
        self.middle_frame.pack(fill=tk.BOTH, expand=True)
        
        # We're removing the bottom_frame that previously held the results
        # Instead, we'll store results in memory and display them on demand


    def create_widgets(self):
        self.create_operation_widgets()
        self.create_input_widgets()
        self.create_report_buttons()


    def create_operation_widgets(self):
        # Frame for dropdowns
        dropdown_frame = tk.Frame(self.top_frame, bg=self.bg_color)
        dropdown_frame.pack(pady=10)
        
        # Operation dropdown (add, delete, update)
        tk.Label(dropdown_frame, text="Operation:", bg=self.bg_color, fg=self.fg_color, font=("Arial", 12)).grid(row=0, column=0, padx=10)
        self.operation_var = tk.StringVar()
        operations = ["Add", "Delete", "Update"]
        self.operation_dropdown = ttk.Combobox(dropdown_frame, textvariable=self.operation_var, values=operations, width=15, state="readonly")
        self.operation_dropdown.grid(row=0, column=1, padx=10)
        self.operation_dropdown.current(0)
        
        # Table dropdown
        tk.Label(dropdown_frame, text="Table:", bg=self.bg_color, fg=self.fg_color, font=("Arial", 12)).grid(row=0, column=2, padx=10)
        self.table_var = tk.StringVar()
        tables = ["Patient", "Doctor", "Pharmacy", "PharmaceuticalCompany", "Drug", "Prescription", "Contract", "Sells"]
        self.table_dropdown = ttk.Combobox(dropdown_frame, textvariable=self.table_var, values=tables, width=20, state="readonly")
        self.table_dropdown.grid(row=0, column=3, padx=10)
        self.table_dropdown.current(0)
        
        # Submit button for operation
        self.submit_btn = tk.Button(
            dropdown_frame, 
            text="Generate Form", 
            command=self.generate_form, 
            bg=self.success_color, 
            fg=self.fg_color, 
            font=("Arial", 12),
            relief=tk.FLAT,
            padx=15,
            pady=5,
            cursor="hand2"
        )
        self.results_btn = tk.Button(
            self.top_frame,
            text="Show Results",
            command=self.show_results_popup,
            bg="#808080",  # Gray (disabled appearance)
            fg=self.fg_color,
            font=("Arial", 12, "bold"),
            relief=tk.FLAT,
            padx=15,
            pady=5,
            cursor="arrow",  # Default cursor for disabled state
            state=tk.DISABLED  # Initially disabled
        )
        self.results_btn.pack(pady=10)
    
        # Store results data
        self.results_headers = None
        self.results_data = None
        self.has_results = False
        self.submit_btn.grid(row=0, column=4, padx=20)
        
        # Add hover effect
        self.submit_btn.bind("<Enter>", lambda e: self.submit_btn.config(bg="#66bb6a"))
        self.submit_btn.bind("<Leave>", lambda e: self.submit_btn.config(bg=self.success_color))
        
        # Bind events to dropdowns
        self.operation_dropdown.bind("<<ComboboxSelected>>", lambda e: self.clear_form())
        self.table_dropdown.bind("<<ComboboxSelected>>", lambda e: self.clear_form())

    def create_input_widgets(self):
        # This method will be called when generating forms
        # The actual input widgets will be created dynamically based on the selected operation and table
        pass

    def clear_form(self):
        # Clear only widgets in the middle frame
        for widget in self.middle_frame.winfo_children():
            widget.destroy()



    def generate_form(self):
        # Clear previous form
        self.clear_form()
        
        operation = self.operation_var.get()
        table = self.table_var.get()
        
        # Create a frame for the form with improved styling
        form_frame = tk.LabelFrame(
            self.middle_frame,
            text=f"{operation} {table}",
            font=("Arial", 12, "bold"),
            bg=self.frame_bg,
            fg=self.fg_color,
            padx=10,
            pady=10
        )
        form_frame.pack(fill=tk.BOTH, expand=False, padx=20, pady=10)  # Changed expand to False for more compact forms
        # Dictionary to store entry widgets
        self.entries = {}
        
        # Generate form fields based on table
        if table == "Patient":
            self.create_form_field(form_frame, "Patient ID (Aadhar):", "p_id", 0)
            if operation in ["Add", "Update"]:
                self.create_form_field(form_frame, "Name:", "p_name", 1)
                self.create_form_field(form_frame, "Age:", "p_age", 2)
                self.create_form_field(form_frame, "Address:", "p_address", 3)
                self.create_form_field(form_frame, "Primary Physician ID (Aadhar):", "p_primary_physician_id", 4)
                self.create_form_field(form_frame, "Additional Doctor ID (Optional):", "p_additional_doctor_id", 5)
        
        elif table == "Doctor":
            if operation in ["Add", "Update"]:
                self.create_form_field(form_frame, "Doctor ID (Aadhar):", "d_id", 0)
                self.create_form_field(form_frame, "Name:", "d_name", 1)
                self.create_form_field(form_frame, "Speciality:", "d_speciality", 2)
                self.create_form_field(form_frame, "Years of Experience:", "d_years_exp", 3)
                if operation == "Update":
                    self.create_form_field(form_frame, "Patient ID to Add (Optional):", "d_patient_id", 4)
            else:  # Delete
                self.create_form_field(form_frame, "Doctor ID (Aadhar):", "d_id", 0)
        
        elif table == "Pharmacy":
            if operation in ["Add", "Update"]:
                self.create_form_field(form_frame, "Pharmacy Name:", "ph_name", 0)
                self.create_form_field(form_frame, "Address:", "ph_address", 1)
                self.create_form_field(form_frame, "Phone:", "ph_phone", 2)
            else:  # Delete
                self.create_form_field(form_frame, "Pharmacy Address:", "ph_address", 0)
        
        elif table == "PharmaceuticalCompany":
            if operation in ["Add", "Update"]:
                self.create_form_field(form_frame, "Company Name:", "company_name", 0)
                self.create_form_field(form_frame, "Phone Number:", "company_phone", 1)
                if operation == "Update":
                    self.create_form_field(form_frame, "New Company Name:", "new_company_name", 2)
            else:  # Delete
                self.create_form_field(form_frame, "Company Name:", "company_name", 0)
        
        elif table == "Drug":
            if operation == "Add":
                self.create_form_field(form_frame, "Trade Name:", "trade_name", 0)
                self.create_form_field(form_frame, "Formula:", "formula", 1)
                self.create_form_field(form_frame, "Company Name:", "company_name", 2)
            else:  # Delete (Update not implemented for Drug in the SQL)
                self.create_form_field(form_frame, "Trade Name:", "trade_name", 0)
                self.create_form_field(form_frame, "Company Name:", "company_name", 1)
        
        elif table == "Prescription":
            if operation == "Add":
                self.create_form_field(form_frame, "Patient ID:", "p_id", 0)
                self.create_form_field(form_frame, "Doctor ID:", "d_id", 1)
                self.create_form_field(form_frame, "Prescription Date (YYYY-MM-DD):", "pres_date", 2)
                self.create_form_field(form_frame, "Drug ID:", "drug_id", 3)
                self.create_form_field(form_frame, "Quantity:", "quantity", 4)
            elif operation == "Update":
                self.create_form_field(form_frame, "Old Patient ID:", "old_p_id", 0)
                self.create_form_field(form_frame, "Old Doctor ID:", "old_d_id", 1)
                self.create_form_field(form_frame, "Old Prescription Date (YYYY-MM-DD):", "old_pres_date", 2)
                self.create_form_field(form_frame, "New Patient ID:", "new_p_id", 3)
                self.create_form_field(form_frame, "New Doctor ID:", "new_d_id", 4)
                self.create_form_field(form_frame, "New Prescription Date (YYYY-MM-DD):", "new_pres_date", 5)
                self.create_form_field(form_frame, "New Drug ID:", "new_drug_id", 6)
                self.create_form_field(form_frame, "New Quantity:", "new_quantity", 7)
            else:  # Delete
                self.create_form_field(form_frame, "Patient ID:", "p_id", 0)
                self.create_form_field(form_frame, "Doctor ID:", "d_id", 1)
                self.create_form_field(form_frame, "Prescription Date (YYYY-MM-DD):", "pres_date", 2)

        elif table == "Sells":
            if operation == "Add":
                self.create_form_field(form_frame, "Pharmacy Address:", "ph_address", 0)
                self.create_form_field(form_frame, "Drug ID:", "drug_id", 1)
                self.create_form_field(form_frame, "Stock:", "stock", 2)
                self.create_form_field(form_frame, "Price:", "price", 3)
            elif operation == "Delete":
                self.create_form_field(form_frame, "Pharmacy Address:", "ph_address", 0)
                self.create_form_field(form_frame, "Drug ID:", "drug_id", 1)
            elif operation == "Update":
                self.create_form_field(form_frame, "Pharmacy Address:", "ph_address", 0)
                self.create_form_field(form_frame, "Drug ID:", "drug_id", 1)
                self.create_form_field(form_frame, "New Stock:", "stock", 2)
                self.create_form_field(form_frame, "New Price:", "price", 3)
        
        elif table == "Contract":
            if operation in ["Add", "Update"]:
                self.create_form_field(form_frame, "Company Name:", "company_name", 0)
                self.create_form_field(form_frame, "Pharmacy Address:", "ph_address", 1)
                self.create_form_field(form_frame, "Content:", "content", 2, is_text=True)
                self.create_form_field(form_frame, "Start Date (YYYY-MM-DD):", "start_date", 3)
                self.create_form_field(form_frame, "End Date (YYYY-MM-DD):", "end_date", 4)
                self.create_form_field(form_frame, "Supervisor:", "supervisor", 5)
            else:  # Delete
                self.create_form_field(form_frame, "Company Name:", "company_name", 0)
                self.create_form_field(form_frame, "Pharmacy Address:", "ph_address", 1)
        
        # Add submit button

    
        # Add submit button with more compact styling
        submit_frame = tk.Frame(form_frame, bg=self.frame_bg)
        submit_frame.grid(row=100, column=0, columnspan=2, pady=10)  # Reduced padding
        
        submit_btn = tk.Button(
            submit_frame, 
            text=f"Submit {operation}",
            command=self.submit_form,
            bg=self.success_color,
            fg=self.fg_color,
            font=("Arial", 11),  # Slightly smaller font
            relief=tk.FLAT,
            padx=15,
            pady=5,  # Reduced padding
            cursor="hand2"
        )
        submit_btn.pack()
        
        # Add hover effect
        submit_btn.bind("<Enter>", lambda e: submit_btn.config(bg="#66bb6a"))
        submit_btn.bind("<Leave>", lambda e: submit_btn.config(bg=self.success_color))

    def create_form_field(self, parent, label_text, field_name, row, is_text=False):
        tk.Label(
            parent,
            text=label_text,
            bg=self.frame_bg,
            fg=self.fg_color,
            font=("Arial", 10)  # Smaller font
        ).grid(row=row, column=0, sticky="w", padx=8, pady=3)  # Reduced padding
        
        if is_text:
            entry = scrolledtext.ScrolledText(
                parent,
                width=35,  # Slightly smaller width
                height=3,   # Reduced height
                bg=self.entry_bg,
                fg=self.fg_color,
                insertbackground=self.fg_color,
                relief=tk.FLAT,
                borderwidth=1
            )
            entry.grid(row=row, column=1, sticky="w", padx=8, pady=3)  # Reduced padding
        else:
            entry = tk.Entry(
                parent,
                width=25,  # Slightly smaller width
                font=("Arial", 10),  # Smaller font
                bg=self.entry_bg,
                fg=self.fg_color,
                insertbackground=self.fg_color,
                relief=tk.FLAT,
                borderwidth=1
            )
            entry.grid(row=row, column=1, sticky="w", padx=8, pady=3)  # Reduced padding
        
        self.entries[field_name] = entry


    def create_result_widgets(self):
        # Create a frame for results
        result_frame = tk.LabelFrame(
            self.bottom_frame, 
            text="Results", 
            font=("Arial", 12, "bold"), 
            bg=self.frame_bg,
            fg=self.fg_color
        )
        result_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=10)
        
        # Create a scrolled text widget for displaying results
        self.result_text = scrolledtext.ScrolledText(
            result_frame, 
            width=100, 
            height=15,
            bg=self.entry_bg,
            fg=self.fg_color,
            insertbackground=self.fg_color,
            relief=tk.FLAT,
            borderwidth=1,
            font=("Consolas", 10)  # Monospaced font for better alignment
        )
        self.result_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)

    def create_report_buttons(self):
        # Create a frame for report buttons
        report_frame = tk.LabelFrame(
            self.top_frame, 
            text="Reports", 
            font=("Arial", 12, "bold"), 
            bg=self.frame_bg,
            fg=self.fg_color
        )
        report_frame.pack(fill=tk.X, padx=20, pady=10)
        
        # Create buttons for specific reports
        buttons = [
            ("Patient Prescriptions", self.patient_prescription_report),
            ("Prescription Details", self.prescription_details),
            ("Company Drugs", self.company_drugs),
            ("Pharmacy Stock", self.pharmacy_stock),
            ("Pharmacy Contact", self.pharmacy_contact),
            ("Doctor's Patients", self.doctor_patients),
            ("Display Contract", self.display_contract)
        ]
        
        # Create buttons in a grid layout
        for i, (text, command) in enumerate(buttons):
            btn = tk.Button(
                report_frame, 
                text=text, 
                command=command, 
                bg=self.accent_color, 
                fg=self.fg_color, 
                font=("Arial", 11),
                width=18,
                height=2,
                relief=tk.FLAT,
                cursor="hand2"
            )
            # Add hover effect
            btn.bind("<Enter>", lambda e, b=btn: b.config(bg=self.hover_color))
            btn.bind("<Leave>", lambda e, b=btn: b.config(bg=self.accent_color))
            
            row = i // 4
            col = i % 4
            btn.grid(row=row, column=col, padx=10, pady=10)

    def submit_form(self):
        operation = self.operation_var.get()
        table = self.table_var.get()
        
        try:
            # Get values from form fields
            values = self.get_form_values()
            
            # Call appropriate stored procedure based on operation and table
            if table == "Patient":
                if operation == "Add":
                    self.cursor.callproc('add_patient', [
                        values.get('p_id', ''),
                        values.get('p_name', ''),
                        int(values.get('p_age', 0)),
                        values.get('p_address', ''),
                        values.get('p_primary_physician_id', ''),
                        values.get('p_additional_doctor_id', None) if values.get('p_additional_doctor_id', '').strip() else None
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_patient', [values.get('p_id', '')])
                elif operation == "Update":
                    self.cursor.callproc('update_patient', [
                        values.get('p_id', ''),
                        values.get('p_name', ''),
                        int(values.get('p_age', 0)),
                        values.get('p_address', ''),
                        values.get('p_primary_physician_id', ''),
                        values.get('p_additional_doctor_id', None) if values.get('p_additional_doctor_id', '').strip() else None
                    ])
            
            elif table == "Doctor":
                if operation == "Add":
                    self.cursor.callproc('add_doctor', [
                        values.get('d_id', ''),
                        values.get('d_name', ''),
                        values.get('d_speciality', ''),
                        int(values.get('d_years_exp', 0))
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_doctor', [values.get('d_id', '')])
                elif operation == "Update":
                    self.cursor.callproc('update_doctor', [
                        values.get('d_id', ''),
                        values.get('d_name', ''),
                        values.get('d_speciality', ''),
                        int(values.get('d_years_exp', 0)),
                        values.get('d_patient_id', None)
                    ])
            
            elif table == "Pharmacy":
                if operation == "Add":
                    self.cursor.callproc('add_pharmacy', [
                        values.get('ph_name', ''),
                        values.get('ph_address', ''),
                        values.get('ph_phone', '')
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_pharmacy', [values.get('ph_address', '')])
                elif operation == "Update":
                    self.cursor.callproc('update_pharmacy', [
                        values.get('ph_address', ''),
                        values.get('ph_name', ''),
                        values.get('ph_phone', '')
                    ])
            
            elif table == "PharmaceuticalCompany":
                if operation == "Add":
                    self.cursor.callproc('add_company', [
                        values.get('company_name', ''),
                        values.get('company_phone', '')
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_company', [values.get('company_name', '')])
                elif operation == "Update":
                    self.cursor.callproc('update_company', [
                        values.get('company_name', ''),
                        values.get('new_company_name', ''),
                        values.get('company_phone', '')
                    ])
            
            elif table == "Drug":
                if operation == "Add":
                    self.cursor.callproc('add_drug', [
                        values.get('trade_name', ''),
                        values.get('formula', ''),
                        values.get('company_name', '')
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_drug', [
                        values.get('trade_name', ''),
                        values.get('company_name', '')
                    ])
            
            elif table == "Prescription":
                if operation == "Add":
                    self.cursor.callproc('add_prescription', [
                        values.get('p_id', ''),
                        values.get('d_id', ''),
                        values.get('pres_date', ''),
                        int(values.get('drug_id', 0)),
                        int(values.get('quantity', 0))
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_prescription', [
                        values.get('p_id', ''),
                        values.get('d_id', ''),
                        values.get('pres_date', '')
                    ])
                elif operation == "Update":
                    self.cursor.callproc('update_prescription', [
                        values.get('old_p_id', ''),
                        values.get('old_d_id', ''),
                        values.get('old_pres_date', ''),
                        values.get('new_p_id', ''),
                        values.get('new_d_id', ''),
                        values.get('new_pres_date', ''),
                        int(values.get('new_drug_id', 0)),
                        int(values.get('new_quantity', 0))
                    ])
            elif table == "Sells":
                if operation == "Add":
                    self.cursor.callproc('add_sells_entry', [
                        values.get('ph_address', ''),
                        int(values.get('drug_id', 0)),
                        int(values.get('stock', 0)),
                        float(values.get('price', 0))
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_sells_entry', [
                        values.get('ph_address', ''),
                        int(values.get('drug_id', 0))
                    ])
                elif operation == "Update":
                    # Assuming there's an update_sells_entry procedure
                    self.cursor.callproc('add_drug_to_pharmacy', [
                        int(values.get('drug_id', 0)),
                        values.get('ph_address', ''),
                        int(values.get('stock', 0)),
                        float(values.get('price', 0))
                    ])
            
            elif table == "Contract":
                if operation == "Add":
                    self.cursor.callproc('add_contract', [
                        values.get('company_name', ''),
                        values.get('ph_address', ''),
                        values.get('content', ''),
                        values.get('start_date', ''),
                        values.get('end_date', ''),
                        values.get('supervisor', '')
                    ])
                elif operation == "Delete":
                    self.cursor.callproc('delete_contract', [
                        values.get('company_name', ''),
                        values.get('ph_address', '')
                    ])
                elif operation == "Update":
                    self.cursor.callproc('update_contract', [
                        values.get('company_name', ''),
                        values.get('ph_address', ''),
                        values.get('content', ''),
                        values.get('start_date', ''),
                        values.get('end_date', ''),
                        values.get('supervisor', '')
                    ])
            
            # Commit the transaction
            self.conn.commit()
            messagebox.showinfo("Success", f"{operation} operation on {table} completed successfully!")
            
            # Clear the form
            self.clear_form()
            
        except mysql.connector.Error as err:
            self.conn.rollback()
            messagebox.showerror("Database Error", f"Error: {err}")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {e}")

    def get_form_values(self):
        values = {}
        for field_name, entry_widget in self.entries.items():
            if isinstance(entry_widget, scrolledtext.ScrolledText):
                values[field_name] = entry_widget.get("1.0", tk.END).strip()
            else:
                values[field_name] = entry_widget.get().strip()
        return values

    def display_results(self, headers, data):
        # Store the results instead of displaying them directly
        self.results_headers = headers
        self.results_data = data
        
        # Debug output
        print(f"Headers: {headers}")
        print(f"Data: {data}")
        
        # Enable and highlight the results button if we have data
        if data and len(data) > 0:
            self.has_results = True
            self.results_btn.config(
                state=tk.NORMAL,
                bg=self.accent_color,
                cursor="hand2"
            )
            # Add hover effect
            self.results_btn.bind("<Enter>", lambda e: self.results_btn.config(bg=self.hover_color))
            self.results_btn.bind("<Leave>", lambda e: self.results_btn.config(bg=self.accent_color))
        else:
            self.has_results = False
            self.results_btn.config(
                state=tk.DISABLED,
                bg="#808080",
                cursor="arrow"
            )
            # Remove hover effect
            self.results_btn.unbind("<Enter>")
            self.results_btn.unbind("<Leave>")

    def show_results_popup(self):
        if not self.has_results:
            return
        
        # Create a popup window for results
        popup = self.create_styled_popup("Query Results", "800x500")
        
        # Create a scrolled text widget for displaying results
        result_text = scrolledtext.ScrolledText(
            popup,
            width=90,
            height=25,
            bg=self.entry_bg,
            fg=self.fg_color,
            insertbackground=self.fg_color,
            relief=tk.FLAT,
            borderwidth=1,
            font=("Consolas", 10)  # Monospaced font for better alignment
        )
        result_text.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # Display results in the popup
        if not self.results_data:
            result_text.insert(tk.END, "No results found.\n")
            return
        
        # Format headers
        header_text = "  ".join(str(h).ljust(20) for h in self.results_headers)
        result_text.insert(tk.END, header_text + "\n")
        result_text.insert(tk.END, "-" * len(header_text) + "\n")
        
        # Format data
        for row in self.results_data:
            row_text = "  ".join(str(item).ljust(20) for item in row)
            result_text.insert(tk.END, row_text + "\n")
        
        # Add a close button
        close_btn = tk.Button(
            popup,
            text="Close",
            command=popup.destroy,
            bg=self.accent_color,
            fg=self.fg_color,
            font=("Arial", 11),
            relief=tk.FLAT,
            padx=20,
            pady=5,
            cursor="hand2"
        )
        close_btn.pack(pady=10)
        close_btn.bind("<Enter>", lambda e: close_btn.config(bg=self.hover_color))
        close_btn.bind("<Leave>", lambda e: close_btn.config(bg=self.accent_color))

    def create_styled_popup(self, title, geometry):
        popup = tk.Toplevel(self.root)
        popup.title(title)
        popup.geometry(geometry)
        popup.configure(bg=self.bg_color)
        
        return popup

    def patient_prescription_report(self):
        # Create a popup window for input
        popup = self.create_styled_popup("Patient Prescription Report", "400x200")
        
        tk.Label(popup, text="Patient ID:", bg=self.bg_color, fg=self.fg_color).grid(row=0, column=0, padx=10, pady=10)
        patient_id = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        patient_id.grid(row=0, column=1, padx=10, pady=10)
        
        tk.Label(popup, text="Start Date (YYYY-MM-DD):", bg=self.bg_color, fg=self.fg_color).grid(row=1, column=0, padx=10, pady=10)
        start_date = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        start_date.grid(row=1, column=1, padx=10, pady=10)
        
        tk.Label(popup, text="End Date (YYYY-MM-DD):", bg=self.bg_color, fg=self.fg_color).grid(row=2, column=0, padx=10, pady=10)
        end_date = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        end_date.grid(row=2, column=1, padx=10, pady=10)
        
        def submit():
            try:
                p_id = patient_id.get().strip()
                s_date = start_date.get().strip()
                e_date = end_date.get().strip()
                
                if not p_id or not s_date or not e_date:
                    messagebox.showerror("Error", "All fields are required!")
                    return
                
                self.cursor.callproc('prescription_report', [p_id, s_date, e_date])
                
                # Get results from the stored procedure
                for result in self.cursor.stored_results():
                    data = result.fetchall()
                    headers = [i[0] for i in result.description]
                    self.display_results(headers, data)
                
                popup.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")
        
        report_btn = tk.Button(
            popup, 
            text="Generate Report", 
            command=submit, 
            bg=self.success_color, 
            fg=self.fg_color,
            relief=tk.FLAT,
            cursor="hand2"
        )
        report_btn.grid(row=3, column=0, columnspan=2, pady=20)
        report_btn.bind("<Enter>", lambda e: report_btn.config(bg="#66bb6a"))
        report_btn.bind("<Leave>", lambda e: report_btn.config(bg=self.success_color))

    def display_contract(self):
        # Create a popup window for input
        popup = self.create_styled_popup("Display Contract", "450x180")
        
        tk.Label(popup, text="Pharmacy Name:", bg=self.bg_color, fg=self.fg_color).grid(row=0, column=0, padx=10, pady=10)
        pharmacy_name = tk.Entry(popup, width=25, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        pharmacy_name.grid(row=0, column=1, padx=10, pady=10)
        
        tk.Label(popup, text="Pharmacy Address:", bg=self.bg_color, fg=self.fg_color).grid(row=1, column=0, padx=10, pady=10)
        pharmacy_address = tk.Entry(popup, width=25, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        pharmacy_address.grid(row=1, column=1, padx=10, pady=10)
        
        tk.Label(popup, text="Company Name:", bg=self.bg_color, fg=self.fg_color).grid(row=2, column=0, padx=10, pady=10)
        company_name = tk.Entry(popup, width=25, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        company_name.grid(row=2, column=1, padx=10, pady=10)
        
        def submit():
            try:
                ph_name = pharmacy_name.get().strip()
                ph_address = pharmacy_address.get().strip()
                comp_name = company_name.get().strip()
                
                if not ph_name or not ph_address or not comp_name:
                    messagebox.showerror("Error", "All fields are required!")
                    return
                
                # Create a query to get contract information
                query = """
                SELECT 
                    c.company_name AS 'Company Name',
                    pc.phone_number AS 'Company Phone',
                    p.pname AS 'Pharmacy Name',
                    p.address AS 'Pharmacy Address',
                    p.phone AS 'Pharmacy Phone',
                    c.start_date AS 'Contract Start Date',
                    c.end_date AS 'Contract End Date',
                    c.supervisor AS 'Contract Supervisor',
                    c.content AS 'Contract Content',
                    CASE 
                        WHEN c.end_date < CURDATE() THEN 'Expired'
                        WHEN c.start_date > CURDATE() THEN 'Future'
                        ELSE 'Active'
                    END AS 'Contract Status',
                    DATEDIFF(c.end_date, CURDATE()) AS 'Days Remaining'
                FROM Contract c
                JOIN Pharmacy p ON c.ph_address = p.address
                JOIN PharmaceuticalCompany pc ON c.company_name = pc.company_name
                WHERE c.ph_address = %s
                AND p.pname = %s
                AND c.company_name = %s
                """
                
                self.cursor.execute(query, (ph_address, ph_name, comp_name))
                
                # Get results
                data = self.cursor.fetchall()
                
                if not data:
                    messagebox.showinfo("Information", "No contract exists between this pharmacy and pharmaceutical company")
                    return
                    
                headers = [i[0] for i in self.cursor.description]
                self.display_results(headers, data)
                
                popup.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")
        
        display_btn = tk.Button(
            popup, 
            text="Display Contract", 
            command=submit, 
            bg=self.success_color, 
            fg=self.fg_color,
            relief=tk.FLAT,
            cursor="hand2"
        )
        display_btn.grid(row=3, column=0, columnspan=2, pady=20)
        display_btn.bind("<Enter>", lambda e: display_btn.config(bg="#66bb6a"))
        display_btn.bind("<Leave>", lambda e: display_btn.config(bg=self.success_color))

    def prescription_details(self):
        # Create a popup window for input
        popup = self.create_styled_popup("Prescription Details", "400x150")
        
        tk.Label(popup, text="Patient ID:", bg=self.bg_color, fg=self.fg_color).grid(row=0, column=0, padx=10, pady=10)
        patient_id = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        patient_id.grid(row=0, column=1, padx=10, pady=10)
        
        tk.Label(popup, text="Prescription Date (YYYY-MM-DD):", bg=self.bg_color, fg=self.fg_color).grid(row=1, column=0, padx=10, pady=10)
        pres_date = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        pres_date.grid(row=1, column=1, padx=10, pady=10)
        
        def submit():
            try:
                p_id = patient_id.get().strip()
                date = pres_date.get().strip()
                
                if not p_id or not date:
                    messagebox.showerror("Error", "All fields are required!")
                    return
                
                self.cursor.callproc('print_pres_details', [p_id, date])
                
                # Get results from the stored procedure
                for result in self.cursor.stored_results():
                    data = result.fetchall()
                    headers = [i[0] for i in result.description]
                    self.display_results(headers, data)
                
                popup.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")
        
        details_btn = tk.Button(
            popup, 
            text="Get Details", 
            command=submit, 
            bg=self.success_color, 
            fg=self.fg_color,
            relief=tk.FLAT,
            cursor="hand2"
        )
        details_btn.grid(row=2, column=0, columnspan=2, pady=20)
        details_btn.bind("<Enter>", lambda e: details_btn.config(bg="#66bb6a"))
        details_btn.bind("<Leave>", lambda e: details_btn.config(bg=self.success_color))

    def company_drugs(self):
        # Create a popup window for input
        popup = self.create_styled_popup("Company Drugs", "400x120")
        
        tk.Label(popup, text="Company Name:", bg=self.bg_color, fg=self.fg_color).grid(row=0, column=0, padx=10, pady=10)
        company_name = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        company_name.grid(row=0, column=1, padx=10, pady=10)
        
        def submit():
            try:
                name = company_name.get().strip()
                
                if not name:
                    messagebox.showerror("Error", "Company name is required!")
                    return
                
                self.cursor.callproc('drug_details', [name])
                
                # Get results from the stored procedure
                for result in self.cursor.stored_results():
                    data = result.fetchall()
                    headers = [i[0] for i in result.description]
                    self.display_results(headers, data)
                
                popup.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")
        
        drugs_btn = tk.Button(
            popup, 
            text="Get Drugs", 
            command=submit, 
            bg=self.success_color, 
            fg=self.fg_color,
            relief=tk.FLAT,
            cursor="hand2"
        )
        drugs_btn.grid(row=1, column=0, columnspan=2, pady=20)
        drugs_btn.bind("<Enter>", lambda e: drugs_btn.config(bg="#66bb6a"))
        drugs_btn.bind("<Leave>", lambda e: drugs_btn.config(bg=self.success_color))

    def pharmacy_stock(self):
        # Create a popup window for input
        popup = self.create_styled_popup("Pharmacy Stock", "400x120")
        
        tk.Label(popup, text="Pharmacy Address:", bg=self.bg_color, fg=self.fg_color).grid(row=0, column=0, padx=10, pady=10)
        pharmacy_address = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        pharmacy_address.grid(row=0, column=1, padx=10, pady=10)
        
        def submit():
            try:
                address = pharmacy_address.get().strip()
                
                if not address:
                    messagebox.showerror("Error", "Pharmacy address is required!")
                    return
                
                self.cursor.callproc('print_stock_position', [address])
                
                # Get results from the stored procedure
                for result in self.cursor.stored_results():
                    data = result.fetchall()
                    headers = [i[0] for i in result.description]
                    self.display_results(headers, data)
                
                popup.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")
        
        stock_btn = tk.Button(
            popup, 
            text="Get Stock", 
            command=submit, 
            bg=self.success_color, 
            fg=self.fg_color,
            relief=tk.FLAT,
            cursor="hand2"
        )
        stock_btn.grid(row=1, column=0, columnspan=2, pady=20)
        stock_btn.bind("<Enter>", lambda e: stock_btn.config(bg="#66bb6a"))
        stock_btn.bind("<Leave>", lambda e: stock_btn.config(bg=self.success_color))

    def pharmacy_contact(self):
        # Create a popup window for input
        popup = self.create_styled_popup("Pharmacy Contact", "400x120")
        
        tk.Label(popup, text="Pharmacy Address:", bg=self.bg_color, fg=self.fg_color).grid(row=0, column=0, padx=10, pady=10)
        pharmacy_address = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        pharmacy_address.grid(row=0, column=1, padx=10, pady=10)
        
        def submit():
            try:
                address = pharmacy_address.get().strip()
                
                if not address:
                    messagebox.showerror("Error", "Pharmacy address is required!")
                    return
                
                self.cursor.callproc('print_pharmacy_contact', [address])
                
                # Get results from the stored procedure
                for result in self.cursor.stored_results():
                    data = result.fetchall()
                    headers = [i[0] for i in result.description]
                    self.display_results(headers, data)
                
                popup.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")
        
        contact_btn = tk.Button(
            popup, 
            text="Get Contact", 
            command=submit, 
            bg=self.success_color, 
            fg=self.fg_color,
            relief=tk.FLAT,
            cursor="hand2"
        )
        contact_btn.grid(row=1, column=0, columnspan=2, pady=20)
        contact_btn.bind("<Enter>", lambda e: contact_btn.config(bg="#66bb6a"))
        contact_btn.bind("<Leave>", lambda e: contact_btn.config(bg=self.success_color))

    def doctor_patients(self):
        # Create a popup window for input
        popup = self.create_styled_popup("Doctor's Patients", "400x120")
        
        tk.Label(popup, text="Doctor ID:", bg=self.bg_color, fg=self.fg_color).grid(row=0, column=0, padx=10, pady=10)
        doctor_id = tk.Entry(popup, width=20, bg=self.entry_bg, fg=self.fg_color, insertbackground=self.fg_color)
        doctor_id.grid(row=0, column=1, padx=10, pady=10)
        
        def submit():
            try:
                d_id = doctor_id.get().strip()
                
                if not d_id:
                    messagebox.showerror("Error", "Doctor ID is required!")
                    return
                
                self.cursor.callproc('print_patients_for_doctor', [d_id])
                
                # Get results from the stored procedure
                for result in self.cursor.stored_results():
                    data = result.fetchall()
                    headers = [i[0] for i in result.description]
                    self.display_results(headers, data)
                
                popup.destroy()
            except Exception as e:
                messagebox.showerror("Error", f"An error occurred: {e}")
        
        patients_btn = tk.Button(
            popup, 
            text="Get Patients", 
            command=submit, 
            bg=self.success_color, 
            fg=self.fg_color,
            relief=tk.FLAT,
            cursor="hand2"
        )
        patients_btn.grid(row=1, column=0, columnspan=2, pady=20)
        patients_btn.bind("<Enter>", lambda e: patients_btn.config(bg="#66bb6a"))
        patients_btn.bind("<Leave>", lambda e: patients_btn.config(bg=self.success_color))

def main():
    root = tk.Tk()
    app = NovaPharmacyApp(root)
    root.mainloop()

if __name__ == "__main__":
    main()
