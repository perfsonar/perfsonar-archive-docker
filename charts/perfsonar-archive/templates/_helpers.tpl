{{- define "perfsonar-archive.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "perfsonar-archive.fullname" -}}
{{- if .Values.fullnameOverride }}{{ .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}{{- else }}{{- printf "%s-%s" .Release.Name (include "perfsonar-archive.name" .) | trunc 63 | trimSuffix "-" }}{{- end }}
{{- end }}

{{- define "perfsonar-archive.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "perfsonar-archive.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "perfsonar-archive.selectorLabels" -}}
app.kubernetes.io/name: {{ include "perfsonar-archive.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
