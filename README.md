# consult-ugrep.el

Based on [consult-ag](https://github.com/yadex205/consult-ag) by Kanon Kakuno. A quick modification to get ugrep up and running within consult.

[ugrep](https://github.com/Genivia/ugrep) integration for GNU Emacs using [Consult](https://github.com/minad/consult). 

# Requirements

* GNU Emacs >= 27.1
* Consult >= 1.6
* ugrep

# Usage

## `consult-ugrep`

Search with `ugrep`. By default it searches the project directory (found by `consult-project-function`), otherwise the `default-directory` will be searched.
