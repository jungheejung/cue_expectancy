--- 
title: "Analysis logbook: task-cue-expectancy"
author: "Heejung Jung"
site: bookdown::bookdown_site
documentclass: book
output:
  html_document:
    code_folding: hide
    toc: true
    toc_float: true
    collapsed: false
    smooth_scroll: false
    df_print: paged
bibliography:
- book.bib
- packages.bib
description: |
  This is a logbook of all the mixed model analyses in one setting.
  set in the _output.yml file.
  The HTML output format for this example is bookdown::gitbook,
link-citations: yes
github-repo: "rstudio/bookdown-demo"

editor_options: 
  markdown: 
    wrap: 72
---

# About

This is a analysis book written in Markdown. The purpose is the keep track of analyses and summarize findings, while decluttering from result vs. code. 

## Usage 

Each bookdown chapter is an .Rmd file. This .Rmd is migrated from the git repository cue-expectancy and specificially from the folder **step02_R**. Each .Rmd file was developed as a standalone analysis pipeline. Once validated, the identical .Rmd is migrated to the bookdown folder and edited for bookdown compiling. 


