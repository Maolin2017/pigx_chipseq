dnl -*- Autoconf -*-

AC_INIT([PiGx_chipseq], [m4_translit(m4_esyscmd([cat VERSION]),m4_newline)])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([gnu color-tests tar-pax -Wall -Wno-portability foreign])
AM_SILENT_RULES([yes])

dnl We need sed for version checks
AC_PROG_SED

dnl Load Python support for Automake and ensure we have a Python
dnl interpreter for at least version 3.5.  This sets the "PYTHON"
dnl variable.
dnl https://www.gnu.org/software/automake/manual/html_node/Python.html
AM_PATH_PYTHON([3.5])

AX_PYTHON_MODULE([yaml], "required")

dnl Check for required programmes and store their full path in the
dnl given variables.  The variables are used to substitute
dnl placeholders in the scripts.

dnl The variables only need to be set manually when they cannot be
dnl found via the PATH environment variable.
AC_DEFUN([find_or_override_prog],
[AC_ARG_VAR($1, override location of $2 executable)dnl
AS_IF([test -z "$$1"],dnl
      [AC_PATH_PROG([$1], [$2], no)dnl
      if test x"$$1" == x"no" ; then
        AC_MSG_ERROR([Could not find $2.])
      fi
      ],dnl
      [AC_MSG_NOTICE([Using $$1 as $2 executable.])])])

find_or_override_prog([GNUBASH],         [bash])
find_or_override_prog([PERL],            [perl])
find_or_override_prog([IDR],             [idr])
find_or_override_prog([MACS2],           [macs2])
find_or_override_prog([SNAKEMAKE],       [snakemake])
find_or_override_prog([PANDOC],          [pandoc])
find_or_override_prog([PANDOC_CITEPROC], [pandoc-citeproc])
find_or_override_prog([FASTQC],          [fastqc])
find_or_override_prog([BOWTIE2],         [bowtie2])
find_or_override_prog([BOWTIE2_BUILD],   [bowtie2-build])
find_or_override_prog([BOWTIE2_INSPECT], [bowtie2-inspect])
find_or_override_prog([BEDTOBIGBED],     [bedToBigBed])
find_or_override_prog([BAMTOBED],        [bamToBed])

find_or_override_prog([R],               [R])
find_or_override_prog([RSCRIPT],         [Rscript])


AC_ARG_ENABLE([r-packages-check],
  AS_HELP_STRING([--disable-r-packages-check], [Do not check any R packages.]),
  [AC_MSG_NOTICE([Skipping R packages check.  Be careful!])],
  [dnl
AX_R_PACKAGE([data.table])
AX_R_PACKAGE([genomation])
AX_R_PACKAGE([GenomicRanges])
AX_R_PACKAGE([RCAS])
AX_R_PACKAGE([rtracklayer])
AX_R_PACKAGE([stringr])
  ])


find_or_override_prog([SAMTOOLS],      [samtools])
AC_ARG_ENABLE([samtools-version-check],
  AS_HELP_STRING([--disable-samtools-version-check], [Do not check the Samtools version.]),
  [AC_MSG_NOTICE([Skipping Samtools version check.  Be careful!])],
  [dnl
SAMTOOLS_VERSION_MIN=1.3
SAMTOOLS_VERSION=$([$SAMTOOLS --version | $SED 's/^samtools //;q'])
AX_COMPARE_VERSION([$SAMTOOLS_VERSION], [lt], [$SAMTOOLS_VERSION_MIN],
      [AC_MSG_ERROR([Please install Samtools $SAMTOOLS_VERSION_MIN.])])
  ])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT