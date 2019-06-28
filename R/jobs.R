#' Run Scripts and RStudio Jobs with Pushbullet alerts
#'
#' @description
#' Functions, mostly to be used with RStudio Add-Ins, to run  scripts
#' with Pushbullet alerts. `source_` functions source in current session,
#' `bg_` functions in background session.  `_current_` functions use the current
#' RStudio editor pane, other functions take a script argument.
#'
#' these functions will issue a push alert using [RPushbullet::pbPost()].
#' See [here](https://github.com/eddelbuettel/rpushbullet#initialization) about
#' setting up Pushbullet with R - you just need to get an API key and run
#' [RPushbullet::pbSetup()].
#'
#' @param script_path The script to run. If NULL for `job_and_pb()` and
#'   `source_and_pb()`, prompts for a file interactively in the RStudio API.
#' @param ... passed on to [source()]
#' @export
#' @export
#' @rdname jobs
source_and_pb <- function(script_path = NULL, ...) {
  if (is.null(script_path)) script_path <- rstudioapi::selectFile()
  jobname = paste("R Job:", basename(script_path))
  withCallingHandlers(
    source(normalizePath(script_path), ...),
    error = function(e) {
      RPushbullet::pbPost("note", jobname, as.character(e))
      stop(e)
    }
  )
  RPushbullet::pbPost("note", jobname, "This job has finished!")
}

#' @export
#' @rdname jobs
source_current_and_pb <- function(...) {
  script_path <- rstudioapi::getSourceEditorContext()$path
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
  script_path <- rstudioapi::getSourceEditorContext()$path
  bg_and_pb(script_path = script_path)
}
