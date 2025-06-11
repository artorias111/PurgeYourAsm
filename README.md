# PurgeYourAsm

Purge your assembly with purge_dups (https://github.com/dfguan/purge_dups)

## Usage 
```shell
# Run with default parameters
nextflow run purge.nf --primary_asm assembly.fa --hifi_reads /path/to/hifi/reads
# example
nextflow run purge.nf --primary_asm /data2/work/Mmus.fa --hifi_reads /data2/work/Mmus_Revio_data


# Override parameters
nextflow run purge.nf \
  --primary_asm assembly.fa \
  --hifi_reads /path/to/reads/ \
  --busco_lineage vertebrata_odb10 \
  --nthreads 32 \
  --outdir /path/to/results/
```


### Additional usage information
you can also edit the `nextflow.log` file to your liking to run `purge_dups` as you see fit. 


### Output
