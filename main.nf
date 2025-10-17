#!/usr/bin/env nextflow

// Load the modules with aliases for second round
include { get_reads } from './bin/process_hifi.nf'

include { purge_dups_mmp2;
          purge_dups_split_self_align;
          purge_dups_purge_haplotigs_overlaps;
          process_purged_seqs } from './bin/PurgeDups.nf'

include { runQuast } from './bin/Quast.nf'
include { runBusco } from './bin/Busco.nf'


// Second round aliases
include { purge_dups_mmp2 as purge_dups_mmp2_r2;
          purge_dups_split_self_align as purge_dups_split_self_align_r2;
          purge_dups_purge_haplotigs_overlaps as purge_dups_purge_haplotigs_overlaps_r2;
          process_purged_seqs as process_purged_seqs_r2 } from './bin/PurgeDups.nf'

include { runQuast as runQuast_r2} from './bin/Quast.nf'
include { runBusco as runBusco_r2 } from './bin/Busco.nf'

// Define the workflows
workflow QC_round1 {
    take:
    assembly_ch
    asm_name

    main:
    runQuast(assembly_ch, asm_name)
    runBusco(assembly_ch, asm_name)

    emit:
    quast = runQuast.out
    busco = runBusco.out
}

workflow QC_round2 {
    take:
    assembly_ch
    asm_name

    main:
    runQuast_r2(assembly_ch, asm_name)
    runBusco_r2(assembly_ch, asm_name)

    emit:
    quast = runQuast_r2.out
    busco = runBusco_r2.out

}

workflow purge_dups_round1 {
    log.info "First round: Purging your assembly with purge_dups"

    take:
    primary_assembly
    processed_reads

    main:
    purge_dups_mmp2(processed_reads, primary_assembly)
    purge_dups_split_self_align(primary_assembly)
    purge_dups_purge_haplotigs_overlaps(purge_dups_split_self_align.out,
        purge_dups_mmp2.out.pb_base_cov)
    process_purged_seqs(purge_dups_purge_haplotigs_overlaps.out,
        primary_assembly)

    emit:
    assembly = process_purged_seqs.out.assembly
    merged_purged = process_purged_seqs.out.merged_purged
}

workflow purge_dups_round2 {
    log.info "Second round: Purging the merger of purged reads and haplotigs"

    take:
    primary_assembly
    processed_reads

    main:
    purge_dups_mmp2_r2(processed_reads, primary_assembly)
    purge_dups_split_self_align_r2(primary_assembly)
    purge_dups_purge_haplotigs_overlaps_r2(purge_dups_split_self_align_r2.out,
        purge_dups_mmp2_r2.out.pb_base_cov)
    process_purged_seqs_r2(purge_dups_purge_haplotigs_overlaps_r2.out,
        primary_assembly)

    emit:
    assembly = process_purged_seqs_r2.out.assembly
    merged_purged = process_purged_seqs_r2.out.merged_purged
}

workflow {
    if (params.mode == 'default') {
        // Process reads once at the beginning
        processed_reads = get_reads(params.hifi_reads)
        
        // First round of purging
        purge_dups_out = purge_dups_round1(params.primary_asm, processed_reads)
        QC_round1(purge_dups_out.assembly, "first_round_purged")
        
        // Second round of purging
        purge_dups_out2 = purge_dups_round2(purge_dups_out.merged_purged, processed_reads)
        QC_round2(purge_dups_out2.assembly, "second_round_purged")
    }
}