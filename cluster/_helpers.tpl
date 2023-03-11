{{- define "clickhouse.monitor.container" }}
- name: clickhouse-monitor
  image: {{ .clickhouse.monitor.image.repository }}:{{ .clickhouse.monitor.image.tag }}
  imagePullPolicy: {{ .clickhouse.monitor.image.pullPolicy }}
  env:
    - name: CLICKHOUSE_USERNAME
      valueFrom:
        secretKeyRef: 
          name: clickhouse-secret
          key: username
    - name: CLICKHOUSE_PASSWORD
      valueFrom:
        secretKeyRef:
          name: clickhouse-secret
          key: password
    - name: DB_URL
      value: "tcp://localhost:9000"
    - name: TABLE_NAME
      value: "default.flows"
    - name: MV_NAMES
      value: "default.flows_pod_view default.flows_node_view default.flows_policy_view"
    - name: STORAGE_SIZE
      value: {{ .clickhouse.storageSize | quote }}
    - name: THRESHOLD
      value: {{ .clickhouse.monitor.threshold | quote }}
    - name: DELETE_PERCENTAGE
      value: {{ .clickhouse.monitor.deletePercentage | quote }}
{{- end }}

{{- define "clickhouse.container" }}
- name: clickhouse
  image: {{ .clickhouse.image.repository }}:{{ .clickhouse.image.tag }}
  imagePullPolicy: {{ .clickhouse.image.pullPolicy }}
  volumeMounts:
    {{- if .schema }}
    - name: clickhouse-configmap-volume
      mountPath: /docker-entrypoint-initdb.d
    {{- end }}
    {{- if not .clickhouse.persistentVolume.enable }}
    - name: clickhouse-storage-volume
      mountPath: /var/lib/clickhouse
    {{- end }}
{{- end }}

{{- define "clickhouse.volume" }}
- name: clickhouse-configmap-volume
  configMap:
    name: clickhouse-mounted-configmap
{{- if not .clickhouse.persistentVolume.enable }}
- name: clickhouse-storage-volume
  emptyDir:
    medium: Memory
    sizeLimit: {{ .clickhouse.storageSize }}
{{- end }}
{{- end }}