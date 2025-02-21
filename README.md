# ezdb

A simple R MySQL database wrapper with a user-friendly authentication layer 

## Overview

`ezdb` is an R package designed to simplify interactions with MySQL databases. It provides a convenient way to manage database connections and execute queries, focusing on ease of use and security. The package includes an authentication layer that supports both file-based and interactive login methods, ensuring that your credentials are handled securely.

## Features
- Encapsulates database connection logic in a convenient way
- Authentication layer:
    - Using a `secrets.json` file
    - Or by typing the database login credentials in the terminal
- Follows the RAII idiom: automatically closes the database connection when the connection instance is destroyed

## Installation

1. Make sure you have R installed. You can download R from the official website: [https://www.r-project.org/](https://www.r-project.org/)

2. Install the devtools package:

    ```R
    install.packages("devtools")
    ```

3. Install the ezdb package:

    ```R
    devtools::install_github("adriengivry/ezdb")
    ```

## Usage

1. In your R script or interactive session, load the `ezdb` package:

    ```R
    library(ezdb)
    ```

2. Create a database server instance (stores info about your server):

    ```R
    db_server <- DatabaseServer$new("host.server.url", 3306) # <-- 3306 being the default port
    ```

3. Create a database connection instance:

    ```R
    db_connection <- DatabaseConnection$new(db_server, "my_database")
    ```

4. Execute a query:

    ```R
    query_result <- db_connection$execute("SELECT * FROM person")
    ```

5. Or, execute a query in a single line without a database connection:

    ```R
    execute_single_query("SELECT * FROM person", db_server, "my_database")
    ```
    _Note: not recommended when you need to execute multiple queries, as each invocation will connect/disconnect from your target server_

## Storing credentials
Login credentials can be stored in a `secrets.json` file located at the root of your R project.
This file should be formatted as:
```json
{
    "db_user": "guest",
    "db_password": "123456"
}
```
If your R project is versioned, make sure to add the `secrets.json` file to your `.gitignore`!