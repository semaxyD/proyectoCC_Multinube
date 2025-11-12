#!/bin/bash
echo "🔄 Reiniciando servicios en AKS..."

# Reiniciar Ingress Controller
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx

# Reiniciar microservicios
kubectl rollout restart deployment frontend-deployment -n microstore
kubectl rollout restart deployment users-deployment -n microstore
kubectl rollout restart deployment products-deployment -n microstore
kubectl rollout restart deployment orders-deployment -n microstore

echo "⏳ Esperando que los pods estén listos (esto puede tomar 2-3 minutos)..."
kubectl wait --for=condition=ready pod -l app=users -n microstore --timeout=300s
kubectl wait --for=condition=ready pod -l app=products -n microstore --timeout=300s
kubectl wait --for=condition=ready pod -l app=orders -n microstore --timeout=300s
kubectl wait --for=condition=ready pod -l app=frontend -n microstore --timeout=300s

echo "✅ Verificando Ingress..."
kubectl get ingress -n microstore

EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo ""
echo "🌐 Aplicación disponible en: http://$EXTERNAL_IP/"
echo "🧪 Probando endpoint de usuarios..."
curl -s http://$EXTERNAL_IP/api/users/ | head -20

echo ""
echo "✅ ¡Listo! Si ves JSON arriba, todo está funcionando."
