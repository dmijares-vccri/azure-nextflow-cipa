#!/bin/bash

###
# how to use this script
###
# ./script.sh DRUG CPU [SAMPLES] [POPULATION] [ACCURACY] 
###
# Constants
LOG_DIRECTORY="${APP_DIR}/cipa/hERG_fitting/logs"
DEFAULT_SAMPLES=0 #up to 2000
DEFAULT_ACCURACY=0.001
DEFAULT_POPULATION=80

# Define variables
drug=$1
cpu=$2
samples=${3:-$DEFAULT_SAMPLES}
population=${4:-$DEFAULT_POPULATION}
accuracy=${5:-$DEFAULT_ACCURACY}

# Define log file
timestamp=$(date +%y%m%d_%H%M%S)
log_name=${drug}_${timestamp}
log_file="${LOG_DIRECTORY}/${log_name}"

# Input validation
if [ -z "$drug" ] || [ -z "$cpu" ]; then
echo "Error: Missing required input parameters. Usage: ./entrypoint.sh DRUG CPU [SAMPLES] [POPULATION] [ACCURACY]"
exit 1
fi

# Run the first Rscript
if ! Rscript generate_bootstrap_samples.R -d "$drug" > "${log_file}_generate_bootstrap_samples.R.txt"; then
echo "Error: generate_bootstrap_samples.R failed. Check log file for details: ${log_file}_generate_bootstrap_samples.R.txt"
exit 1
fi

# # Run the second Rscript
# Start a for loop that will repeat a set number of times
for ((counter=0; counter<=$samples; counter++))
do
  if ! Rscript hERG_fitting.R -d "$drug" -c "$cpu" -i "$counter" -l "$population" -t "$accuracy" > "${log_file}_sample_${counter}.txt"; then
    echo "Error: hERG_fitting.R failed. Check log file for details: ${log_file}_sample_${counter}.txt"
    exit 1
  fi
done

echo "Success: Rscripts completed successfully. Log file: $log_file"