# PurgeYourAsm

Purge your assembly with purge_dups (https://github.com/dfguan/purge_dups)

## Usage 
```shell
# clone this repository on your local machine
git clone https://github.com/artorias111/PurgeYourAsm.git && cd PurgeYourAsm

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

## Post run cleanup
Once the job is complete, you can clean up the intermediate files (which can be quite big) with these two commands
```shell
# dry run: Find out which files are going to be removed
nextflow clean -n
# cleanup
nextflow clean -f
```

## Output
There's 5 directories in `results` directory:
```shell
first_round_purged_busco_results
first_round_purged_quast_results
purged_assemblies
second_round_purged_busco_results
second_round_purged_quast_results
```
The final purged assembly (second run) is in `results/purged_assemblies/purged.fa` 

If, for some reason, the first round purged assembly is preferred, you can find the corresponding purged assembly in the `work` directory. Refer to `.nextflow.log` to find the location of the purged assembly of your first run. 
