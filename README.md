# Benchmarking Linux Kernels

Decision support tool for choosing the 'best' kernel.

## Current state of tested Linux kernels

- **lts - boots; vbox VMs start; USB work**
- **linux-tkg-muqss-skylake 5.10.14 (last stable version) - boots; vbox VMs start; USB work**
- clear - boots; vbox VMs don't start, USB work
- lqx - boots; vbox VMs don't start, USB doesn't work
- everything else (approximately between 5.10.14 - 5.11.2 onwards - including linux-libre, linux-lts-tkg-muqss, etc.) - doesn't boot: kernel panic

## Usage

    mkdir ~/git
    cd ~/git
    git clone https://github.com/kyberdrb/benchmarking-linux-kernels.git
    cd benchmarking-linux-kernels/
    ./which_kernel_is_the_best.sh

Then follow the instructions in the terminal.

## Data preparation

Data generated with script

    ./begin_benchmarking.sh

Unixbench output needs to be manually copied entirely and then manually pasted into a new file corresponding with the kernel info. Then follow the instructions on the screen.

See sample data in `data/raw_data/` directory for examples of `interbench` and `unixbench` files.

**The script relies on that all data be in the same format with the same number of lines**

## Data preprocessing

Data processed with commands inside `./which_kernel_is_the_best.sh`

Columns for the PCA tool were cherry-picked from the data because of the covariance that the algorithm required.

The data were processed in Libre Office Calc: deleted columns (variables) with zero covariance, i.e. all rows in that column had multiple values of '100' or at most '99.9' or multiple values of '0'

**BEWARE!** Sometimes are backticks in the data when copying from Libre Office Calc directly to the PCA online tool.
As a result, the PCA online tool doesn't perform any computation, although in the editor on the website looks everything in the proper format
i.e. single quote on both sides, not single quote and backtick character. 
To prevent this from happening, copy the data from the Libre Office Calc to a text editor, replace backticks with single quotes if necessary, and then copy the repaired data to the PCA online tool. Make sure there is equal number of columns in the column section and in the data section.

## Data processing and postprocecssing

Data are evaluated with PCA (Principal Component Analysis) method with https://wessa.net/rwasp_factor_analysis.wasp using `.dataset` files which have values delimited by a TAB character `\t`, as the tool requires it.

Put the column names in the `Names of X columns` field, and the data in the `Data X` field.
