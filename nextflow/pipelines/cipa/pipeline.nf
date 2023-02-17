#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.timestamp = '$(date +%Y%m%d_%H%M%S%Z)'

process test {
    cpus "$params.cpusPerSample"
    queue 'default'
    container "$params.azureRegistryServer/default/cipa:latest"

    output:
        stdout

    script:
        """
        mkdir -p "${params.azureFileShare}/${params.runId}/results/"
        mkdir -p "${params.azureFileShare}/${params.runId}/logs/${params.drugName}"/
        cd /app/cipa/hERG_fitting/
        chmod +x ./entrypoint.sh 
        rm -rf results/*
        ./entrypoint.sh $params.drugName $task.cpus $params.numberOfSamples
        cp -rv results/*  "${params.azureFileShare}/${params.runId}/results/"
        cp -rv logs/*  "${params.azureFileShare}/${params.runId}/logs/${params.drugName}"/
        """
}

workflow {
     test | view
}


