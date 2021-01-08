#!/bin/sh

RAW_DATA="${SCRIPT_DIR}data/raw_data/"

SCRIPT_DIR="$(dirname $0)/../"

#data/interbench_cpu_trimmed_data/ data/interbench_cpu_extracted_data/ data/interbench_cpu_comma_separated_data/ pca_input_data/interbench-cpu_utilization.csv

TRIMMED_DATA_DIR="${SCRIPT_DIR}data/interbench_cpu_trimmed_data/"
EXTRACTED_DATA_DIR="${SCRIPT_DIR}data/interbench_cpu_extracted_data/"
COMMA_SEPARATED_DATA_DIR="${SCRIPT_DIR}data/interbench_cpu_comma_separated_data/"
CSV_OUTPUT_DIR="${SCRIPT_DIR}pca_input_data/"

echo "$TRIMMED_DATA_DIR"
ls -l "$TRIMMED_DATA_DIR"
echo && echo && echo

echo "$EXTRACTED_DATA_DIR"
ls -l "$EXTRACTED_DATA_DIR"
echo && echo && echo

echo "$COMMA_SEPARATED_DATA_DIR"
ls -l "$COMMA_SEPARATED_DATA_DIR"
echo && echo && echo

echo "${CSV_OUTPUT_DIR}"
ls -l "${CSV_OUTPUT_DIR}" 
echo && echo && echo

rm -r "$TRIMMED_DATA_DIR"
rm -r "$EXTRACTED_DATA_DIR"
rm -r "$COMMA_SEPARATED_DATA_DIR"

CSV_OUTPUT_FILE="interbench-cpu_utilization.csv"
echo "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.merge_ready.csv"
echo "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.dataset"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.dataset"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.merge_ready.dataset"

CSV_OUTPUT_FILE_CHERRY_PICKED="interbench-cpu_utilization-cherry-picked.csv"
echo "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.merge_ready.csv"
echo "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.dataset"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.dataset"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.merge_ready.dataset"

mkdir -p "$TRIMMED_DATA_DIR"
mkdir -p "$EXTRACTED_DATA_DIR"
mkdir -p "$COMMA_SEPARATED_DATA_DIR"
mkdir -p "${CSV_OUTPUT_DIR}" 

lines_with_cpu_metrics=( 31 32 38 39 45 46 52 53 59 60 66 67 73 74 105 106 112 113 119 120 126 127 133 134 140 141 172 173 179 180 186 187 193 194 200 201 207 208 236 242 248 254 260 266 272 )

# line numbers in extracted data for columns in raw data, i.e. rows in trimmed data, picked by higher covariance
cherry_picked_lines_with_from_extracted_data=( 31 32 37 38 42 45 )

echo
echo $RAW_DATA
echo
echo $TRIMMED_DATA_DIR
echo

for raw_data_file in $(ls ${RAW_DATA}interbench-*)
do
  trimmed_file_name="trimmed-$(basename ${raw_data_file})"
  echo "${TRIMMED_DATA_DIR}${trimmed_file_name}"
  echo "$raw_data_file"

  # cut out measured values
  #cat $raw_data_file | tail -n 40 | head -n 37 | tr -s ' ' | tr ' \t' '\n' | sed '/^$/d' > ${TRIMMED_DATA_DIR}${trimmed_file_name}

  # TODO instead of manual copying of the output from interbench run, use the log file in the home directory and parse the log file instead of the txt file
  cat "$raw_data_file" | tail -n 39 | head -n 37 | tr -s ' ' | tr ' \t' '\n' | sed '/^$/d' > ${TRIMMED_DATA_DIR}${trimmed_file_name}

done

echo
echo $TRIMMED_DATA_DIR
echo
echo $EXTRACTED_DATA_DIR
echo

for trimmed_data_file in $(ls $TRIMMED_DATA_DIR)
do
  extracted_file_name="extracted-$(basename ${trimmed_data_file})"
  echo ${TRIMMED_DATA_DIR}${trimmed_data_file}
  echo ${EXTRACTED_DATA_DIR}${extracted_file_name}

  # append lines with latency times
  for line_number in ${lines_with_cpu_metrics[@]}
  do
    sed -n ${line_number}p ${TRIMMED_DATA_DIR}${trimmed_data_file} >> ${EXTRACTED_DATA_DIR}${extracted_file_name}

  done

done

echo
echo $COMMA_SEPARATED_DATA_DIR
echo

for extracted_data_file in $(ls ${EXTRACTED_DATA_DIR})
do
  comma_separated_file_name="comma_separated-$(basename ${extracted_data_file})"
  echo ${EXTRACTED_DATA_DIR}${extracted_file_name}
  echo ${COMMA_SEPARATED_DATA_DIR}${comma_separated_file_name}
  
  # remove last character from each line and add a newline
  cat ${EXTRACTED_DATA_DIR}${extracted_data_file} | tr '\n' ',' | sed 's/,$/\n/' > ${COMMA_SEPARATED_DATA_DIR}${comma_separated_file_name}

done

echo
echo "Cherry-picking lines from extracted files"
echo


