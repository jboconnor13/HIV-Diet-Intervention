configfile: "config/config.yaml"

rule microbiome_qiime_processing:
    input:
        input_dir = config["qiime_data_dir"]
    output:
        output_dir = config["qiime_data_dir"]
    conda:
        conda = "conda_envs/qiime2-2023.5"
    script:
        "scripts/create_deltas.sh"


