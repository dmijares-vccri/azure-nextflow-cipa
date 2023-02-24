#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// params.timestamp = '$(date +%Y%m%d_%H%M%S%Z)'
params.timestamp = '$(date +%y%m%d_%H%M%S)'
params.pathazfs = "${params.azureFileShare}/${params.runId}"
params.pathtoresults = "${params.azureFileShare}/${params.runId}/results/${params.drugName}"
params.pathtologs = "${params.azureFileShare}/${params.runId}/logs/${params.drugName}"


process prerequisites  {
    cpus "$params.cpusPerSample"
    queue 'cipa'
    container "$params.azureRegistryServer/default/cipa:latest"

    output:
        val "${params.azureFileShare}/${params.runId}/results/${params.drugName}"

    script:
        """
        #go to working directory
        cd /app/cipa/hERG_fitting/
        #create folders on azure share
        mkdir -p "${params.pathtoresults}"
        mkdir -p "${params.pathtologs}"

        #clear results folder and create logs foldermexiletine
        rm -rf results/*
        mkdir -p "logs/${params.drugName}"

        Rscript generate_bootstrap_samples.R -d $params.drugName >\
            "logs/${params.drugName}/${params.drugName}_${params.timestamp}_generate_bootstrap_samples.R.txt"

        Rscript hERG_fitting.R -d $params.drugName -c $task.cpus -i 0 -l $params.population -t $params.accuracy >\
            "logs/${params.drugName}/${params.drugName}_${params.timestamp}_sample_0.txt" 

        cp -rv "results/${params.drugName}/"* "${params.pathtoresults}"
        cp -rv "logs/${params.drugName}/"* "${params.pathtologs}"
        """       
}

process parallel {
    cpus "$params.cpusPerSample"
    queue 'cipa'
    container "$params.azureRegistryServer/default/cipa:latest"
  
    input:
        val baseDir
        val sample

    output:
        stdout

    script:
        """
        #go to working directory
        cd /app/cipa/hERG_fitting/
        
        #delete existing results
        rm -rf results/*

        #create logs & results folders 
        mkdir -p "logs/${params.drugName}"
        mkdir -p "results/${params.drugName}"
        
        #copy results from previous process
        cp -rv "${baseDir}/"* results/${params.drugName} | 2>null
        
        #run analisys
        Rscript hERG_fitting.R -d $params.drugName -c $task.cpus -i $sample -l $params.population -t $params.accuracy >\
                "logs/${params.drugName}/${params.drugName}_${params.timestamp}_sample_${sample}.txt"

        #copy results & logs to the share
        cp -rv "results/${params.drugName}/"* "${params.pathtoresults}/"
        cp -rv "logs/${params.drugName}/"* "${params.pathtologs}/"
        """
}

workflow {
    def factorsOf80 = [0, 1, 2, 4, 5, 8, 10, 16, 20, 40, 80]
    if(params.cpusPerSample < 1) {
        err("Invalid input: cpusPerSample must be => 1.")
    }
    if (!factorsOf80.contains(params.cpusPerSample % 80)) {
        err("Invalid input: cpusPerSample must be a factor of 80.")
    }

    // Allow sample 0 to be run independently
    if (params.startSampleNumber == 0) {
        if (params.endSampleNumber != 0) {
            err("Invalid input: if startSampleNumber is 0 endSampleNumber must be 0.")
        }
        prerequisites()
    }
    
    // Make sure sample range is within bounds
    if (params.startSampleNumber > 0) {
        if (params.endSampleNumber > 2000) {
            err("Invalid input: endSampleNumber must be <= 2000.")
        }
        if (params.startSampleNumber > params.endSampleNumber) {
            err("Invalid input: startSampleNumber must be <= endSampleNumber.")
        }
        def dir = prerequisites()
        parallel(dir, Channel.from(params.startSampleNumber..params.endSampleNumber)) | view
    }
}