{{/*
Expand the name of the chart.
*/}}
{{- define "hatchet.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hatchet.fullname" -}}
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
{{- define "hatchet.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "hatchet.frontend.labels" -}}
helm.sh/chart: {{ include "hatchet.chart" . }}
{{ include "hatchet.frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Backend labels
*/}}
{{- define "hatchet.backend.labels" -}}
helm.sh/chart: {{ include "hatchet.chart" . }}
{{ include "hatchet.backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Frontend selector labels
*/}}
{{- define "hatchet.frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hatchet.name" . }}-frontend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend selector labels
*/}}
{{- define "hatchet.backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hatchet.name" . }}-backend
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

####################

{{/*
Create the name of the service account to use
*/}}
{{- define "hatchet.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hatchet.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get list of enabled backend services
*/}}
{{- define "hatchet.backendServices" -}}
{{- $services := list -}}
{{- if .Values.api.enabled -}}
{{- $services = append $services "api" -}}
{{- end -}}
{{- if .Values.grpc.enabled -}}
{{- $services = append $services "grpc" -}}
{{- end -}}
{{- if .Values.controllers.enabled -}}
{{- $services = append $services "controllers" -}}
{{- end -}}
{{- if .Values.scheduler.enabled -}}
{{- $services = append $services "scheduler" -}}
{{- end -}}
{{- $services -}}
{{- end -}}

{{/*
Create backend service name
*/}}
{{- define "hatchet.backendServiceName" -}}
{{- $serviceName := .serviceName -}}
{{- $context := .context -}}
{{- $serviceConfig := index $context.Values $serviceName -}}
{{- if $serviceConfig.fullnameOverride -}}
{{- $serviceConfig.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if $serviceConfig.nameOverride -}}
{{- printf "%s-%s" $context.Release.Name $serviceConfig.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" $context.Release.Name $serviceName | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create backend service labels
*/}}
{{- define "hatchet.backendServiceLabels" -}}
{{- $serviceName := .serviceName -}}
{{- $context := .context -}}
helm.sh/chart: {{ include "hatchet.chart" $context }}
app.kubernetes.io/name: {{ $serviceName }}
app.kubernetes.io/instance: {{ $context.Release.Name }}
{{- if $context.Chart.AppVersion }}
app.kubernetes.io/version: {{ $context.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ $context.Release.Service }}
app.kubernetes.io/component: {{ $serviceName }}
{{- end -}}

{{/*
Create backend service selector labels
*/}}
{{- define "hatchet.backendServiceSelectorLabels" -}}
{{- $serviceName := .serviceName -}}
{{- $context := .context -}}
app.kubernetes.io/name: {{ $serviceName }}
app.kubernetes.io/instance: {{ $context.Release.Name }}
app.kubernetes.io/component: {{ $serviceName }}
{{- end -}}

{{/*
Create backend service account name
*/}}
{{- define "hatchet.backendServiceAccountName" -}}
{{- $serviceName := .serviceName -}}
{{- $context := .context -}}
{{- $serviceConfig := index $context.Values $serviceName -}}
{{- if $serviceConfig.serviceAccount.create -}}
{{- default (include "hatchet.backendServiceName" (dict "serviceName" $serviceName "context" $context)) $serviceConfig.serviceAccount.name -}}
{{- else -}}
{{- default "default" $serviceConfig.serviceAccount.name -}}
{{- end -}}
{{- end -}}
