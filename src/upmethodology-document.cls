% Document class for Unified Process Methodology
%
% Copyright (c) 2014-25 Stephane GALLAND <galland@arakhne.org>
% 
% This program is free library; you can redistribute it and/or modify
% it under the terms of the GNU Lesser General Public License as
% published by the Free Software Foundation; either version 3 of the
% License, or any later version.
%
% This library is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% Lesser General Public License for more details.
%
% You should have received a copy of the GNU Lesser General Public
% License along with this library; see the file COPYING.  If not,
% write to the Free Software Foundation, Inc., 59 Temple Place - Suite
% 330, Boston, MA 02111-1307, USA.

\global\edef\upm@package@docclazz@ver{2025/04/20}

\NeedsTeXFormat{LaTeX2e}[1995/12/01]
\ProvidesClass{upmethodology-document}[\upm@package@docclazz@ver]

\RequirePackage{upmethodology-p-common}

\newif\ifupm@package@docclazz@nodocinfo
\upm@package@docclazz@nodocinfofalse
\newif\ifupm@package@docclazz@nopubpage
\upm@package@docclazz@nopubpagefalse
\newif\ifupm@package@docclazz@autofrontmatter
\upm@package@docclazz@autofrontmatterfalse
\newif\ifupm@package@docclazz@addfrontcover
\upm@package@docclazz@addfrontcovertrue
\newif\ifupm@package@docclazz@addbackcover
\upm@package@docclazz@addbackcovertrue

\newif\ifupm@package@docclazz@taskpackage
\upm@package@docclazz@taskpackagefalse
\newif\ifupm@package@docclazz@specpackage
\upm@package@docclazz@specpackagefalse
\newif\ifupm@package@docclazz@codepackage
\upm@package@docclazz@codepackagefalse

\newif\ifupm@package@docclazz@nohyperref
\upm@package@docclazz@nohyperreffalse

\gdef\upm@package@docclazz@optionstopass{a4paper,11pt}

\DeclareOption{twoside}{%
  \xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,twoside,openright}%
}
\DeclareOption{oneside}{%
  \xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,oneside}%
}

\DeclareOption{french}{%
  \xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,french}%
  \PassOptionsToPackage{french}{upmethodology-document}
}
\DeclareOption{francais}{%
  \xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,french}%
  \PassOptionsToPackage{french}{upmethodology-document}
}
\DeclareOption{english}{%
  \xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,english}%
  \PassOptionsToPackage{english}{upmethodology-document}
}
\DeclareOption{standardlists}{%
	\message{*********** DISABLING UPMETHODOLOGY LISTS}
	\PassOptionsToPackage{standardlists}{upmethodology-fmt}
}

\DeclareOption{nohyperref}{%
	\message{*********** DISABLING HYPERREF}
	\global\upm@package@docclazz@nohyperreftrue
}

\DeclareOption{nodocumentinfo}{%
	\global\upm@package@docclazz@nodocinfotrue%
}
\DeclareOption{documentinfo}{%
	\global\upm@package@docclazz@nodocinfofalse%
}
\DeclareOption{nopubpage}{%
	\global\upm@package@docclazz@nopubpagetrue%
}
\DeclareOption{pubpage}{%
	\global\upm@package@docclazz@nopubpagefalse%
}
\DeclareOption{nofrontmatter}{%
	\global\upm@package@docclazz@autofrontmatterfalse%
}
\DeclareOption{frontmatter}{%
	\global\upm@package@docclazz@autofrontmattertrue%
}
\DeclareOption{nofrontcover}{%
	\global\upm@package@docclazz@addfrontcoverfalse%
}
\DeclareOption{frontcover}{%
	\global\upm@package@docclazz@addfrontcovertrue%
}
\DeclareOption{nobackcover}{%
	\global\upm@package@docclazz@addbackcoverfalse%
}
\DeclareOption{backcover}{%
	\global\upm@package@docclazz@addbackcovertrue%
}
\DeclareOption{taskpackage}{%
	\global\upm@package@docclazz@taskpackagetrue%
}
\DeclareOption{specpackage}{%
	\global\upm@package@docclazz@specpackagetrue%
}
\DeclareOption{codepackage}{%
	\global\upm@package@docclazz@codepackagetrue%
}
\DeclareOption{book}{%
	\global\upmbookformattrue
	\global\upmreportformatfalse
	\global\upmarticleformatfalse
	\global\upm@package@docclazz@nopubpagefalse%
	\global\upm@package@docclazz@nodocinfofalse%
	\xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,twoside,openright}%
}
\DeclareOption{report}{%
	\global\upmbookformatfalse
	\global\upmreportformattrue
	\global\upmarticleformatfalse
	\global\upm@package@docclazz@nopubpagetrue%
	\global\upm@package@docclazz@nodocinfofalse%
	\xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,oneside}%
}
\DeclareOption{article}{%
	\global\upmbookformatfalse
	\global\upmreportformatfalse
	\global\upmarticleformattrue
	\global\upm@package@docclazz@nopubpagetrue%
	\global\upm@package@docclazz@nodocinfotrue%
	\xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,oneside}%
}

