

# ---------------------------------------------------------------------------- #
table_RleList = function(x)
{
    library(S4Vectors)
    nbins = max(max(x)) + 1L
    data = lapply(x,
                   function(xi)
                       S4Vectors:::tabulate2(runValue(xi) + 1L, nbins,
                                             weight=runLength(xi)))
    ans = matrix(unlist(data, use.names=FALSE),
                  nrow=length(x), byrow=TRUE)
    dimnames(ans) = list(names(x), 0:(nbins-1L))
    class(ans) = "table"
    ans
}


# ---------------------------------------------------------------------------- #
RleSumAny = function (e1, e2)
{
    library(chipseq)
    len = length(e1)
    stopifnot(len == length(e2))
    x1 = runValue(e1); s1 = cumsum(runLength(e1))
    x2 = runValue(e2); s2 = cumsum(runLength(e2))
    .Call("rle_sum_any",
          as.integer(x1), as.integer(s1),
          as.integer(x2), as.integer(s2),
          as.integer(len),
          PACKAGE = "chipseq")
}


# ---------------------------------------------------------------------------- #
Append_List_Element = function(l, name, value){
    l[[name]] = c(l[[name]], value)
    l
}

# ---------------------------------------------------------------------------- #
Summarize_Statistics_List = function(
    lout
){
    lsum = list()
    lsum$CovHistAll = NULL

    message('CovHistAll ...')
        for(l in 1:length(lout$CovHist)){
            tempCovHist = cbind(as.numeric(names(lout$CovHist[[l]])),as.numeric(lout$CovHist[[l]]))
            tempCovHist = merge(lsum$CovHistAll,tempCovHist,by.x=0,by.y=1,all=TRUE,sort=FALSE)
            CovSums    = data.frame(Depth=rowSums(tempCovHist[,-1,drop=FALSE],na.rm=TRUE),row.names=tempCovHist[,1])
            CovHistAll = CovSums
        }
        tempCovHistAll = as.numeric(CovHistAll[,1])
        names(tempCovHistAll) = rownames(CovHistAll)
        lsum$CovHistAll = tempCovHistAll

    message('ShiftMat ...')
        lsum$ShiftsAv = rowMeans(do.call(cbind, lout$ShiftMat), na.rm=TRUE)

    message('ShiftsCorAv ...')
        lsum$ShiftsCorAv = rowMeans(do.call(cbind, lout$ShiftMatCor), na.rm=TRUE)

    message('PosAny ...')
        lsum$PosAny = with(lout, unname((sum(NegAny)))+unname((sum(PosAny))))

    message('SSD ...')
        lsum$SSDAv = mean(unlist(lout$SSD))

    message('readlength ...')
        lsum$readlength = lout$readlength

    message('Annotation ...')
        lsum$annot = lout$annot

    message('Duplicated Reads ...')
        lsum$duplication_rate = data.frame(
            Ndup = sum(unlist(lout$duplicated_reads)), 
            Ntot = sum(unlist(lout$total_reads))
        )

    message('Library Complexity ...')
        # this reduces the RleList elements into a single Rle which 
        # is already a histogram
        vec = lapply(lout$library_complexity, sort)
        vec = do.call(rbind, lapply(vec, function(x)data.frame(bin=runValue(x[[1]]), count=runLength(x[[1]])))) %>%
           group_by(bin) %>% 
           summarize(count = sum(count))
        lsum$library_complexity = vec
        
    message('Mitochondrial Reads ...')
        lsum$mitochondrial_reads = as.data.frame(lout$mitochondrial_reads)

    return(lsum)
}


# ---------------------------------------------------------------------------- #
Count_chrM <- function(
    bamfile, 
    chrM_givenName=NULL
) {
    
    library(Rsamtools)
    
    ## define some default names for chrM
    chrM_defaultName <-  c("chrM","MT","MtDNA","chMT")
    chrM_defaultName <- unique(c(chrM_defaultName,chrM_givenName))
    
    bamfile <- gsub(pattern = '.bai',replacement = '',bamfile)
    
    ## get genome chrom lengths
    chr_lengths = scanBamHeader(bamfile)[[1]]$targets
    
    ## check if chrM is included
    if (!any(names(chr_lengths) %in% chrM_defaultName)) {
        warning("No chrM detected, returning 0 counts.")
        return(0)
    }
    
    chr_lengths = chr_lengths[names(chr_lengths) %in% chrM_defaultName]
    gr <- GRanges(seqnames = names(chr_lengths),
                  ranges = IRanges(start = 1,end = chr_lengths))
    
    count <- Rsamtools::countBam(file = bamfile,
                        param = Rsamtools::ScanBamParam(which = gr))$records
    
    return(count)
    
}
