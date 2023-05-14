nextflow.enable.dsl = 2

params.accession = "null"
params.outdir = "SRA_data"

include { prefetch } from "./prefetch_exam"
include { convertfastq } from "./fastq_dump_exam"
include { fastqc } from "./fastqc_report_exam"


process fastp {
  publishDir "${params.outdir}/sra/${accession}_fastq/", mode: 'copy', overwrite: true
  
  container "https://depot.galaxyproject.org/singularity/fastp:0.23.3--h5f740d0_0"

  input:
    path fastqfiles
    val accession

  output:
    path "fastp_fastq/*.fastq", emit: fastqfiles
    path "fastp_report", emit: fastpreport

  script:
      if(fastqfiles instanceof List) {
      """
      mkdir fastp_fastq
      mkdir fastp_report
      fastp -i ${fastqfiles[0]} -I ${fastqfiles[1]} -o fastp_fastq/${fastqfiles[0].getSimpleName()}_fastp.fastq -O fastp_fastq/${fastqfiles[1].getSimpleName()}_fastp.fastq -h fastp_report/fastp.html -j fastp_report/fastp.json
      """
    } else {
      """
      mkdir fastp_fastq
      mkdir fastp_report
      fastp -i ${fastqfiles} -o fastp_fastq/${fastqfiles.getSimpleName()}_fastp.fastq -h fastp_report/fastp.html -j fastp_report/fastp.json
      """
    }
}


workflow sradownloadhandle {
  take:
    accession
    outdir
    
  main:
    srafile = prefetch(accession)
    converted = convertfastq(accession, srafile).fastqfiles
    trimmed = fastp(converted, accession).fastqfiles 
    trimmed_flat = trimmed.flatten()
    report = fastqc(trimmed_flat.collect()).results

  emit:
    trimmedfastq = trimmed_flat
    fastqc_out = report
}

workflow {
  pipelineresults = sradownloadhandle(params.accession, params.outdir)
  pipelineresults.fastqc_out.view()
  pipelineresults.trimmedfastq.view()
}