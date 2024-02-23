#!/bin/sh
 
# Define the path to the binary
binary_path="/tmp/SLOB"
 
# Define the path to the awr logs
awr_log_path="/tmp/SLOB/awrlog"
 
# Check if the path exists
if [ ! -d "$awr_log_path" ]; then
    # If the path doesn't exist, create it
    mkdir -p "$awr_log_path"
    echo "Directory $awr_log_path created."
else
    echo "Directory $awr_log_path already exists."
fi
 
# Define the script to be executed
script_to_execute="runit.sh"
 
# Verify if slob.conf exists in the binary_path as a file or symlink
if [ -f "${binary_path}/slob.conf" ] || [ -L "${binary_path}/slob.conf" ]; then
    echo "slob.conf found in $binary_path"
else
    echo "slob.conf not found in $binary_path"
    exit 1
fi
 
 
# Define the values for the outer loop (SCHEMA)
schemas=(1 4 8 16 32 64)
# Define the values for the middle loop (THREAD)
threads=(1 4)
# Define the values for the inner loop (UPDATE_PCT)
update_percentages=(0 20 100)
 
# Loop through SCHEMA values
for schema in "${schemas[@]}"; do
    # Loop through THREAD values
    for thread in "${threads[@]}"; do
        # Loop through UPGRADE_PCT values
        for update_pct in "${update_percentages[@]}"; do
            # Update slob.conf with upgrade percent value
            echo "Set UPDATE_PCT ${binary_path}/slob.conf to $update_pct"
            sed -i "s/UPDATE_PCT=.*/UPDATE_PCT=$update_pct/" ${binary_path}/slob.conf
            cat $binary_path/slob.conf
            # Execute the script with the parameters
            echo "Executing $script_to_execute with SCHEMA: $schema, THREAD: $thread for UPDATE_PCT $update_pct"
            $binary_path/$script_to_execute -s "$schema" -t "$thread"
 
            # Rename the output files
            suffix="_s${schema}_t${thread}_p${update_pct}"
            mv "tm.out" "$awr_log_path/tm${suffix}.out"
            mv "iostat.out" "$awr_log_path/iostat${suffix}.out"
            mv "mpstat.out" "$awr_log_path/mpstat${suffix}.out"
            mv "vmstat.out" "$awr_log_path/vmstat${suffix}.out"
            mv "awr.txt" "$awr_log_path/awr${suffix}.txt"
            mv "awr.html.gz" "$awr_log_path/awr${suffix}.html.gz"
            mv "slob_debug.out" "$awr_log_path/slob_debug${suffix}.out"
            # Sleep for 2 minutes
            echo "short break for 120s"
            sleep 120
        done
    done
done
