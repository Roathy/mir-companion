# 🔐 Keystore de Firma - mironline Companion App

## 📋 Información del Keystore

- **Archivo**: `mironline-release-key.jks`
- **Tipo**: PKCS12
- **Algoritmo**: RSA 2048-bit
- **Alias**: mironline-release-key
- **Validez**: Hasta 2053-01-07 (27+ años)
- **Fingerprint SHA256**: `CD:15:73:75:A7:77:33:B5:DD:43:1A:61:A0:69:74:75:82:F3:17:3D:AE:C2:78:48:90:4D:85:09:85:24:B8:F2`

## ⚠️ IMPORTANTE - SEGURIDAD

### 🔒 Backup y Custodia
- **CRÍTICO**: Este keystore es único e irreemplazable
- **BACKUP**: Hacer múltiples copias seguras en diferentes ubicaciones
- **ACCESO**: Solo personal autorizado debe tener acceso
- **PÉRDIDA**: Si se pierde, NO se pueden publicar actualizaciones en Play Store

### 🔑 Contraseñas
- **Store Password**: Configurada en `key.properties` (no incluir en git)
- **Key Password**: Igual que Store Password (limitación PKCS12)
- **Rotación**: Considerar cambio anual de contraseñas

## 🚀 Uso para Builds

### Build Release Local
```bash
# Asegurar que key.properties existe
flutter build apk --release
flutter build appbundle --release
```

### Build CI/CD con Variables de Entorno
```bash
export KEYSTORE_FILE="android/app/mironline-release-key.jks"
export KEYSTORE_PASSWORD="SECURE_PASSWORD_HERE"
export KEY_ALIAS="mironline-release-key"
export KEY_PASSWORD="SECURE_PASSWORD_HERE"

flutter build appbundle --release
```

## 🔍 Verificación de Firma

```bash
# Verificar que el APK está firmado correctamente
jarsigner -verify -verbose build/app/outputs/flutter-apk/app-release.apk

# Ver información del certificado
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
```

## 📚 Comandos Útiles

```bash
# Listar contenido del keystore
keytool -list -v -keystore mironline-release-key.jks

# Verificar expiración del certificado
keytool -list -keystore mironline-release-key.jks -alias mironline-release-key

# Cambiar contraseña del keystore
keytool -storepasswd -keystore mironline-release-key.jks
```

---
**Generado**: 2024-08-22  
**Validez del Certificado**: 2025-08-22 a 2053-01-07