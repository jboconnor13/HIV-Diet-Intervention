configfile: "config/config.yaml"

rule microbiome_qiime_processing:
    input:
        input_dir = config["qiime_data_dir"]
    output:
        output_dir = config["qiime_data_dir"]
    script:
        "scripts/create_deltas.sh"


