nextflow.enable.dsl = 2

params.accession = "null"
params.outdir = "SRA_data"

include {prefetch} from "./prefetch_exam"

process convertfastq {
  storeDir "${params.outdir}/sra/${accession}_fastq/raw_fastq"

  container "https://depot.galaxyproject.org/singularity/sra-tools:3.0.3--h87f3376_0"

  input: 
    val accession
    path srafile

  output:
     path '*.fastq'

  script:
  """
  fastq-dump --split-files ${srafile}
  """
}
workflow {
    srafile = prefetch(params.accession)
    convertfastq(params.accession, srafile)
}