{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "ltutil.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ltutil.fullname" -}}
{{- $name := include "ltutil.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ltutil.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
namespace.
*/}}
{{- define "ltutil.namespace" -}}
{{- printf "%s-%s" (include "ltutil.name" .) .Release.Name -}}
{{- end -}}


{{/*
namespace.
*/}}
{{- define "ltutil.domain" -}}
{{- printf "%s.%s.%s" .Release.Name .Values.stage .Values.domain -}}
{{- end -}}


{{/*
Manage the labels for each entity
*/}}
{{- define "ltutil.labelsshort" -}}
app.kubernetes.io/name: {{ include "ltutil.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}


{{/*
Manage the labels for each entity
*/}}
{{- define "ltutil.labels" -}}
app.kubernetes.io/name: {{ include "ltutil.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
helm.sh/chart: {{ include "ltutil.chart" . | quote }}
{{- end -}}


{{/*
Manage the labels for each entity
*/}}
{{- define "ltutil.labelcomponent" -}}
app.kubernetes.io/component: {{ . | quote }}
{{- end -}}


{{/*
Manage the labels for each entity
*/}}
{{- define "ltutil.labelshortall" -}}
{{- $values := index . 0 -}}
{{- $name := index . 1 -}}
{{ include "ltutil.labelsshort" $values }}
{{ include "ltutil.labelcomponent" $name }}
{{- end -}}


{{/*
Manage the labels for each entity
*/}}
{{- define "ltutil.labelall" -}}
{{- $values := index . 0 -}}
{{- $name := index . 1 -}}
{{ include "ltutil.labels" $values }}
{{ include "ltutil.labelcomponent" $name }}
{{- end -}}


{{/*
StorageClass
*/}}
{{- define "ltutil.storageClass" -}}
{{- if . }}
{{- if (eq "-" .) -}}
""
{{- else -}}
"{{ . }}"
{{- end }}
{{- end }}
{{- end -}}


{{/*
Extra environment variables. Either use
.extra:
  - key: value
or tpl, if you need template replacements
.tpl |
  - name: NAME
    value: {{TEMPLATE_STUFF}}
finally in your template:
{{ include "isoptera2.extraEnv" | indent X }}
*/}}
{{- define "ltutil.extraEnv" }}
{{- range $key, $value := .envExtra -}}
- name: {{ $key | quote }}
  value: {{ $value | quote }}
{{ end -}}
{{- if .envTpl }}
{{- with .envTpl }}
{{ tpl . $  }}
{{- end }}
{{- end }}
{{- end -}}

