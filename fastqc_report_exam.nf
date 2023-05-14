nextflow.enable.dsl = 2
params.accession = "null"
params.outdir = "SRA_data"

include { prefetch } from "./prefetch_exam"
include { convertfastq } from "./fastq_dump_exam"

process fastqc {
    publishDir "${params.outdir}/sra/${params.accession}_fastq/fastqc_results/"
    container "https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0"

    input:
        path fastqfiles

    output:
        path "*.html"
        path "*.zip"

    script:

        """
        fastqc ${fastqfiles}
        """
}

workflow sradownloadhandle {
    take:
        accession
        outdir

    main:
        srafile = prefetch(accession)
        fastq_raw = convertfastq (accession, srafile)
        fastq_raw_flat = fastq_raw.flatten()
        fastqc(fastq_raw)
    emit:
        raw_out = fastq_raw
}
workflow {
    sradownloadhandle(params.accession, params.outdir)
}