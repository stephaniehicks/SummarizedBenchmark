#' Modify definition of method in BenchDesign object
#'
#' This function takes a BenchDesign object and the name of a method
#' already defined in the object, and returns a modified BenchDesign
#' object with the specified changes made only to the named method.
#' At a minimum, a string name for the method, `blabel`, must be
#' specified in addition to the primary BenchDesign object.
#' 
#' @param b BenchDesign object.
#' @param blabel Character name of method to be modified.
#' @param ... Named parameter, value pairs to overwrite 
#'        in method definition. This can include `bfunc`,
#'        `bpost`, and `bmeta` parameters. All other named parameters
#'        will be added to the list of parameters to be passed to
#'        `bfunc`.
#' @param .overwrite Logical whether to overwrite the existing list of
#'        parameters to be passed to `bfunc` (TRUE), or to simply add
#'        the new parameters to the existing list (FALSE).
#'        (default = FALSE) 
#'        
#' @examples
#' ## with toy data.frame
#' df <- data.frame(pval = runif(100))
#' bd <- BenchDesign(df)
#'
#' ## add method
#' bd <- addBMethod(bd, blabel = "qv",
#'                  bfunc = qvalue::qvalue,
#'                  bpost = function(x) { x$qvalue },
#'                  bmeta = list(note = "storey's q-value"),
#'                  p = pval)
#'
#' ## modify method 'bmeta' property of 'qv' method
#' bd <- modifyBMethod(bd, blabel = "qv",
#'                     bmeta = list(note = "Storey's q-value"))
#' 
#' ## verify that method has been updated
#' showBMethod(bd, "qv")
#'
#' @return
#' Modified BenchDesign object.
#' 
#' @md
#' @import rlang
#' @export
#' @author Patrick Kimes
modifyBMethod <- function(b, blabel, ..., .overwrite = FALSE) {
    UseMethod("modifyBMethod")
}

#' @export
modifyBMethod.BenchDesign <- function(b, blabel, ..., .overwrite = FALSE) {
    ## capture input
    qd <- quos(...)

    ## verify that method definition already exists
    if(!(blabel %in% names(b$methods))) {
        stop("Specified method is not defined in BenchDesign.")
    }

    ## modify and add to bench
    bm <- b$methods[[blabel]]
    b$methods[[blabel]] <- .modmethod(bm, qd, .overwrite)

    return(b)
}


#' Modify BenchDesign Method
#'
#' Given a method defined in a BenchDesign, this helper function
#' returns a modified method with new parameters defined as a
#' list of quosures.
#' 
#' @param m method
#' @param q quosure list of new parameters
#' @param .overwrite logical whether to overwrite parameters
#'
#' @return
#' modified method. 
#'
#' @rdname modmethod
#' @keywords internal
#' @author Patrick Kimes
.modmethod <- function(m, q, .overwrite) {
    ## parse out bfunc, bpost, bmeta
    if ("bfunc" %in% names(q)) {
        m$func <- q$bfunc
    }
    if ("bpost" %in% names(q)) {
        m$post <- q$bpost
    }
    if ("bmeta" %in% names(q)) {
        m$meta <- eval_tidy(q$bmeta)
    }

    ## process named parameters to be used for bfunc
    q <- q[! names(q) %in% c("bfunc", "bpost", "bmeta")]
    if (.overwrite) {
        m$dparams <- q
    } else {
        m$dparams <- replace(m$dparams, names(q), q)
    }
    
    return(m)
}
