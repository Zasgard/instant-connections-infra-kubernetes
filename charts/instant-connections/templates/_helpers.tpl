{{- define "instant-connections.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "instant-connections.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "instant-connections.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "instant-connections.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "instant-connections.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: instant-connections
{{- end -}}

{{- define "instant-connections.redisHost" -}}
{{- if .Values.redis.enabled -}}
{{ printf "%s-redis-master" .Release.Name }}
{{- else -}}
{{- .Values.externalRedis.host -}}
{{- end -}}
{{- end -}}

{{- define "instant-connections.postgresHost" -}}
{{- if .Values.postgres.enabled -}}
{{ printf "%s-postgresql" .Release.Name }}
{{- else -}}
{{- .Values.externalDatabase.host -}}
{{- end -}}
{{- end -}}
