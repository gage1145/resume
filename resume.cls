\ProvidesClass{resume}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass{article}


% Load Packages ---------------------------------------------------------------


\RequirePackage[
    ignoreheadfoot,
    top=2cm,
    bottom=2cm,
    left=2cm,
    right=2cm,
    footskip=1.0cm
]{geometry}
\RequirePackage{titlesec}
\RequirePackage{tabularx}
\RequirePackage{array}
\RequirePackage[dvipsnames]{xcolor}
\definecolor{primaryColor}{RGB}{0, 0, 150}
\RequirePackage{enumitem} 
\RequirePackage{fontawesome5}
\RequirePackage[
    pdftitle={Gage Rowden's CV},
    pdfauthor={Gage Rowden},
    pdfcreator={LaTeX with RenderCV},
    colorlinks=true,
    urlcolor=primaryColor
]{hyperref}
\RequirePackage[pscoord]{eso-pic}
\RequirePackage{calc}
\RequirePackage{bookmark}
\RequirePackage{changepage}
\RequirePackage{paracol}
\RequirePackage{multicol}
\RequirePackage{needspace}
\RequirePackage{charter}
\RequirePackage[T1]{fontenc}


% Set Document Settings -------------------------------------------------------


\raggedright
\AtBeginEnvironment{adjustwidth}{\partopsep0pt}
\pagestyle{empty} % no header or footer
\setcounter{secnumdepth}{0} % no section numbering
\setlength{\parindent}{0pt} % no indentation
\setlength{\topskip}{0pt} % no top skip
\setlength{\columnsep}{0.15cm} % set column seperation
\pagenumbering{gobble} % no page numbering

\titleformat{\section}{
    \needspace{4\baselineskip}\bfseries\large
}{}{0pt}{}[\vspace{1pt}\titlerule]

% section title spacing
\titlespacing{\section}{-1pt}{0.3 cm}{0.2 cm}

% custom bullet points
\renewcommand\labelitemi{$\vcenter{\hbox{\small$\bullet$}}$}


% Custom Environments ---------------------------------------------------------


% New environment for highlights
\newenvironment{highlights}{
    \begin{itemize}[
        topsep=0.10 cm,
        parsep=0.10 cm,
        partopsep=0pt,
        itemsep=0pt,
        leftmargin=1cm
    ]
}{
    \end{itemize}
}

% New environment for the skills section
\newenvironment{skills}{
    \setlength\multicolsep{0pt}
    \begin{multicols}{3}
        \begin{itemize}
            \setlength{\itemsep}{0pt}
            \setlength{\parskip}{0pt}
            \setlength{\parsep}{0pt}     
}{
        \end{itemize}
    \end{multicols}
    \vspace{0.2cm}
}

% New environment for one column entries
\newenvironment{onecolentry}{
    \begin{adjustwidth}{0cm + 0.00001cm}{0cm + 0.00001cm}
}{
    \end{adjustwidth}
}

% New environment for two column entries
\newenvironment{twocolentry}[2][]{
    \vspace{0.2cm}
    \onecolentry
    \def\secondColumn{\textbf{#2}}
    \setcolumnwidth{\fill, 4.5 cm}
    \begin{paracol}{2}
}{
    \switchcolumn\raggedleft\secondColumn
    \end{paracol}
    \endonecolentry
    \vspace{0.10cm}
}

% New environment for three column entries
\newenvironment{threecolentry}[3][]{
    \onecolentry
    \def\thirdColumn{#2}
    \setcolumnwidth{, \fill, 4.5 cm}
    \begin{paracol}{3}
    {\raggedright #3} \switchcolumn
}{
    \switchcolumn \raggedleft \thirdColumn
    \end{paracol}
    \endonecolentry
}

% New environment for the publications section
\newenvironment{pubs}[2][]{
    \onecolentry
    \def\secondColumn{\textbf{#2}}
    \setcolumnwidth{\fill, 1.5cm}
    \begin{paracol}{2}
}{
    \switchcolumn \raggedleft \secondColumn
    \end{paracol}
    \endonecolentry
}

% New environment for the patents section
\newenvironment{patents}[2][]{
    \onecolentry
    \def\secondColumn{#2}
    \setcolumnwidth{\fill, 3.5cm}
    \begin{paracol}{2}
}{
    \switchcolumn \raggedleft \secondColumn
    \end{paracol}
    \endonecolentry
}

% New environment for the software section
\newenvironment{software}[2][]{
    \onecolentry
    \def\secondColumn{\textbf{#2}}
    \setcolumnwidth{\fill, 5cm}
    \begin{paracol}{2}
}{
    \switchcolumn \raggedleft \secondColumn
    \end{paracol}
    \endonecolentry
}

% Header environment
\newenvironment{header}{
    \setlength{\topsep}{0pt}\par\kern\topsep\centering\linespread{1.5}
}{
    \par\kern\topsep
}


% Custom commands -------------------------------------------------------------


% Adds a pipe separator. Used in the header for contact info.
\newcommand{\AND}{\kern 5.0 pt \unskip
        \cleaders\copy\ANDbox\hskip\wd\ANDbox
        \ignorespaces\kern 5.0 pt
}

% Bolds and italicizes my name.
\newcommand{\me}{
    \textbf{\textit{Gage R Rowden}}
}

% Custom command for inputting publications
\newcommand{\pub}[4]{
    \begin{pubs}{#1} % Year
        \textbf{#2}\\ % Title
        \leftskip 1cm #3. % Authors
        \textbf{\href{https://doi.org/#4}{#4}} % DOI
        \vspace{0.1cm}
    \end{pubs}
}

% Custom command for inputting presentations
\newcommand{\pres}[4]{
    \begin{pubs}{#1} % Year
        \textbf{#2}\\ % Title
        \leftskip 1cm #3. #4 % Authors & Conference
        \vspace{0.1cm}
    \end{pubs}
}

% Custom command for inputting patents
\newcommand{\patent}[5]{
    \begin{patents}
        {
            \textbf{Filed:} #1\\ % Filing date
            \textbf{Issued:} #2 % Issued date
        }
        \textbf{#3}\\ % Title
        \vspace{0.1cm}
        \leftskip 1cm #4\\ % Authors
        \vspace{0.1cm}
        \textit{U.S. Patent #5} % Patent number
    \end{patents}
}

% For adding sub-skills in the skills section
\newcommand{\subskill}[1]{
    \textbf{#1}\vspace*{-\baselineskip+5pt}
}

% save the original href command in a new command:
\let\hrefWithoutArrow\href

\AtBeginDocument{
    \fontfamily{lmss}\selectfont
    \pagestyle{plain}
    \newsavebox\ANDbox\sbox\ANDbox{$|$}
}