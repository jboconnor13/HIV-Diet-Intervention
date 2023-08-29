



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



rule random_forest:
    input:
        in_file = out_dir + "04-SELECTED-FEATURES-{reference}/{reference}.txt"
    output:
        out_file = out_dir + "04-SELECTED-FEATURES-{reference}/{reference}.pdf"
    params:
        dataset = "{reference}",
        random_effect = config["random_effect"],
        sample_id = config["sample_id"],
        response_var = config["response_var"],
        max_features = config["max_features"],
        n_estimators = config["n_estimators"],
        iterations = config["iterations"],  # 20 suggested, 10 testing (MERF)
        borutashap_threshold = config["borutashap_threshold"],
        borutashap_p = config["borutashap_p"],
        borutashap_trials = config["borutashap_trials"]
    conda: "conda_envs/merf.yaml"
    script:
        "scripts/random_forest.py"

# TODO see if I can create these files for deltas on original timepoint check
# feature summaries
rule final_steps_r:
    input:
        selected_features_original = path_original + "original-boruta-important.txt",
        selected_features_first = path_first + "first-boruta-important.txt",
        selected_features_previous = path_previous + "previous-boruta-important.txt",
        selected_features_pairwise = path_pairwise + "pairwise-boruta-important.txt"
    output:
        out_file = out_dir + "all-important-features.txt",
        out_file_image = out_dir + "important-feature-occurrences.svg",
    conda: "conda_envs/r_env.yaml",
    script:
        "scripts/feature-heatmaps.R"


rule final_steps_python:
    input: 
        feature_file = out_dir + "all-important-features.txt",
        original_features = path_original + "original-boruta-important.txt",
        first_features = path_first + "first-boruta-important.txt",
        previous_features = path_previous + "previous-boruta-important.txt",
        pairwise_features = path_pairwise + "pairwise-boruta-important.txt"
    output:
        out_file = out_dir + "urls.txt",
    conda: "conda_envs/merf.yaml",
    script:
        "scripts/url_interpretation.py"

rule render_report:
    input:
        original_log = path_original + "original-log.txt",
        first_log = path_first + "first-log.txt",
        previous_log= path_previous + "previous-log.txt",
        pairwise_log = path_pairwise + "pairwise-log.txt",
        feature_occurances = out_dir + "important-feature-occurrences.svg",
        urls = out_dir + "urls.txt",
        # post_hoc = path_post_hoc + "post-hoc-analysis.html",
        # post_hoc_viz = path_post_hoc + "post-hoc-combined.pdf"
    output:
        md_doc=config["report_name"],
    conda: "conda_envs/r_env.yaml",
    script:
        "scripts/report.Rmd"