for extracted_data_file in $(ls ${EXTRACTED_DATA_DIR}extracted*)
do
  cherry_picked_extracted_file_name="cherry-picked-$(basename ${extracted_data_file})"
  echo "${extracted_data_file}"
  echo "${EXTRACTED_DATA_DIR}${cherry_picked_extracted_file_name}"
  
  # cherry-pick lines with highest covariance
  for cherry_picked_line_number in ${cherry_picked_lines_with_from_extracted_data[@]}
  do
    sed -n ${cherry_picked_line_number}p "${extracted_data_file}" >> "${EXTRACTED_DATA_DIR}${cherry_picked_extracted_file_name}"

  done
done

for extracted_data_file in $(ls ${EXTRACTED_DATA_DIR}cherry-picked*)
do
  cherry_picked_comma_separated_file_name="comma_separated-$(basename ${extracted_data_file})"
  echo "${extracted_data_file}"
  echo "${COMMA_SEPARATED_DATA_DIR}${cherry_picked_comma_separated_file_name}"
  
  # remove last character from each line and add a newline
  cat "${extracted_data_file}" | tr '\n' ',' | sed 's/,$/\n/' > ${COMMA_SEPARATED_DATA_DIR}${cherry_picked_comma_separated_file_name}

done

# add columns to CSV file
echo "kernel_type,audio-none-desired_cpu,audio-none-deadlines_met,audio-video-desired_cpu,audio-video-deadlines_met,audio-X-desired_cpu,audio-X-deadlines_met,audio-burn-desired_cpu,audio-burn-deadlines_met,audio-write-desired_cpu,audio-write-deadlines_met,audio-read-desired_cpu,audio-read-deadlines_met,audio-compile-desired_cpu,audio-compile-deadlines_met,video-none-desired_cpu,video-none-deadlines_met,video-X-desired_cpu,video-X-deadlines_met,video-burn-desired_cpu,video-burn-deadlines_met,video-write-desired_cpu,video-write-deadlines_met,video-read-desired_cpu,video-read-deadlines_met,video-compile-desired_cpu,video-compile-deadlines_met,X-none-desired_cpu,X-none-deadlines_met,X-video-desired_cpu,X-video-deadlines_met,X-burn-desired_cpu,X-burn-deadlines_met,X-write-desired_cpu,X-write-deadlines_met,X-read-desired_cpu,X-read-deadlines_met,X-compile-desired_cpu,X-compile-deadlines_met,gaming-none-desired_cpu,gaming-video-desired_cpu,gaming-X-desired_cpu,gaming-burn-desired_cpu,gaming-write-desired_cpu,gaming-read-desired_cpu,gaming-compile-desired_cpu" >> "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"

echo "kernel_type,X-burn-desired_cpu,X-burn-deadlines_met,X-compile-desired_cpu,X-compile-deadlines_met,gaming-burn-desired_cpu,gaming-compile-desired_cpu" >> "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"

echo
echo "Merge all comma separated value files into one CSV file"
echo
echo "${CSV_OUTPUT_DIR}$CSV_OUTPUT_FILE"
echo

for comma_separated_file in $(ls ${COMMA_SEPARATED_DATA_DIR}comma_separated-extracted*)
do
  echo "${comma_separated_file}"  

  echo "$(basename $comma_separated_file)" >> "${CSV_OUTPUT_DIR}$CSV_OUTPUT_FILE"
  cat ${comma_separated_file} >> "${CSV_OUTPUT_DIR}$CSV_OUTPUT_FILE"

done

echo
echo "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"
echo

for comma_separated_file in $(ls ${COMMA_SEPARATED_DATA_DIR}comma_separated-cherry-picked*)
do
  echo "${comma_separated_file}"  

  echo "$(basename $comma_separated_file)" >> "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"
  cat ${comma_separated_file} >> "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"

done

# clean up the file
sed -i 's/comma_separated-extracted-trimmed-interbench-//g' "${CSV_OUTPUT_DIR}$CSV_OUTPUT_FILE"
sed -i ':a;N;$!ba;s/\.log\n/,/g' "${CSV_OUTPUT_DIR}$CSV_OUTPUT_FILE"

sed -i 's/comma_separated-cherry-picked-extracted-trimmed-interbench-//g' "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"
sed -i ':a;N;$!ba;s/\.log\n/,/g' "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"

# wrap string to apostrophes
sed -i "s/^/'/g" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"
sed -i "0,/'/s/'//" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"

sed -i "s/,/',/" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"
sed -i "0,/',/s/'//" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"

sed -i "s/^/'/g" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"
sed -i "0,/'/s/'//" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"

sed -i "s/,/',/" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"
sed -i "0,/',/s/'//" "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"

# create dataset files for merging
cat "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}" | cut -d',' --complement -f1 > "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.merge_ready.csv"
cat "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}" | cut -d',' --complement -f1 > "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.merge_ready.csv"

# create dataset files
cat "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}" | tr ',' '\t' > "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.dataset"
cat "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}" | tr ',' '\t' > "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.dataset"
cat "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.merge_ready.csv" | tr ',' '\t' > "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.merge_ready.dataset"
cat "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.merge_ready.csv" | tr ',' '\t' > "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}.merge_ready.dataset"