\DeclareOption*{%
	\xdef\upm@package@docclazz@optionstopass{\upm@package@docclazz@optionstopass,\CurrentOption}%
	}
\ExecuteOptions{report}
\ProcessOptions*\relax

\ifupmbookformat
	\message{*********** UPMETHODOLOGY BOOK CLASS (WITH PART AND CHAPTER)}
	\expandafter\LoadClass[\upm@package@docclazz@optionstopass]{book}
\else\ifupmreportformat
	\message{*********** UPMETHODOLOGY REPORT CLASS (WITHOUT PART, WITH CHAPTER)}
	\expandafter\LoadClass[\upm@package@docclazz@optionstopass]{report}
\else
	\message{*********** UPMETHODOLOGY ARTICLE CLASS (WITHOUT PART AND CHAPTER)}
	\expandafter\LoadClass[\upm@package@docclazz@optionstopass]{article}
\fi\fi

\RequirePackage{a4wide}

\ifupm@package@docclazz@nohyperref\else\ifpdf
	\RequirePackage[pdftex,
			breaklinks, %make links breakable on several lines
			pageanchor=true, %put implicit anchor on each page (required for \printindex)
		        bookmarks=false, %hide bookmarks
			hyperfigures=true, %not documented
			hyperindex=true, %the page numbers in the index are links
			linktocpage=true, %page numbers are used for links in TOC, LOF...
			bookmarks=true, %open the bookmarks
			bookmarksopen=true, %open all the bookmark's nodes by default
			bookmarksnumbered=true, %section number in bookmarks
			colorlinks=false, % Use a frame around links
			pdfproducer={upmethodology \upm@package@docclazz@ver},
		        ]{hyperref}
\else
	\RequirePackage[breaklinks, %make links breakable on several lines
			pageanchor=true, %put implicit anchor on each page (required for \printindex)
		        bookmarks=false, %hide bookmarks
			hyperfigures=true, %not documented
			hyperindex=true, %the page numbers in the index are links
			linktocpage=true, %page numbers are used for links in TOC, LOF...
			bookmarks=true, %open the bookmarks
			bookmarksopen=true, %open all the bookmark's nodes by default
			bookmarksnumbered=true, %section number in bookmarks
			colorlinks=false, % Use a frame around links
			]{hyperref}
\fi\fi
\RequirePackage{url}
\urlstyle{same}

\ifupmarticleformat\else%
	\RequirePackage{fancyhdr}
\fi

\RequirePackage{upmethodology-document}
\RequirePackage{upmethodology-extension}
\RequirePackage{upmethodology-frontpage}
\RequirePackage{upmethodology-backpage}
\ifupm@package@docclazz@taskpackage
	\RequirePackage{upmethodology-task}
\fi
\ifupm@package@docclazz@codepackage
	\RequirePackage{upmethodology-code}
\fi
\ifupm@package@docclazz@specpackage
	\RequirePackage{upmethodology-spec}
\fi

\ifpdf
  \pdfpageheight=29.7cm
  \pdfpagewidth=21.0cm
\fi

%----------------------------------------
% HEADERS AND FOOTERS
%----------------------------------------

\colorlet{pageheadertext}{gray}
\colorlet{pageheadersection}{darkgray}
\colorlet{pagefootertext}{gray}
\colorlet{pagefooterpage}{darkgray}
\def\upm@footer@pagefmt@left#1{\textcolor{pagefootertext}{%
	\sffamily%
	{\bfseries\textcolor{pagefooterpage}{#1}}%
	\hspace{5pt}\ensuremath{|}%
}}
\def\upm@footer@pagefmt@right#1{\textcolor{pagefootertext}{
	\sffamily%
	\ensuremath{|}\hspace{5pt}%
	{\bfseries\textcolor{pagefooterpage}{#1}}%
}}

\def\upm@header@fmt#1{\textcolor{pageheadertext}{\sffamily{#1}}}
\def\upm@header@sectionfmt@left#1#2{\textcolor{pageheadersection}{#2}\hspace{5pt}\ensuremath{|}\hspace{5pt}\textsc{#1}}
\def\upm@header@sectionfmt@right#1#2{\textsc{#1}\hspace{5pt}\ensuremath{|}\hspace{5pt}\textcolor{pageheadersection}{#2}}

