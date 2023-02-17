#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.timestamp = '$(date +%Y%m%d_%H%M%S%Z)'

process test {
    cpus "$params.cpusPerSample"
    queue 'cipa'
    container "$params.azureRegistryServer/default/cipa:latest"

    output:
        stdout

    script:
        """
        mkdir "${params.azureFileShare}/results/"
        mkdir  "${params.azureFileShare}/logs/"
        cd /app/cipa/hERG_fitting/
        chmod +x ./entrypoint.sh 
        rm -rf results/*
        ./entrypoint.sh $params.drugName $task.cpus $params.numberOfSamples
        cp -r results/*  "${params.azureFileShare}/results/"
        cp -r logs/*  "${params.azureFileShare}/logs/"
        """
}

workflow {
     test | view
}


