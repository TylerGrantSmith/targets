store_init <- function(format = "rds", resources = list()) {
  store_new(
    class = as_class(format),
    file = file_init(),
    resources = resources
  )
}

store_new <- function(class, file = NULL, resources = NULL) {
  UseMethod("store_new")
}

#' @export
store_new.default <- function(class, file = NULL, resources = NULL) {
  store_new_default(file, resources)
}

store_new_default <- function(file, resources) {
  force(file)
  force(resources)
  enclass(environment(), "tar_store")
}

store_assert_format_setting <- function(class) {
  UseMethod("store_assert_format_setting")
}

#' @export
store_assert_format_setting.default <- function(class) {
  tar_throw_validate("unsupported format")
}

store_read_object <- function(store) {
  UseMethod("store_read_object")
}

store_read_object.default <- function(store) {
  store_cast_object(store, store_read_path(store, store$file$path))
}

store_read_path <- function(store, path) {
  UseMethod("store_read_path")
}

store_write_object <- function(store, object) {
  UseMethod("store_write_object")
}

#' @export
store_write_object.default <- function(store, object) {
  path <- store$file$path
  stage <- store$file$stage
  dir_create(dirname(path))
  dir_create(dirname(stage))
  store_write_path(store, store_cast_object(store, object), stage)
  file.rename(stage, path)
}

store_write_path <- function(store, object, path) {
  UseMethod("store_write_path")
}

store_upload_object <- function(store) {
  UseMethod("store_upload_object")
}

store_upload_object.default <- function(store) {
}

store_update_path <- function(store, name, object, path_store) {
  store$file$path <- store_produce_path(store, name, object, path_store)
}

store_produce_path <- function(store, name, object, path_store) {
  UseMethod("store_produce_path")
}

#' @export
store_produce_path.default <- function(store, name, object, path_store) {
  path_objects(path_store = path_store, name = name)
}

store_row_path <- function(store) {
  UseMethod("store_row_path")
}

#' @export
store_row_path.default <- function(store) {
  NA_character_
}

store_path_from_record <- function(store, record, path_store) {
  UseMethod("store_path_from_record")
}

#' @export
store_path_from_record.default <- function(store, record, path_store) {
  path_objects(path_store = path_store, name = record$name)
}

store_tar_path <- function(store, target, path_store) {
  UseMethod("store_tar_path")
}

#' @export
store_tar_path.default <- function(store, target, path_store) {
  path_objects(path_store = path_store, name = target_get_name(target))
}

store_update_stage_early <- function(store, name, path_store) {
  UseMethod("store_update_stage_early")
}

#' @export
store_update_stage_early.default <- function(store, name, path_store) {
  store$file$stage <- store_produce_stage(
    store = store,
    name = name,
    object = NULL,
    path_store = path_store
  )
}

store_update_stage_late <- function(store, name, object, path_store) {
  UseMethod("store_update_stage_late")
}

#' @export
store_update_stage_late.default <- function(store, name, object, path_store) {
}

#' @export
store_update_stage_early.default <- function(store, name, path_store) {
  store$file$stage <- store_produce_stage(
    store = store,
    name = name,
    object = NULL,
    path_store = path_store
  )
}

store_produce_stage <- function(store, name, object, path_store) {
  UseMethod("store_produce_stage")
}

#' @export
store_produce_stage.default <- function(store, name, object, path_store) {
  path_scratch(path_store = path_store, pattern = name)
}

store_cast_object <- function(store, object) {
  UseMethod("store_cast_object")
}

store_cast_object.default <- function(store, object) {
  object
}

store_assert_format <- function(store, object, name) {
  UseMethod("store_assert_format")
}

#' @export
store_assert_format.default <- function(store, object, name) {
}

store_hash_early <- function(store) {
  UseMethod("store_hash_early")
}

#' @export
store_hash_early.default <- function(store) {
}

store_hash_late <- function(store) {
  UseMethod("store_hash_late")
}

#' @export
store_hash_late.default <- function(store) {
  tar_assert_path(store$file$path)
  file_update_hash(store$file)
}

store_ensure_correct_hash <- function(
  store,
  storage,
  deployment
) {
  UseMethod("store_ensure_correct_hash")
}

#' @export
store_ensure_correct_hash.default <- function(store, storage, deployment) {
  if (identical(storage, "worker") && identical(deployment, "worker")) {
    store_wait_correct_hash(store)
  }
}

store_wait_correct_hash <- function(store, sleep = 0.01, timeout = 60) {
  time_left <- timeout
  while (time_left > 0) {
    if (store_has_correct_hash(store)) {
      return(invisible())
    }
    Sys.sleep(sleep)
    time_left <- time_left - sleep
  }
  msg <- paste(
    "Path",
    paste(store$file$path, collapse = " "),
    "does not exist or has incorrect hash.",
    "File sync timed out."
  )
  tar_throw_file(msg)
}

store_has_correct_hash <- function(store) {
  UseMethod("store_has_correct_hash")
}

#' @export
store_has_correct_hash.default <- function(store) {
  all(file.exists(store$file$path)) && file_has_correct_hash(store$file)
}

store_sync_file_meta <- function(store, target, meta) {
  UseMethod("store_sync_file_meta")
}

#' @export
store_sync_file_meta.default <- function(store, target, meta) {
  cue <- target$cue
  if (identical(cue$mode, "never") || identical(cue$file, FALSE)) {
    return()
  }
  name <- target_get_name(target)
  record <- meta$get_record(name)
  file <- file_init(
    path = record$path,
    time = record$time,
    size = record$size,
    bytes = record$bytes
  )
  info <- file_info(target$store$file$path)
  time <- file_time(info)
  bytes <- file_bytes(info)
  size <- file_size(bytes)
  # Fully automated tests do no use big files.
  # Tested in tests/interactive/test-file.R. # nolint
  # nocov start
  if (!identical(time, file$time) || !identical(size, file$size)) {
    record$time <- time
    record$size <- size
    record$bytes <- bytes
    meta$insert_record(record)
  }
  # nocov end
}

store_unload <- function(store, target) {
  UseMethod("store_unload")
}

#' @export
store_unload.default <- function(store, target) {
}

store_serialize_object <- function(store, object) {
  UseMethod("store_serialize_object")
}

#' @export
store_serialize_object.default <- function(store, object) {
  object
}

store_unserialize_object <- function(store, object) {
  UseMethod("store_unserialize_object")
}

#' @export
store_unserialize_object.default <- function(store, object) {
  object
}

store_serialize_value <- function(store, target) {
  UseMethod("store_serialize_value")
}

#' @export
store_serialize_value.default <- function(store, target) {
}

store_unserialize_value <- function(store, target) {
  UseMethod("store_unserialize_value")
}

#' @export
store_unserialize_value.default <- function(store, target) {
}

store_validate <- function(store) {
  tar_assert_correct_fields(store, store_new_default)
  store_validate_packages(store)
  tar_assert_list(store$resources)
}

store_validate_packages <- function(store) {
  tar_assert_package(store_get_packages(store))
}

store_get_packages <- function(store) {
  UseMethod("store_get_packages")
}

#' @export
store_get_packages.default <- function(store) {
  character(0)
}
