{{/*
Expand the name of the chart.
*/}}
{{- define "perfsonar-archive-config-es.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "perfsonar-archive-config-es.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "perfsonar-archive-config-es.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "perfsonar-archive-config-es.labels" -}}
helm.sh/chart: {{ include "perfsonar-archive-config-es.chart" . }}
{{ include "perfsonar-archive-config-es.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "perfsonar-archive-config-es.selectorLabels" -}}
app.kubernetes.io/name: {{ include "perfsonar-archive-config-es.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "perfsonar-archive-config-es.jobServiceAccountName" -}}
{{- if .Values.rbac.create }}
{{- default (printf "%s-job" (include "perfsonar-archive-config-es.fullname" .)) .Values.rbac.serviceAccountName }}
{{- else }}
{{- default "default" .Values.rbac.serviceAccountName }}
{{- end }}
{{- end }}

{{/*
Helper to generate a random password if not using lookup for existing secrets.
This is used if a secret needs to be created fresh.
*/}}
{{- define "perfsonar-archive-config-es.generatePassword" -}}
{{- randAlphaNum .Values.configJob.passwordLength | nospace -}}
{{- end -}}