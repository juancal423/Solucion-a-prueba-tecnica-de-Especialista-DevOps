#!/bin/bash

# Agregar repositorio Helm de Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Actualizar repositorios Helm
helm repo update

# Crear namespace para Prometheus y Grafana
kubectl create namespace prometheus

# Instalar kube-prometheus-stack en el namespace prometheus
helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus

# Mostrar todos los recursos en el namespace prometheus
kubectl get all -n prometheus

# Port forward Prometheus (ejecutar en otro terminal si deseas acceso simultáneo)
echo "Ejecuta en otro terminal para acceder a Prometheus:"
echo "kubectl port-forward -n prometheus prometheus-prometheus-kube-prometheus-prometheus-0 9090"
echo "Accede en el navegador: http://localhost:9090"

# Obtener credenciales de Grafana
echo "Credenciales de Grafana:"
echo "Usuario:"
kubectl get secret -n prometheus prometheus-grafana -o jsonpath='{.data.admin-user}' | base64 --decode
echo ""
echo "Contraseña:"
kubectl get secret -n prometheus prometheus-grafana -o jsonpath='{.data.admin-password}' | base64 --decode
echo ""

# Port forward Grafana (ejecutar en otro terminal para acceso)
echo "Ejecuta en otro terminal para acceder a Grafana:"
echo "kubectl port-forward -n prometheus deployment/prometheus-grafana 3000"
echo "Accede en el navegador: http://localhost:3000"
