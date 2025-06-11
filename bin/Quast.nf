process runQuast {
    conda params.quast_conda

    publishDir { "${params.outdir}/${asm_name}_quast_results" }, mode: 'copy'


    input:
    path genome_asm
    val asm_name

    output:
    path "${asm_name}_QUAST", emit: quast_results

    script:
    """
    quast -o ${asm_name}_QUAST -t ${params.nthreads} \
    --est-ref-size ${params.est_ref_size} \
    ${genome_asm}
    """
}