\global\let\upm@package@docclazz@old@pagestyle\pagestyle
\gdef\pagestyle#1{%
	\gdef\upm@package@docclazz@saved@pagestyle{#1}%
	\upm@package@docclazz@old@pagestyle{#1}%
}
\gdef\upm@package@docclazz@saved@pagestyle{headings}%
\upm@package@docclazz@old@pagestyle{headings}

\newdimen{\upm@smalllogo@height}
\upm@smalllogo@height=1cm

\renewcommand{\sectionmark}[1]{\markright{\upm@header@sectionfmt@right{#1}{\thesection}}}
\ifupmarticleformat\else
	\renewcommand{\chaptermark}[1]{\markboth{\upm@header@sectionfmt@left{#1}{\thechapter}}{}}
\fi

% Supported page styles:
% empty: no header, no footer
% facingtochapter: page that is on the left of the starting page of a chapter
% plain: starting page of a chapter
% headings: pages that are supposed to have header and footer

% Define the header and footer style for books and reports
\ifupmarticleformat\else%

	% Style used for the first pages of the chapter
	\fancypagestyle{plain}{
		\fancyhf{}%
		\renewcommand{\headrulewidth}{0pt}%
		\renewcommand{\footrulewidth}{0pt}%
		\fancyfoot[LE]{\upm@footer@pagefmt@left{\thepage}}%
		\fancyfoot[RO]{\upm@footer@pagefmt@right{\thepage}}%
	}
	% Style used in chapters in which a standard heading is expected
	\fancypagestyle{headings}{
		\fancyhf{}%
		\renewcommand{\headrulewidth}{0pt}%
		\renewcommand{\footrulewidth}{0pt}%
		\fancyhead[LE]{\upm@header@fmt{\leftmark}}%
		\fancyhead[RO]{\upm@header@fmt{\rightmark}}%
		\fancyfoot[LE]{\upm@footer@pagefmt@left{\thepage}}%
		\fancyfoot[RO]{\upm@footer@pagefmt@right{\thepage}}%
	}
\fi

%----------------------------------------
% FRONT, MAIN AND BACK MATTERS
%----------------------------------------

\global\let\upm@package@docclazz@frontmatter\frontmatter
\gdef\frontmatter{%
	\upm@package@docclazz@old@pagestyle{headings}%
	\pagenumbering{roman}%
	\global\let\frontmatter\relax%
}

\global\let\upm@package@docclazz@mainmatter\mainmatter
\gdef\mainmatter{%
	\upm@package@docclazz@mainmatter%
	\global\let\frontmatter\relax%
	\global\let\mainmatter\relax%
}

\global\let\upm@package@docclazz@backmatter\backmatter
\gdef\backmatter{%
	\global\let\frontmatter\relax%
	\global\let\mainmatter\relax%
	\global\let\backmatter\relax%
	\upm@package@docclazz@backmatter%
	\global\let\upm@package@docclazz@appendix\appendix%
	\gdef\appendix{%
		\upm@package@docclazz@appendix%
		\global\@mainmattertrue%
	}%
}

%----------------------------------------
% AUTO-GENERATED DOCUMENT
%----------------------------------------

\AtBeginDocument{%
	\ifupm@package@docclazz@autofrontmatter\frontmatter\fi%
	\ifupm@package@docclazz@addfrontcover\makefrontcover\fi%
	\ifupm@package@docclazz@nopubpage\else\upmpublicationpage\fi%
	\ifupm@package@docclazz@nodocinfo\else\upmdocinfopage\fi%
	\sloppy%
}

\AtEndDocument{%
	\ifupm@package@docclazz@addbackcover\makebackcover\fi%
}

%----------------------------------------
% PDF COLORS
%----------------------------------------
\gdef\upm@package@getcolor#1,#2,#3{#1 #2 #3}
\ifpdf
	\ifupm@package@docclazz@nohyperref
		\renewcommand{\setpdfcolor}[1]{%
		}
	\else
		\renewcommand{\setpdfcolor}[1]{
			\hypersetup{
				filebordercolor={\upm@package@getcolor #1}, % frame color
				linkbordercolor={\upm@package@getcolor #1}, % frame color
				citebordercolor={\upm@package@getcolor #1}, % frame color
				menubordercolor={\upm@package@getcolor #1}, % frame color
				urlbordercolor={\upm@package@getcolor #1}, % frame color
				runbordercolor={\upm@package@getcolor #1}, % frame color
			}
		}
	\fi
\fi

%----------------------------------------
% SET FORBIDDEN SECTIONNING FUNCTIONS
%----------------------------------------
\ifupmbookformat\else
	\gdef\upm@package@docclazz@hidesec@a#1{%
		\@ifnextchar*{\upm@package@docclazz@hidesec@d{#1}}{%
		\@ifnextchar[{\upm@package@docclazz@hidesec@b{#1}}{\upm@package@docclazz@hidesec@c{#1}}%
		}}
	\gdef\upm@package@docclazz@hidesec@d#1#2{%
		\@ifnextchar[{\upm@package@docclazz@hidesec@b{#1}}{\upm@package@docclazz@hidesec@c{#1}}}
	\gdef\upm@package@docclazz@hidesec@b#1[#2]#3{\@warning{"#1" macro is skipped. Title: "#3"}}
	\gdef\upm@package@docclazz@hidesec@c#1#2{\@warning{"#1" macro is skipped. Title: "#2"}}

	\gdef\part{\upm@package@docclazz@hidesec@a{\string\part}}
	\gdef\partstar{\upm@package@docclazz@hidesec@a{\string\part*}}
	\gdef\parttoc{\upm@package@docclazz@hidesec@a{\string\parttoc}}

\ifupmreportformat\else

	\gdef\chapter{\upm@package@docclazz@hidesec@a{\string\part}}
	\gdef\chapterstar{\upm@package@docclazz@hidesec@a{\string\part*}}
	\gdef\chaptertoc{\upm@package@docclazz@hidesec@a{\string\parttoc}}

\fi\fi

\endinput
