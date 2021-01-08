#!/bin/sh

SCRIPT_DIR="$(dirname $0)"

"${SCRIPT_DIR}"/preprocessing_utils/extract_metrics-unixbench.sh
"${SCRIPT_DIR}"/preprocessing_utils/extract_metrics-interbench-latencies.sh
"${SCRIPT_DIR}"/preprocessing_utils/extract_metrics-interbench-cpu.sh

rm "${SCRIPT_DIR}"/pca_input_data/all_in_one.csv
rm "${SCRIPT_DIR}"/pca_input_data/all_in_one.dataset

# merge CSV files horizontally (by columns)
paste -d ',' "${SCRIPT_DIR}"/pca_input_data/unixbench.csv "${SCRIPT_DIR}"/pca_input_data/interbench-latencies-cherry-picked.csv.merge_ready.csv "${SCRIPT_DIR}"/pca_input_data/interbench-latencies-cherry-picked.csv.merge_ready.csv > "${SCRIPT_DIR}"/pca_input_data/all_in_one.csv

# merge dataset files horizontally (by columns)
paste -d '\t' "${SCRIPT_DIR}"/pca_input_data/unixbench.csv.dataset "${SCRIPT_DIR}"/pca_input_data/interbench-latencies-cherry-picked.csv.merge_ready.dataset "${SCRIPT_DIR}"/pca_input_data/interbench-cpu_utilization-cherry-picked.csv.merge_ready.dataset > "${SCRIPT_DIR}"/pca_input_data/all_in_one.dataset

echo
echo "Data preprocessing finished."
echo

echo
echo "------------------------------------------------------------"
echo

echo "https://wessa.net/rwasp_factor_analysis.wasp" | xclip -selection clipboard

echo "Open a web browser and go to the address that has been copied to the clipboard."
echo "    https://wessa.net/rwasp_factor_analysis.wasp"
echo "Press 'Ctrl+V' in the address bar."

echo
echo "------------------------------------------------------------"

read -p "Press any key when you got to the website"
echo

cat pca_input_data/all_in_one.dataset | tail -n+2 | xclip -selection clipboard

echo "The dataset had been copied into clipboard."
echo "Paste this data into the 'Data X' field."

echo
echo "------------------------------------------------------------"
echo

read -p "Press any key when you copied the dataset"
echo

echo -n "$(cat pca_input_data/all_in_one.dataset | head -n1)" | xclip -selection clipboard

echo "The column names had been copied into clipboard."
echo "Go to the same site and paste this data into the 'Names of X columns' field."

echo
echo "------------------------------------------------------------"
echo

read -p "Press any key when you copied the column names"
echo

echo "Set the rest of the parameters"
echo "    Number of Factors: 11"
echo "Chart options"
echo "    Width: 1700"
echo "    Height: 1000"
echo
echo "Values of these parameters are arbitrary."
echo "You can change them according to your preferences."
echo "I recommend to set the height and the width of the chart according to the capabilities of the screen for comfortable presentation in browser."

echo
echo "------------------------------------------------------------"
echo

read -p "Press any key when you set the additional parameters"
echo

echo "After all parameters have been set, press the 'Compute' button."

echo
echo "------------------------------------------------------------"
echo

read -p "Press any key when you clicked the 'Compute' button"
echo

echo "https://wessa.net/rwasp_factor_analysis.wasp#charts" | xclip -selection clipboard

echo "The results appear in the 'Charts' section"
echo "    https://wessa.net/rwasp_factor_analysis.wasp#charts"
echo "This URL had been already copied into your clipboard."
echo "Go to the browser again and paste the URL in the address bar."
echo
echo "==============================================================="
echo "The 'best' kernel will be in the top right corner of the chart."
echo "==============================================================="

echo

# remove Interbench work files
rm -f ~/interbench.*

