#!/bin/sh

RAW_DATA="${SCRIPT_DIR}data/raw_data/"

SCRIPT_DIR="$(dirname $0)/../"
TRIMMED_DATA_DIR="${SCRIPT_DIR}data/unixbench_trimmed_data/"
EXTRACTED_DATA_DIR="${SCRIPT_DIR}data/unixbench_extracted_data/"
COMMA_SEPARATED_DATA_DIR="${SCRIPT_DIR}data/unixbench_comma_separated_data/"
CSV_OUTPUT_FILE="${SCRIPT_DIR}pca_input_data/unixbench.csv"

ls -l "$TRIMMED_DATA_DIR"
echo && echo && echo

ls -l "$EXTRACTED_DATA_DIR"
echo && echo && echo

ls -l "$COMMA_SEPARATED_DATA_DIR"
echo && echo && echo

ls -l "$(dirname ${CSV_OUTPUT_FILE})" 
echo && echo && echo

rm -r "$TRIMMED_DATA_DIR"
rm -r "$EXTRACTED_DATA_DIR"
rm -r "$COMMA_SEPARATED_DATA_DIR"
rm "${CSV_OUTPUT_FILE}"
rm "${CSV_OUTPUT_FILE}.merge_ready.csv"
rm "${CSV_OUTPUT_FILE}.dataset"
rm "${CSV_OUTPUT_FILE}.merge_ready.dataset"

mkdir -p "$TRIMMED_DATA_DIR"
mkdir -p "$EXTRACTED_DATA_DIR"
mkdir -p "$COMMA_SEPARATED_DATA_DIR"
mkdir -p "$(dirname ${CSV_OUTPUT_FILE})" 

 lines_with_metrics_singlethreaded=( 6 14 22 34 46 58 66 75 83 93 103 112 211 )
lines_with_metrics_multithreaded=( 237 245 253 265 277 289 297 306 314 324 334 343 442 )

for raw_data_file in $(ls ${RAW_DATA}unixbench-*)
do
  trimmed_file_name="trimmed-$(basename ${raw_data_file})"
  echo ${TRIMMED_DATA_DIR}${trimmed_file_name}
  echo ${RAW_DATA}$raw_data_file

  # cut out scores
  cat $raw_data_file | tail -n 63 | head -n 62 | tr -s ' ' | tr ' ' '\n' | sed '/^$/d' > ${TRIMMED_DATA_DIR}${trimmed_file_name}

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

  # append lines with singlethreaded scores
  for line_number in ${lines_with_metrics_singlethreaded[@]}
  do
    sed -n ${line_number}p ${TRIMMED_DATA_DIR}${trimmed_data_file} >> ${EXTRACTED_DATA_DIR}${extracted_file_name}

  done

  # append lines with multithreaded scores
  for line_number in "${lines_with_metrics_multithreaded[@]}"
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
  cat ${EXTRACTED_DATA_DIR}${extracted_data_file} | tr '\n' ',' | sed 's/,$/\n/' >> ${COMMA_SEPARATED_DATA_DIR}${comma_separated_file_name}

done

# add columns to CSV file
echo "kernel_type,Dhrystone_2_using_register_variables-1_parallel_copy,Double-Precision_Whetstone-1_parallel_copy,Execl-Throughput-1_parallel_copy,File_Copy_1024_bufsize_2000_maxblocks-1_parallel_copy,File_Copy_256_bufsize_500_maxblocks-1_parallel_copy,File_Copy_4096_bufsize_8000_maxblocks-1_parallel_copy,Pipe_Throughput-1_parallel_copy,Pipe-based_Context_Switching-1_parallel_copy,Process_Creation-1_parallel_copy,Shell_Scripts_(1_concurrent)-1_parallel_copy,Shell_Scripts_(8_concurrent)-1_parallel_copy,System_Call_Overhead-1_parallel_copy,System_Benchmarks_Index_Score-1_parallel_copy,Dhrystone_2_using_register_variables-4_parallel_copies,Double-Precision_Whetstone-4_parallel_copies,Execl-Throughput-4_parallel_copies,File_Copy_1024_bufsize_2000_maxblocks-4_parallel_copies,File_Copy_256_bufsize_500_maxblocks-4_parallel_copies,File_Copy_4096_bufsize_8000_maxblocks-4_parallel_copies,Pipe_Throughput-4_parallel_copies,Pipe-based_Context_Switching-4_parallel_copies,Process_Creation-4_parallel_copies,Shell_Scripts_(1_concurrent)-4_parallel_copies,Shell_Scripts_(8_concurrent)-4_parallel_copies,System_Call_Overhead-4_parallel_copies,System_Benchmarks_Index_Score-4_parallel_copies" >> "$CSV_OUTPUT_FILE"

echo
echo "Merge all comma separated value files into one CSV file"
echo
echo "$CSV_OUTPUT_FILE"
echo

for comma_separated_file in $(ls ${COMMA_SEPARATED_DATA_DIR})
do
  echo $comma_separated_file >> "$CSV_OUTPUT_FILE"

  cat ${COMMA_SEPARATED_DATA_DIR}${comma_separated_file} >> "$CSV_OUTPUT_FILE"

done

# clean up the file
sed -i 's/comma_separated-extracted-trimmed-unixbench-//g' "$CSV_OUTPUT_FILE"

sed -i ':a;N;$!ba;s/\.txt\n/,/g' "$CSV_OUTPUT_FILE"

# wrap string to apostrophes
sed -i "s/^/'/g" "${CSV_OUTPUT_FILE}"
sed -i "0,/'/s/'//" "${CSV_OUTPUT_FILE}"

sed -i "s/,/',/" "${CSV_OUTPUT_FILE}"
sed -i "0,/',/s/'//" "${CSV_OUTPUT_FILE}"

# create dataset files for merging
cat "${CSV_OUTPUT_FILE}" | cut -d',' --complement -f1 > "${CSV_OUTPUT_FILE}.merge_ready.csv"

# create dataset
cat "${CSV_OUTPUT_FILE}" | tr ',' '\t' > "${CSV_OUTPUT_FILE}.dataset"
cat "${CSV_OUTPUT_FILE}.merge_ready.csv" | tr ',' '\t' > "${CSV_OUTPUT_FILE}.merge_ready.dataset"

