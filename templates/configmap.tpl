apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ template "nginx-suave.fullname" . }}
data:
  nginx.conf: |-
    events { }
    http {
        upstream littlesuave {
            server 127.0.0.1:8080;
        }

        server {
            location /api {
                proxy_pass http://littlesuave;
            }
        }
    }