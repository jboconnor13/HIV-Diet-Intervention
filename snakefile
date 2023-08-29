rule microbiome_qiime_processing:
    input:
        in_file = path_original + "original.txt"
    output:
        out_file = out_dir + "04-SELECTED-FEATURES-{reference}/"
                   "{reference}.txt"
    params:
        reference_time = "{reference}",
        absolute_values = "no",
        build_datatable = config["build_datatable"], # TODO have this be optional default true
        distance_matrices = config["distance_matrices"],
    conda: "conda_envs/r_env.yaml",
    script:
        "scripts/create_deltas.sh"


