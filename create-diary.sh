#!/bin/bash

FILENAME="diary.tex"
OUTDIR="ltx"

DOC_HEADER=$(cat << EOF
\documentclass[a5paper]{article}

\usepackage[T1]{fontenc}
\usepackage[sfdefault]{biolinum}

\usepackage{tikz}
\usepackage[top=.5cm, bottom=.5cm, outer=.5cm, inner=0cm]{geometry}

\newcommand{\PrintPage}[4]{
{\qquad \quad \Huge \bf {#1 #2}} {\quad \large {#3 #4}}
\tikz[remember picture,overlay] \node[opacity=0.7,inner sep=0pt] at (current page.center){\includegraphics[width=\paperwidth,height=\paperheight]{diary-background}};
\clearpage}

\pagestyle{empty}

\begin{document}
EOF
)

DOC_FOOTER=$(cat << EOF
\end{document}
EOF
)

BEGINNING_DATE_SECONDS=$(date --utc --date="$1" +%s)
END_DATE_SECONDS=$(date --utc --date="$2" +%s)
if [[ $BEGINNING_DATE_SECONDS -gt $END_DATE_SECONDS ]]; then
    echo "Bad inputs: the first date should come before the second"
    exit -1
fi

printf "${DOC_HEADER//\\/\\\\}" > "$FILENAME"

CURRENT_DATE=$1
CURRENT_DATE_SECONDS=$BEGINNING_DATE_SECONDS
while [[ $CURRENT_DATE_SECONDS -lt $END_DATE_SECONDS ]]; do 

    DAY_OF_WEEK=$(date --date="$CURRENT_DATE" +%a)
    if [[ $DAY_OF_WEEK != "Sat" ]] && [[ $DAY_OF_WEEK != "Sun" ]]; then
        echo "Printing $CURRENT_DATE..."

        DAY_OF_MONTH=$(date --date="$CURRENT_DATE" +%d)
        MONTH=$(date --date="$CURRENT_DATE" +%B)
        YEAR=$(date --date="$CURRENT_DATE" +%Y)

        printf "\\PrintPage{$DAY_OF_WEEK}{$DAY_OF_MONTH}{$MONTH}{$YEAR}" >> "$FILENAME"
    fi

    # Increment date
    CURRENT_DATE=$(date -I -d "$CURRENT_DATE + 1 day")
    CURRENT_DATE_SECONDS=$(date --utc --date="$CURRENT_DATE" +%s)
done

printf "${DOC_FOOTER//\\/\\\\}" >> "$FILENAME"

latexmk -pdf $FILENAME -outdir=$OUTDIR
