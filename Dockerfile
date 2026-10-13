
FROM python:3.12-slim

WORKDIR /app

COPY app.py .

ENV APP_NAME=MicroApp
ENV APP_PORT=8080
ENV APP_VERSION=3.0.0

EXPOSE 8080

CMD ["python", "-u", "app.py"]
