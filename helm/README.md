# perfSONAR Archive Elasticsearch Configuration Helm Chart

This Helm chart configures an existing Elasticsearch instance for use as a perfSONAR archive. It sets up:

*   Elasticsearch users and roles (`pscheduler_logstash`, `pscheduler_reader`, `pscheduler_writer`).
*   Role mappings.
*   An Index Lifecycle Management (ILM) policy for `pscheduler` data streams.
*   Composable index templates (component templates and an index template) for `pscheduler` data streams, enabling modern Elasticsearch features.
*   A Kubernetes Job to apply these configurations to your Elasticsearch cluster.
*   A ConfigMap containing Logstash pipeline configuration files, designed to be consumed by a separate Logstash deployment.

This chart **does not** deploy Elasticsearch or Logstash itself. It assumes you have an existing Elasticsearch cluster and a separate Logstash deployment that will use the configurations provided by this chart.

## Prerequisites

*   Helm 3 installed.
*   A running Kubernetes cluster.
*   An existing Elasticsearch cluster (version 7.x or newer recommended for data streams).
*   `kubectl` configured to interact with your Kubernetes cluster.
*   (Optional but Recommended) An existing Logstash deployment, or a plan to deploy one, that can consume the generated ConfigMap.

## Chart Structure

helm/
├── Chart.yaml
├── values.yaml
├── README.md
├── files/
│ ├── roles/ # Elasticsearch role definitions
│ │ ├── pscheduler_logstash_role.json
│ │ ├── pscheduler_reader_role.json
│ │ └── pscheduler_writer_role.json
│ ├── role_mappings/ # Elasticsearch role mappings
│ │ ├── pscheduler_logstash_mapping.json
│ │ ├── pscheduler_reader_mapping.json
│ │ └── pscheduler_writer_mapping.json
│ ├── ilm_policies/ # ILM policy definitions
│ │ └── pscheduler_hot_warm_delete_policy.json
│ ├── component_templates/ # Composable template components
│ │ ├── pscheduler_mappings_component.json
│ │ └── pscheduler_settings_component.json
│ ├── index_templates/ # Composable index template for data streams
│ │ └── pscheduler_default_template.json
│ └── logstash_pscheduler_config/ # Logstash pipeline files
│ ├── pipeline/
│ │ ├── 01-inputs.conf
│ │ ├── # ... (other filter files like 10-common.conf, etc.)
│ │ └── 99-outputs.conf
│ └── ruby_scripts/
│ └── prometheus_parse.rb
└── templates/
├── _helpers.tpl
├── rbac.yaml
├── secrets-generated-passwords.yaml
├── configmap-es-configurations.yaml # Contains configure-es.sh script & ES JSON configs
├── configmap-logstash-pipeline.yaml # For Logstash pipeline files
└── job-configure-es.yaml # The K8s Job to configure ES


## Configuration

The primary way to configure this chart is through the `values.yaml` file or by providing your own values file during installation (`-f my-values.yaml`).

### Key Configuration Parameters (`values.yaml`)

*   **`existingElasticsearch`**:
    *   `host`: Hostname or service name of your Elasticsearch cluster.
    *   `port`: Port number for Elasticsearch (e.g., 9200).
    *   `scheme`: `http` or `https`.
    *   `adminCredentialsSecret`: Name of the Kubernetes secret containing Elasticsearch admin `username` and `password`.
    *   `caBundleSecretName`: (Optional) Name of the Kubernetes secret containing `ca.crt` if your Elasticsearch uses a custom CA.
    *   `insecureSkipVerify`: (Optional, default `false`) Set to `true` to skip TLS verification (not recommended for production).

*   **`perfsonarUsers`**: Defines users to be created (e.g., `logstash`, `reader`, `writer`).
    *   `username`: The username for Elasticsearch.
    *   `roleName`: The Elasticsearch role to assign (must correspond to a file in `files/roles/`).
    *   `generatePassword.enabled`: If `true`, a password will be generated.
    *   `generatePassword.secretName`: Name of the Kubernetes secret where the generated password will be stored.
    *   `existingSecretName`: If you manage passwords externally, provide the name of a K8s secret containing the password.

*   **`roleMappings`**: Defines Elasticsearch role mappings.
    *   `enabled`: Set to `true` to apply this mapping.
    *   `mappingName`: The name of the role mapping in Elasticsearch.
    *   `fileName`: The corresponding JSON file in `files/role_mappings/`.

*   **`ilmPolicies`**: Defines ILM policies.
    *   `enabled`: Set to `true` to apply this policy.
    *   `policyName`: The name of the ILM policy in Elasticsearch (this name is also referenced in the settings component template).
    *   `fileName`: The corresponding JSON file in `files/ilm_policies/`.

*   **`componentTemplates`**: Defines component templates.
    *   `enabled`: Set to `true` to apply this component template.
    *   `templateName`: The name of the component template in Elasticsearch.
    *   `fileName`: The corresponding JSON file in `files/component_templates/`.

*   **`indexTemplates`**: Defines the main index template for data streams.
    *   `enabled`: Set to `true` to apply this index template.
    *   `templateName`: The name of the index template in Elasticsearch.
    *   `fileName`: The corresponding JSON file in `files/index_templates/`.

*   **`configJob`**: Configuration for the Kubernetes Job that applies settings.
    *   `image`: Container image for the job (defaults to `curlimages/curl`).
    *   `resources`: CPU/memory requests and limits.

*   **`logstashPschedulerPipeline`**:
    *   `enabled`: If `true`, creates a ConfigMap with Logstash pipeline files.
    *   `configMapName`: Name of the ConfigMap to be created.

*   **`rbac`**:
    *   `create`: If `true`, creates a ServiceAccount, Role, and RoleBinding for the configuration Job.
    *   `serviceAccountName`: Name of the ServiceAccount to use or create.

### Before Installation: Create Elasticsearch Admin Credentials Secret

The chart requires a Kubernetes secret containing the administrative username and password for your Elasticsearch cluster.

```bash
kubectl create secret generic elasticsearch-admin-credentials \
  --from-literal=username='YOUR_ES_ADMIN_USERNAME' \
  --from-literal=password='YOUR_ES_ADMIN_PASSWORD' \
  -n <your-namespace>
```

### (Optional) Create Elasticsearch CA Bundle Secret

If your Elasticsearch instance uses a custom CA certificate and you want secure communication (scheme: "https" and insecureSkipVerify: false), create a secret containing the CA certificate:

```bash
kubectl create secret generic elasticsearch-ca-cert \
  --from-file=ca.crt=/path/to/your/es-ca.crt \
  -n <your-namespace>
```

Then, set `existingElasticsearch.caBundleSecretName: "elasticsearch-ca-cert"` in your values.yaml.

### Installation