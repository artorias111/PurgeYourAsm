process runBusco {
    conda params.busco_conda
        
    publishDir { "${params.outdir}/${asm_name}_busco_results" }, mode: 'copy'

    input:
    path genome_asm
    val asm_name

    output:
    path "${asm_name}_BUSCO", emit :busco_results

    script:
    """
    busco -o ${asm_name}_BUSCO \
    -i ${genome_asm} \
    -m geno \
    -l ${params.busco_lineage} \
    --download_path ${params.busco_db_path} \
    -c ${params.nthreads} \
    --offline
    """
}
