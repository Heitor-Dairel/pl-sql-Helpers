# Heitor Library PL/SQL Package

## Overview
The `HEITOR_LIBRARY` package is a collection of utility functions designed to simplify common date-related operations and other calculations in PL/SQL. This library provides functionality such as leap year determination, business day adjustments, and movable holiday calculations, among others.

The package is divided into two components:
- **Specification (`PCK_HEITOR_LIBRARY_SPEC.sql`)**: Defines the public interface for the package.
- **Body (`PCK_HEITOR_LIBRARY_BODY.sql`)**: Contains the implementation of the package's functions.

## Features
### Key Functions
1. **`BISSEXTOX`**
   - **Description**: Determines whether a given year is a leap year.
   - **Input**: Year as a string.
   - **Output**: Returns a string indicating the result.

2. **`CHRONOS`**
   - **Description**: Adjusts a given date based on business day rules, supporting options for skipping holidays and weekends.
   - **Inputs**:
     - `DATA`: The base date.
     - `SKIP_BUSINESS_DAY`: Specifies how to handle non-business days (default: 2).
     - `SIGN`: Adjustment direction (default: 1).
     - `DAYS`: Number of days to adjust (optional).
   - **Output**: Returns the adjusted date.

3. **`PASCHALIS_CALCULUS`**
   - **Description**: Calculates Easter and related movable holidays for a given year.
   - **Inputs**:
     - `YEAR`: Year for the calculation.
     - `HOLIDAY_TYPE`: Specifies the type of holiday (optional).
   - **Output**: Returns the date of the specified holiday.

### Holiday Table Dependency (`TB_CALENDARIO_FERIADOS`)

Some functions, such as `CHRONOS`, rely on a table called `TB_CALENDARIO_FERIADOS` to identify holidays. This table is used to skip non-business days based on holiday definitions.

#### Important:
The `TB_CALENDARIO_FERIADOS` table is **not included** in the database by default. You must update the table name and field references in the package code to match the structure of your own holiday table.
If your table has a different name or structure, make sure to update all references to `TB_CALENDARIO_FERIADOS` in the package body.

## Files
1. **`PCK_HEITOR_LIBRARY_SPEC.sql`**: Contains the package specification, defining the functions and procedures available.
2. **`PCK_HEITOR_LIBRARY_BODY.sql`**: Implements the logic for the functions defined in the specification.

## Usage
To use the `HEITOR_LIBRARY` package, follow these steps:
1. Deploy the specification and body files to your Oracle database.
2. Call the desired functions using SQL or PL/SQL, as needed.

### Example
```sql
-- Check if a year is a leap year
DECLARE
  result VARCHAR2(10);
BEGIN
  result := HEITOR_LIBRARY.BISSEXTOX('2024');
  DBMS_OUTPUT.PUT_LINE('Leap year result: ' || result);
END;

-- Calculate Easter for a given year
DECLARE
  easter_date DATE;
BEGIN
  easter_date := HEITOR_LIBRARY.PASCHALIS_CALCULUS('2025');
  DBMS_OUTPUT.PUT_LINE('Easter 2025: ' || TO_CHAR(easter_date, 'YYYY-MM-DD'));
END;
```

## Installation
1. Open your preferred SQL client.
2. Run `PCK_HEITOR_LIBRARY_SPEC.sql` to create the package specification.
3. Run `PCK_HEITOR_LIBRARY_BODY.sql` to create the package body.

## License
This project is licensed under the [MIT License](LICENSE). Feel free to use, modify, and distribute the code.

## Contributing
Contributions are welcome! If you have suggestions or improvements, feel free to submit a pull request or open an issue on GitHub.
