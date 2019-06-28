#' Run Scripts and RStudio Jobs with Pushbullet alerts
#'
#' @description
#' Functions, mostly to be used with RStudio Add-Ins, to run  scripts
#' with Pushbullet alerts. `source_` functions source in current session,
#' `bg_` functions in background session, and `job_. functions in the background
#' as RStudio jobs.   `_current_` functions use the current
#' RStudio editor pane, other functions take a script argument.
#'
#' These functions will issue a push alert using [RPushbullet::pbPost()].
#' See [here](https://github.com/eddelbuettel/rpushbullet#initialization) about
#' setting up Pushbullet with R - you just need to get an API key and run
#' [RPushbullet::pbSetup()].
#'
#' @details
#'
#' Note that these functions always run scripts in the current working directory.
#'
#' @param script_path The script to run. If NULL for `job_and_pb()` and
#'   `source_and_pb()`, prompts for a file interactively in the RStudio API.
#' @param ... passed on to [source()]
#' @export
#' @export
#' @rdname jobs
source_and_pb <- function(script_path = NULL, ...) {
  if (is.null(script_path)) script_path <- rstudioapi::selectFile()
  jobname <- paste("R Job:", basename(script_path))
  start <- Sys.time()
  withCallingHandlers(
    source(normalizePath(script_path), ...),
    error = function(e) {
      runtime <- Sys.time() - start
      RPushbullet::pbPost("note", jobname,
                          paste(as.character(e),"\nOccurred after",
                                round(as.double(runtime), 2),
                                attr(runtime, "units"))
                          )
      stop(e)
    }
  )
  runtime <- Sys.time() - start
  RPushbullet::pbPost("note", jobname,
                      paste( "This job has finished!\nRuntime of",
                             round(as.double(runtime), 2),
                             attr(runtime, "units")
                      ))
}

#' @export
#' @rdname jobs
source_current_and_pb <- function(...) {
  script_path <- current_rs_doc()
  source_and_pb(script_path, ...)
}

#' @export
#' @rdname jobs
bg_and_pb <- function(script_path = NULL) {
  if (is.null(script_path)) script_path <- rstudioapi::selectFile()
  callr::r_bg(
    function(z) pbjob::source_and_pb(z),
    args = list(z = normalizePath(script_path)),
    wd = getwd(),
    system_profile = TRUE, user_profile = TRUE,
    supervise = TRUE
  )
}

#' @export
#' @rdname jobs
bg_current_and_pb <- function() {
  script_path <- current_rs_doc()
  bg_and_pb(script_path = script_path)
}

#' @export
#' @rdname jobs
job_and_pb <- function(script_path = NULL) {
  if (is.null(script_path)) script_path <- rstudioapi::selectFile()
  job_name  <- paste("pbjob:", basename(script_path))
  tmpscript <- tempfile(fileext = ".R")
  cat(
    "pbjob::source_and_pb('", normalizePath(script_path), "')\n",
    file = tmpscript, sep = ""
  )
  rsjob <- rstudioapi::jobRunScript(tmpscript, name = job_name,
                                    workingDir = getwd())
}

#' @export
#' @rdname jobs
job_current_and_pb <- function() {
  script_path <- current_rs_doc()
  job_and_pb(script_path = script_path)
}

current_rs_doc <- function() {
  doc <- rstudioapi::getSourceEditorContext()
  if (doc$path == "") {
    tmp <- file.path(tempdir(), ".active-rstudio-document")
    writeLines(doc$contents, tmp)
    return(tmp)
  } else {
    return(doc$path)
  }
}

