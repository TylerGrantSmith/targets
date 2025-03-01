% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tar_watch_server.R
\name{tar_watch_server}
\alias{tar_watch_server}
\title{Shiny module server for tar_watch()}
\usage{
tar_watch_server(
  id,
  height = "650px",
  exclude = ".Random.seed",
  config = Sys.getenv("TAR_CONFIG", "_targets.yaml"),
  project = Sys.getenv("TAR_PROJECT", "main")
)
}
\arguments{
\item{id}{Character of length 1, ID corresponding to the UI function
of the module.}

\item{height}{Character of length 1,
height of the \code{visNetwork} widget and branches table.}

\item{exclude}{Character vector of nodes to omit from the graph.}

\item{config}{Character of length 1, file path of the YAML
configuration file with \code{targets} project settings.
The \code{config} argument specifies which YAML configuration
file that \code{tar_config_get()} reads from or \code{tar_config_set()}
writes to in a single function call.
It does not globally change which configuration file is used
in subsequent function calls. The default file path of the YAML
file is always \verb{_targets.yaml} unless you set another
default path using the \code{TAR_CONFIG} environment variable,
e.g. \code{Sys.setenv(TAR_CONFIG = "custom.yaml")}. This also has the
effect of temporarily modifying the default arguments to other functions
such as \code{\link[=tar_make]{tar_make()}} because the default arguments
to those functions are controlled by \code{tar_config_get()}.}

\item{project}{Character of length 1, name of the current
\code{targets} project. Thanks to the \code{config} R package,
\code{targets} YAML configuration files can store multiple
sets of configuration settings, with each set corresponding
to its own project. The \code{project} argument allows you to
set or get a configuration setting for a specific project
for a given call to \code{tar_config_set()} or \code{tar_config_get()}.
The default project is always called \code{"main"}
unless you set another
default project using the \code{TAR_PROJECT} environment variable,
e.g. \code{Sys.setenv(tar_project = "custom")}. This also has the
effect of temporarily modifying the default arguments to other functions
such as \code{\link[=tar_make]{tar_make()}} because the default arguments
to those functions are controlled by \code{tar_config_get()}.}
}
\value{
A Shiny module server.
}
\description{
Use \code{\link[=tar_watch_ui]{tar_watch_ui()}} and \code{tar_watch_server()}
to include \code{\link[=tar_watch]{tar_watch()}} as a Shiny module in an app.
}
\seealso{
Other progress: 
\code{\link{tar_built}()},
\code{\link{tar_canceled}()},
\code{\link{tar_errored}()},
\code{\link{tar_poll}()},
\code{\link{tar_progress_branches}()},
\code{\link{tar_progress_summary}()},
\code{\link{tar_progress}()},
\code{\link{tar_skipped}()},
\code{\link{tar_started}()},
\code{\link{tar_watch_ui}()},
\code{\link{tar_watch}()}
}
\concept{progress}
