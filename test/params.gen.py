import json

# Define the list of items to generate JSON payloads for
my_list = ["dofetilide", "bepridil", "sotalol", "quinidine", "terfenadine", "ondansetron", "chlorpromazine", "verapamil", "ranolazine", "mexiletine", "diltiazem","cisapride"]

# Define the JSON template for the payload
json_template = {
    "runId": "CiPA_Results", 
    "drugName": "", 
    "numberOfSamples": 2000, 
    "population": 80, 
    "accuracy": 0.001, 
    "cpusPerSample": 40
    }

# Generate a JSON payload for each item in the list
for item in my_list:
    json_template['drugName'] = f"{item}"
    # Define the JSON payload file name based on the current item name
    json_file_name = f"{item}.json"
    # Write the JSON data to a file with the defined file name
    with open(json_file_name, 'w') as json_file:
        json.dump(json_template, json_file)