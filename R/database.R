#' DatabaseServer Class
#'
#' A reference class to represent a database server.
#'
#' @field host The host address of the database server.
#' @field port The port number of the database server.
#' @export DatabaseServer
DatabaseServer <- setRefClass(
  "DatabaseServer",
  fields = list(
    host = "character",
    port = "numeric"
  ),
  methods = list(
    initialize = function(host = "localhost", port = 3306) {
      'Initialize a DatabaseServer object'
      .self$host <- host
      .self$port <- port
    }
  )
)

#' DatabaseConnection Class
#'
#' A reference class to represent a connection to a database.
#'
#' @field db_server A DatabaseServer object representing the database server.
#' @field db_name The name of the database.
#' @field db_user The username for the database connection.
#' @field db_password The password for the database connection.
#' @field connection The MySQL connection object.
#' @field connected Boolean storing the connection status
#' @export DatabaseConnection
DatabaseConnection <- setRefClass(
  "DatabaseConnection",
  fields = list(
    db_server = "DatabaseServer",
    db_name = "character",
    db_user = "character",
    db_password = "character",
    connection = "ANY",
    connected = "logical"
  ),
  methods = list(
    initialize = function(db_server, db_name, db_user = NULL, db_password = NULL) {
      'Initialize a DatabaseConnection object'
      library(RMySQL)

      .self$connection <- NULL
      .self$connected <- FALSE

      .self$db_server <- db_server
      .self$db_name <- db_name

      .self$authenticate_and_connect()

      on.exit(.self$finalize())
    },
    authenticate_and_connect = function(db_user = NULL, db_password = NULL) {
      '
      Authenticate the user using the provided credentials.
      '
      library(jsonlite)

      secrets <- tryCatch({
        fromJSON("secrets.json")
      }, error = function(e) {
        NULL
      })

      db_current_user <- db_user
      db_current_password <- db_password

      if (is.null(db_current_user)) {
        db_current_user <- if (!is.null(secrets) && !is.null(secrets$db_user)) secrets$db_user else NULL
        if (is.null(db_current_user)) {
          db_current_user <- readline("Database username: ")
        }
      }

      if (is.null(db_current_password)) {
        db_current_password <- if (!is.null(secrets) && !is.null(secrets$db_password)) secrets$db_password else NULL
        if (is.null(db_current_password)) {
          db_current_password <- readline("Database password: ")
        }
      }

      .self$db_user <- if (!is.null(db_current_user)) db_current_user else "guest"
      .self$db_password <- if (!is.null(db_current_password)) db_current_password else ""

      .self$connect()

      if (.self$is_valid()) {
        if (is.null(secrets) && (is.null(db_user) || is.null(db_password))) {
          save_credentials <- readline("Do you want to save these credentials? (Y/n): ")
          if (tolower(save_credentials) == "y") {
            write_json(list(db_user = .self$db_user, db_password = .self$db_password), "secrets.json")
            cat("Credentials saved to secrets.json\n")
          }
        }
      }
    },
    connect = function() {
      '
      Connect to the database.

      This method establishes a connection to the database using the provided
      server, username, and password.
      '
      .self$connection <- dbConnect(MySQL(), host = .self$db_server$host, port = .self$db_server$port, user = .self$db_user, password = .self$db_password, dbname = .self$db_name)
      cat(sprintf("Connected to %s@%s:%d\n", .self$db_user, .self$db_server$host, .self$db_server$port))
      if (dbIsValid(.self$connection)) {
        .self$connected <- TRUE
      }
    },
    execute = function(query) {
      'Execute a query on the database'
      return(dbGetQuery(.self$connection, query))
    },
    disconnect = function() {
      'Disconnect from the database and cleans up the connection object'
      if (.self$is_valid()) {
        cat(sprintf("Disconnected from %s@%s:%d\n", .self$db_user, .self$db_server$host, .self$db_server$port))
        dbDisconnect(.self$connection)
        .self$connected = FALSE
      }
    },
    is_valid = function() {
      'Returns TRUE if the connection is established and valid'
      return(.self$connected && !is.null(.self$connection) && dbIsValid(.self$connection))
    },
    finalize = function() {
      '
      Finalize the DatabaseConnection object

      This method ensures that the database connection is properly closed when
      the object is garbage collected.
      '
      .self$disconnect()
    }
  )
)

#' Execute a single query on the database
#'
#' This function creates a DatabaseConnection object, executes a single query,
#' and then finalizes the connection.
#'
#' @param query The SQL query to be executed.
#' @param db_server A DatabaseServer object representing the database server.
#' @param db_name The name of the database.
#' @param db_user The username for the database connection. Default is NULL.
#' @param db_password The password for the database connection. Default is NULL.
#' @return The result of the query.
#' @export
execute_single_query <- function(query, db_server, db_name, db_user = NULL, db_password = NULL) {
  db_connection <- DatabaseConnection$new(db_server, db_name, db_user, db_password)
  result <- db_connection$execute(query)
  db_connection$finalize()
  return(result)
}
