{{/*
Expand the name of the chart.
*/}}
{{- define "acend-training-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Hostname
*/}}
{{- define "acend-training-chart.hostname" -}}
{{- if or (eq .Release.Name "main") (eq .Release.Name "latest") }}
{{- printf "%s%s%s" .Values.ingress.appname "." .Values.ingress.domain }}
{{- else }}
{{- printf "%s%s%s%s%s" .Values.ingress.appname "-" .Release.Name "." .Values.ingress.domain }}
{{- end }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acend-training-chart.fullname" -}}
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
{{- define "acend-training-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "acend-training-chart.labels" -}}
helm.sh/chart: {{ include "acend-training-chart.chart" . }}
{{ include "acend-training-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "acend-training-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acend-training-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "acend-training-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "acend-training-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
