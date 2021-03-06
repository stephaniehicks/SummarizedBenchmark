#' Create a new BenchDesign
#'
#' Initializes a new BenchDesign object for benchmarking methods.
#'
#' @param bdata optional data.frame or other list object to be
#'        used in the benchmark. (default = NULL)
#'
#' @return
#' BenchDesign object
#'
#' @examples
#' ## with no input
#' bd <- BenchDesign()
#'
#' ## with toy data.frame
#' df <- data.frame(x1 = rnorm(20), y1 = rnorm(20))
#' bd <- BenchDesign(df)
#'
#' @import rlang
#' @export
#' @author Patrick Kimes
BenchDesign <- function(bdata = NULL) {
    b <- structure(list(bdata = bdata,
                        methods = list()),
                   class = "BenchDesign")
    b
}


#' Check if object is a BenchDesign
#'
#' Check whether an object is a BenchDesign.
#' 
#' @param x object to test
#'
#' @return
#' Logical whether object is a BenchDesign
#'
#' @examples
#' ## with toy data.frame
#' df <- data.frame(x1 = rnorm(20), y1 = rnorm(20))
#' bd <- BenchDesign(df)
#'
#' ## check if actually BenchDesign
#' is.BenchDesign(bd)
#' 
#' @keywords internal
#' @export
#' @author Patrick Kimes
is.BenchDesign <- function(x) {
    inherits(x, "BenchDesign")
}


#' Pretty print BenchDesign
#' 
#' @param x BenchDesign object.
#' @param ... other parameters.
#'
#' @return
#' Prints summary of BenchDesign object
#' 
#' @examples
#' ## print an empty BenchDesign
#' bd <- BenchDesign()
#' bd
#' 
#' @keywords internal
#' @importFrom stringr str_pad str_trunc
#' @export
#' @author Patrick Kimes
print.BenchDesign <- function(x, ...) {
    cat(stringr::str_pad("BenchDesign object ", 60, "right", "-"), "\n")
    cat("  benchmark data:\n")
    if (!is.null(x$bdata)) {
        cat("    class: ", class(x$bdata), "\n")
        cat("    names: ", paste(names(x$bdata), collapse=", "), "\n")
    } else {
        cat("    NULL\n")
    }
    cat("  benchmark methods:\n")
    if (length(x$methods) < 1) {
        cat("    none\n")
    } else {
        max_c <- 20
        m1 <- max(nchar(names(head(x$methods))))
        m1 <- min(m1, max_c)
        m2 <- max(nchar(sapply(head(x$methods), function(x) { quo_text(x$func) })))
        m2 <- min(m2, max_c)
        for (n in names(head(x$methods, 5))) {
            p1 <- str_pad(str_trunc(n, max_c), m1 + 1, "left", " ")
            p2 <- str_pad(str_trunc(gsub("\n", ";", quo_text(x$methods[[n]]$func)), max_c),
                          m2 + 1, "left", " ")
            cat("    method: ", p1, "; func: ", p2, "\n", sep="")
        }
        if (length(x$methods) > 5 ) {
            cat("    ... and", length(x$methods) - 5, "more methods.\n")
        }
    }
}
