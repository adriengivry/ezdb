% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/database.R
\docType{class}
\name{DatabaseConnection-class}
\alias{DatabaseConnection-class}
\alias{DatabaseConnection}
\title{DatabaseConnection Class}
\description{
A reference class to represent a connection to a database.
}
\section{Fields}{

\describe{
\item{\code{db_server}}{A DatabaseServer object representing the database server.}

\item{\code{db_name}}{The name of the database.}

\item{\code{db_user}}{The username for the database connection.}

\item{\code{db_password}}{The password for the database connection.}

\item{\code{connection}}{The MySQL connection object.}

\item{\code{connected}}{Boolean storing the connection status}
}}

\section{Methods}{

\describe{
\item{\code{authenticate_and_connect(db_user = NULL, db_password = NULL)}}{Authenticate the user using the provided credentials.}

\item{\code{connect()}}{      Connect to the database.

      This method establishes a connection to the database using the provided
      server, username, and password.
      }

\item{\code{disconnect()}}{Disconnect from the database and cleans up the connection object}

\item{\code{execute(query)}}{Execute a query on the database}

\item{\code{finalize()}}{      Finalize the DatabaseConnection object

      This method ensures that the database connection is properly closed when
      the object is garbage collected.
      }

\item{\code{initialize(
  db_server,
  db_name,
  db_user = NULL,
  db_password = NULL,
  keep_alive = FALSE
)}}{Initialize a DatabaseConnection object}

\item{\code{is_valid()}}{Returns TRUE if the connection is established and valid}
}}

