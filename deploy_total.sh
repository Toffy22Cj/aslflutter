
# DEPLOY TOTAL - Todas las opciones sin cable
echo "🚀 ASL App - DEPLOY TOTAL (Sin Cables)"

# Build
echo "🔨 Construyendo APK..."
flutter clean && flutter pub get && flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
SIZE=$(du -h "$APK_PATH" | cut -f1)
echo "✅ APK generado: $SIZE"

# Obtener IP local
get_ip() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "127.0.0.1")
    else
        IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "127.0.0.1")
    fi
    echo "$IP"
}

# Generar QR en terminal
generate_qr() {
    local url="$1"
    if command -v qrencode &> /dev/null; then
        echo "📲 QR Code:"
        qrencode -t ANSI "$url"
    else
        echo "💡 Instala qrencode para QR: brew install qrencode"
    fi
}

# Servidor local con QR
start_local_server() {
    local IP=$(get_ip)
    local PORT=8000

    # Crear página HTML mejorada
    cat > build/app/outputs/flutter-apk/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>ASL App - Descargar</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, sans-serif;
            text-align: center;
            padding: 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 20px;
            backdrop-filter: blur(10px);
            max-width: 500px;
            margin: 0 auto;
        }
        .btn {
            background: #00d2ff;
            color: white;
            padding: 15px 30px;
            text-decoration: none;
            border-radius: 50px;
            display: inline-block;
            font-weight: bold;
            margin: 10px;
            transition: transform 0.3s;
        }
        .btn:hover { transform: scale(1.05); }
        .qr { margin: 20px auto; background: white; padding: 20px; border-radius: 10px; display: inline-block; }
        .info { background: rgba(0,0,0,0.2); padding: 15px; border-radius: 10px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 ASL App</h1>
        <div class="info">
            <p>⚡ Versión: $(date '+%d/%m/%Y %H:%M')</p>
            <p>📦 Tamaño: $SIZE</p>
            <p>🌐 IP: $IP</p>
        </div>

        <a href="app-release.apk" class="btn">⬇️ DESCARGAR APK</a>

        <div class="qr">
            <img src="https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=http://$IP:$PORT/app-release.apk&format=png"
                 alt="QR Code" width="200" height="200">
            <br>
            <small>📷 Escanea con tu teléfono</small>
        </div>

        <p style="margin-top: 30px; font-size: 12px; opacity: 0.8;">
            Conectado a la misma red WiFi • Puerto: $PORT
        </p>
    </div>
</body>
</html>
EOF

    echo "🌐 Servidor local iniciado:"
    echo "📱 http://$IP:$PORT"
    echo ""
    generate_qr "http://$IP:$PORT"
    echo ""
    echo "💡 Mantén este terminal abierto. Presiona Ctrl+C para detener."

    cd build/app/outputs/flutter-apk/
    python3 -m http.server $PORT
}

# Google Drive (abrir carpeta)
google_drive_method() {
    echo "📤 Método Google Drive:"
    echo "1. 📂 Abriendo carpeta del APK..."
    open build/app/outputs/flutter-apk/
    echo "2. 🌐 Ve a https://drive.google.com"
    echo "3. ⬆️ Sube el archivo 'app-release.apk'"
    echo "4. 🔗 Comparte el enlace"
    echo ""
    echo "📲 O usa: Dropbox, OneDrive, iCloud, etc."
}

# Telegram
telegram_method() {
    echo "🤖 Método Telegram:"
    echo "1. 💬 Abre Telegram en tu teléfono"
    echo "2. 👤 Ve a 'Saved Messages' o un chat"
    echo "3. 📎 Adjunta el APK desde la carpeta:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo "4. 📤 Envíatelo a ti mismo"
    echo ""
    open build/app/outputs/flutter-apk/
}

# WhatsApp
whatsapp_method() {
    echo "💬 Método WhatsApp:"
    echo "1. 📱 Abre WhatsApp en tu teléfono"
    echo "2. 💬 Ve a un chat (puede ser tu propio chat)"
    echo "3. 📎 Adjunta documento → Buscar archivo"
    echo "4. 📁 Navega a la carpeta de descargas"
    echo "5. 🔍 Busca 'app-release.apk' y envíalo"
    echo ""
    open build/app/outputs/flutter-apk/
}

