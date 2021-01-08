#!/bin/sh

RAW_DATA="${SCRIPT_DIR}data/raw_data/"

SCRIPT_DIR="$(dirname $0)/../"
TRIMMED_DATA_DIR="${SCRIPT_DIR}data/interbench_trimmed_data/"
EXTRACTED_DATA_DIR="${SCRIPT_DIR}data/interbench_extracted_data/"
COMMA_SEPARATED_DATA_DIR="${SCRIPT_DIR}data/interbench_comma_separated_data/"
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

CSV_OUTPUT_FILE="interbench-latencies.csv"
echo "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.merge_ready.csv"
echo "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.dataset"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.dataset"
rm "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}.merge_ready.dataset"

CSV_OUTPUT_FILE_CHERRY_PICKED="interbench-latencies-cherry-picked.csv"
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

lines_with_latencies=( 27 29 30 34 36 37 41 43 44 48 50 51 55 57 58 62 64 65 69 71 72 101 103 104 108 110 111 115 117 118 122 124 125 129 131 132 136 138 139 168 170 171 175 177 178 182 184 185 189 191 192 196 198 199 203 205 206 232 234 235 238 240 241 244 246 247 250 252 253 256 258 259 262 264 265 268 270 271 274 276 277 280 282 283 )

# line numbers in extracted data for columns in raw data, i.e. rows in trimmed data, picked by higher covariance
cherry_picked_lines_with_from_extracted_data=( 33 55 56 57 76 77 78 )

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
  for line_number in ${lines_with_latencies[@]}
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
echo "kernel_type,audio-none-average_latency,audio-none-latency-deviation,audio-none-maximum-latency,audio-video-average_latency,audio-video-latency-deviation,audio-video-maximum-latency,audio-X-average_latency,audio-X-latency-deviation,audio-X-maximum-latency,audio-burn-average_latency,audio-burn-latency-deviation,audio-burn-maximum-latency,audio-write-average_latency,audio-write-latency-deviation,audio-write-maximum-latency,audio-read-average_latency,audio-read-latency-deviation,audio-read-maximum-latency,audio-compile-average_latency,audio-compile-latency-deviation,audio-compile-maximum-latency,video-none-average_latency,video-none-latency-deviation,video-none-maximum-latency,video-X-average_latency,video-X-latency-deviation,video-X-maximum-latency,video-burn-average_latency,video-burn-latency-deviation,video-burn-maximum-latency,video-write-average_latency,video-write-latency-deviation,video-write-maximum-latency,video-read-average_latency,video-read-latency-deviation,video-read-maximum-latency,video-compile-average_latency,video-compile-latency-deviation,video-compile-maximum-latency,X-none-average_latency,X-none-latency-deviation,X-none-maximum-latency,X-video-average_latency,X-video-latency-deviation,X-video-maximum-latency,X-burn-average_latency,X-burn-latency-deviation,X-burn-maximum-latency,X-write-average_latency,X-write-latency-deviation,X-write-maximum-latency,X-read-average_latency,X-read-latency-deviation,X-read-maximum-latency,X-compile-average_latency,X-compile-latency-deviation,X-compile-maximum-latency,gaming-none-average_latency,gaming-none-latency-deviation,gaming-none-maximum-latency,gaming-video-average_latency,gaming-video-latency-deviation,gaming-video-maximum-latency,gaming-X-average_latency,gaming-X-latency-deviation,gaming-X-maximum-latency,gaming-burn-average_latency,gaming-burn-latency-deviation,gaming-burn-maximum-latency,gaming-write-average_latency,gaming-write-latency-deviation,gaming-write-maximum-latency,gaming-read-average_latency,gaming-read-latency-deviation,gaming-read-maximum-latency,gaming-compile-average_latency,gaming-compile-latency-deviation,gaming-compile-maximum-latency" >> "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE}"

echo "kernel_type,video-write-maximum-latency,X-compile-average_latency,X-compile-latency-deviation,X-compile-maximum-latency,gaming-compile-average_latency,gaming-compile-latency-deviation,gaming-compile-maximum-latency" >> "${CSV_OUTPUT_DIR}${CSV_OUTPUT_FILE_CHERRY_PICKED}"

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

