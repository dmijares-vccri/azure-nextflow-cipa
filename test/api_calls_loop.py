import requests
import time

base_url = "https://fc7z3c.azurewebsites.net/api/nxfutil"
headers = {"content-type": "application/json"}
variables = ["dofetilide", "bepridil", "sotalol", "quinidine", "cisapride", "terfenadine", "ondansetron", "chlorpromazine", "verapamil", "ranolazine", "mexiletine", "diltiazem"]

retry_limit = 3 # maximum number of retries
retry_count = 0

for variable in variables:
    retry = True
    retry_count = 0

    while retry and retry_count < retry_limit:
        url = f"{base_url}"
        payload = {
            "config_uri": "https://raw.githubusercontent.com/dmijares-vccri/azure-nextflow-cipa/main/nextflow/pipelines/nextflow.config",
            "pipeline_uri": "https://raw.githubusercontent.com/dmijares-vccri/azure-nextflow-cipa/main/nextflow/pipelines/cipa/pipeline.nf",
            "parameters_uri": f"https://raw.githubusercontent.com/dmijares-vccri/azure-nextflow-cipa/main/nextflow/pipelines/cipa/drugs/{variable}.json",
            "auto_delete": True
        }

        response = requests.post(url, headers=headers, json=payload)

        if response.status_code == 200:
            # API call was successful
            print(response.json())
            retry = False
        else:
            # Handle error and retry after some delay
            print(f"Error: {response.status_code}, retrying in 5 seconds...")
            retry_count += 1
            time.sleep(5)

    if retry_count >= retry_limit:
        print(f"API call failed for variable {variable} after {retry_count} retries")