# Link temporal
temporal_link_method() {
    echo "🔗 Generando link temporal..."
    echo "⏳ Subiendo APK a transfer.sh..."

    if command -v curl &> /dev/null; then
        URL=$(curl --silent --upload-file "$APK_PATH" https://transfer.sh/app-release.apk)
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ LINK TEMPORAL GENERADO:"
            echo "🌐 $URL"
            echo ""
            generate_qr "$URL"
            echo ""
            echo "⏰ Este link expira en 14 días"
            echo "📱 Compártelo por cualquier app"
        else
            echo "❌ Error al subir el archivo"
        fi
    else
        echo "❌ curl no instalado"
    fi
}

# Email method
email_method() {
    echo "📧 Método Email:"
    echo "1. 📬 Abre tu cliente de email"
    echo "2. ✉️ Envía un email a ti mismo"
    echo "3. 📎 Adjunta el archivo:"
    echo "   build/app/outputs/flutter-apk/app-release.apk"
    echo "4. 📥 Descárgalo en tu teléfono"
    echo ""
    open build/app/outputs/flutter-apk/
}

# Bluetooth method (macOS)
bluetooth_method() {
    echo "🔵 Método Bluetooth:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "1. 🔵 Activa Bluetooth en ambos dispositivos"
        echo "2. 📱 Empareja tu teléfono con la Mac"
        echo "3. 📤 Compartiendo archivo..."
        open -a "Bluetooth File Exchange" "$APK_PATH" 2>/dev/null || \
        echo "💡 Ve a Preferencias del Sistema → Bluetooth → Compartir archivo"
    else
        echo "🔵 Activa Bluetooth y envía el archivo manualmente"
    fi
    echo ""
    open build/app/outputs/flutter-apk/
}

# Airdrop (macOS only)
airdrop_method() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "🪂 Método Airdrop:"
        echo "1. 🔵 Activa Bluetooth y WiFi"
        echo "2. 📱 Activa Airdrop en tu iPhone"
        echo "3. 📤 Compartiendo via Airdrop..."
        open -a "AirDrop" 2>/dev/null || \
        echo "💡 Haz clic derecho en el APK → Compartir → Airdrop"
    else
        echo "🪂 Airdrop solo disponible en macOS"
    fi
    open build/app/outputs/flutter-apk/
}

# Mostrar todas las opciones
echo ""
echo "🎯 ELIGE MÉTODO DE DISTRIBUCIÓN:"
echo "1. 📱 Servidor Local WiFi + QR (RECOMENDADO)"
echo "2. 🌐 Google Drive/Cloud Storage"
echo "3. 🤖 Telegram"
echo "4. 💬 WhatsApp"
echo "5. 📧 Email"
echo "6. 🔗 Link Temporal + QR"
echo "7. 🔵 Bluetooth"
echo "8. 🪂 Airdrop (macOS)"
echo "9. 🎯 MOSTRAR TODAS LAS OPCIONES"
echo "0. ❌ Salir"

read -p "Selecciona (0-9): " choice

case $choice in
    1)
        start_local_server
        ;;
    2)
        google_drive_method
        ;;
    3)
        telegram_method
        ;;
    4)
        whatsapp_method
        ;;
    5)
        email_method
        ;;
    6)
        temporal_link_method
        ;;
    7)
        bluetooth_method
        ;;
    8)
        airdrop_method
        ;;
    9)
        echo ""
        echo "🎯 TODAS LAS OPCIONES DISPONIBLES:"
        echo "📱 APK listo en: $APK_PATH"
        echo ""
        echo "1. 🌐 WiFi Local: ./deploy_total.sh (opción 1)"
        echo "2. ☁️  Cloud: Sube a Drive/Dropbox/iCloud"
        echo "3. 💬 Mensajería: WhatsApp, Telegram, Signal"
        echo "4. 📧 Email: Envíatelo por correo"
        echo "5. 🔗 Link: Usa transfer.sh para link temporal"
        echo "6. 🔵 Bluetooth: Transferencia directa"
        echo "7. 🪂 Airdrop: Si tienes Apple devices"
        echo "8. 📂 USB: Copia manualmente (menos recomendado)"
        ;;
    0)
        echo "👋 ¡Hasta luego!"
        exit 0
        ;;
    *)
        echo "❌ Opción inválida. Ejecuta de nuevo."
        ;;
esac

echo ""
echo "✅ Recuerda: En Android, permite 'Instalar desde fuentes desconocidas'"
echo "📦 APK: $APK_PATH ($SIZE)"