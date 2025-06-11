#!/usr/bin/env nextflow

process purge_dups_mmp2 {

    input: 
    path hifi_reads // list of read files, in fastq.gz
    path pri_asm

    output:
    path 'PB.base.cov', emit: pb_base_cov
    path 'PB.stat'

    script:
    """
    for i in ${hifi_reads}/*
    do
        bname=`basename \$i`
        minimap2 -xmap-pb -t ${params.nthreads} $pri_asm \$i | gzip -c - > \$bname.paf.gz
    done
    ${params.purge_dups}/bin/pbcstat *.paf.gz 
    ${params.purge_dups}/bin/calcuts PB.stat > cutoffs 2>calcults.log
    """

}

process purge_dups_split_self_align { 

    input: 
    path pri_asm

    output:
    path "${pri_asm}.split.self.paf.gz"

    script:
    """
    ASM_SPLIT_FILE="${pri_asm}.split"

    ${params.purge_dups}/bin/split_fa ${pri_asm} > \${ASM_SPLIT_FILE}
    minimap2 -xasm5 -DP \${ASM_SPLIT_FILE} \${ASM_SPLIT_FILE} | gzip -c - > "${pri_asm}.split.self.paf.gz"
    """

}

process purge_dups_purge_haplotigs_overlaps { 
    input: 
    path pri_asm_paf // output of purge_dups_split_self_align
    path PB_base_cov // output of purge_dups_mmp2

    output: 
    path 'dups.bed'

    script:
    """
    ${params.purge_dups}/bin/purge_dups -2 -T cutoffs -c ${PB_base_cov} ${pri_asm_paf} > dups.bed 2> purge_dups.log
    """

}



// This is for the process below
// Notice this command will only remove haplotypic duplications at the ends of the contigs. 
// If you also want to remove the duplications in the middle, please remove -e option at your 
// own risk, it may delete false positive duplications. For more options, 
// please refer to get_seqs -h.

process process_purged_seqs { 

    publishDir "${params.outdir}/purged_assemblies", mode: 'copy'

    input: 
    path dups_bed // output of purge_dups_purge_haplotigs_overlaps
    path pri_asm

    output:
    path "hap.fa", emit :purged_hap
    path "purged.fa", emit: assembly
    path "merged_purged.fa", emit: merged_purged

    script:
    """
    ${params.purge_dups}/bin/get_seqs -e ${dups_bed} ${pri_asm}
    cat hap.fa purged.fa > merged_purged.fa
    """
}
