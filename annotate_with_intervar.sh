log_file='annotate_with_intervar_log.txt'
# Get the current date and time (start time)
start_time=$(date "+%Y-%m-%d %H:%M:%S")

# Append the start time to the log file
echo "========== RUN INTERVAR ==========" >> "$log_file"
echo "Start time: $start_time" >> "$log_file"

python InterVar/Intervar.py \
    --input=/path/to/normal_sample.deepvariant_filtered_merged.vcf \
    --input_type=VCF \
    --output=output \
    --buildver=hg38 \
    --database_intervar=/path/to/InterVar/intervardb \
    --table_annovar=/path/to/annovar/table_annovar.pl \
    --convert2annovar=/path/to/annovar/convert2annovar.pl \
    --annotate_variation=/path/to/annovar/annotate_variation.pl \
    --database_locat=/path/to/rayca/annovar/humandb

# Get the current date and time (end time)
end_time=$(date "+%Y-%m-%d %H:%M:%S")

# Calculate the runtime duration
start_seconds=$(date -d "$start_time" +%s)
end_seconds=$(date -d "$end_time" +%s)
runtime_seconds=$((end_seconds - start_seconds))

# Convert runtime to hours, minutes, and seconds
hours=$((runtime_seconds / 3600))
minutes=$(( (runtime_seconds % 3600) / 60 ))
seconds=$((runtime_seconds % 60))

# Append the end time and runtime duration to the log file
echo "End time: $end_time" >> "$log_file"
echo "Runtime duration: ${hours} hours, ${minutes} minutes, and ${seconds} seconds." >> "$log_file"

echo "Process complete. Log file: $log_file"