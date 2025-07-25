task eqtl_prepare_expression {

    File tpm_gct
    File counts_gct
    File annotation_gtf
    File sample_participant_ids
    File vcf_chr_list
    File sample_list
    String prefix

    Float? tpm_threshold
    Int? count_threshold
    Float? sample_frac_threshold
    String? normalization_method
    String? flags  # --convert_tpm, --legacy_mode

    command {
        set -euo pipefail
        /src/eqtl_prepare_expression.py ${tpm_gct} ${counts_gct} \
        ${annotation_gtf} ${sample_participant_ids} ${vcf_chr_list} ${prefix} \
        ${"--tpm_threshold " + tpm_threshold} \
        ${"--sample_ids " + sample_list} \
        ${"--count_threshold " + count_threshold} \
        ${"--sample_frac_threshold " + sample_frac_threshold} \
        ${"--normalization_method " + normalization_method} \
        ${flags}
    }

    runtime {
        docker: "quay.io/jonnguye/modified_gtex_eqtl:1.1"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
    }

    output {
        File expression_bed="${prefix}.expression.bed.gz"
        File expression_bed_index="${prefix}.expression.bed.gz.tbi"
    }

    meta {
        author: "Francois Aguet"
    }
}

task compute_PCs{
    File expression_bed
    File genotype_covariates 
    String prefix

    command {

    Rscript /tmp/compute_PCS.R \
        --expression_bed ${expression_bed} \
        --genotype_covariates ${genotype_covariates} \
        --output_prefix ${prefix}

    }
    runtime {
        docker: "evinpadhi/prepare_qtl:latest"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${num_threads}"
    }

    output {
        File expression_bed="${prefix}.expression.bed.gz"
        File expression_bed_index="${prefix}.expression.bed.gz.tbi"
    }

    meta {
        author: "Evin Padhi"
    }
} 

workflow prepare_QTL_data {
    
    Int memory
    Int disk_space
    Int num_threads
    Int disk_space

    call eqtl_prepare_expression
    call compute_PCs
}
