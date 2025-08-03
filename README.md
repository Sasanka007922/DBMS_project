# DBMS_project

## User and Password
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


## Add Your Username and Password for the MySQL Login
