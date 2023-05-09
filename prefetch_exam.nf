nextflow.enable.dsl = 2

params.accession = "null" 
params.outdir = "SRA_data" 


process prefetch {
  storeDir "${params.outdir}"
  container "https://depot.galaxyproject.org/singularity/sra-tools:3.0.3--h87f3376_0"

  input:
    val accession

  output:
    path "sra/${accession}.sra", emit: srafile 

  script:
    """
    prefetch $accession 
    """
}

process showFile {
  publishDir "${params.outdir}", mode: "copy", overwrite: true
  
  input:
    path sraresult

  output:
    path "fileinfo.txt"

  script:
    """
    echo "${sraresult}" > fileinfo.txt
    """
}

workflow {
  sraresult = prefetch(params.accession)
  sraresult.view()
  showFile(sraresult)
}