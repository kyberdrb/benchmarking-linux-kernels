# Benchmarking Linux Kernels

Tool for decision support of what kernel to choose.

## Usage

    mkdir ~/git
    cd ~/git
    git clone https://github.com/kyberdrb/benchmarking-linux-kernels.git
    cd benchmarking-linux-kernels/
    ./which_kernel_is_the_best.sh

Then follow the isntructions in the terminal.

## Data preparation
Data generated with command

        sudo ls && clear && date && sleep 5 && ubench && date && sleep 10 && sudo interbench && date && mv "~/$(uname -r).log" ~/git/kyberdrb/benchmarking-linux-kernels/data/raw_data/interbench-$(uname -r).log

**Change** the `~/git/kyberdrb/benchmarking-linux-kernels` with the actual path to the repository on your computer.

Unixbench output is trimmed manually. See sample data in `data/raw_data/` directory.

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
