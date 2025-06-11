process get_reads {
// given a directory, get all the fastq.gz files in the directory

    input:
    path reads_dir

    output:
    path read_files_cleaned

    script:
    """
    mkdir read_files_cleaned
    python3 ${projectDir}/bin/process_hifi.py --hifi_dir ${reads_dir}
    mv *.fastq.gz read_files_cleaned
    """
}
