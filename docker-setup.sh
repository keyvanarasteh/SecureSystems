#!/usr/bin/env bash
# ============================================
# SecureSystems — Docker Ortam Kurulum Betiği
# ============================================
# İlk kullanımda ortamı hazırlar:
#   chmod +x docker-setup.sh
#   ./docker-setup.sh
# ============================================

set -euo pipefail

# Renkli çıktı
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { echo -e "${GREEN}[INFO]${NC}  $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# ─── Ön Kontroller ───
info "Docker kurulum kontrolü..."

if ! command -v docker &>/dev/null; then
    error "Docker kurulu değil. https://docs.docker.com/get-docker/"
fi

if ! command -v docker compose &>/dev/null; then
    error "Docker Compose kurulu değil. https://docs.docker.com/compose/install/"
fi

info "Docker sürümü: $(docker --version)"
info "Compose sürümü: $(docker compose version)"

# ─── .env Dosyası Kontrolü ───
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        warn ".env dosyası bulunamadı, .env.example kopyalanıyor..."
        cp .env.example .env
        info ".env oluşturuldu — lütfen değerleri doldurun."
    else
        warn ".env.example bulunamadı, boş .env oluşturuluyor..."
        touch .env
    fi
else
    info ".env dosyası mevcut."
fi

# ─── Çalışma Dizinleri ───
info "Çalışma dizinleri oluşturuluyor..."
mkdir -p workspace

# ─── Docker İmajlarını Derle ───
info "Ortak sandbox katmanı derleniyor..."
docker build -t securesystems-sandbox-common -f Dockerfile.sandbox-common .

info "Tüm servisler derleniyor..."
docker compose build

# ─── Sonuç ───
echo ""
info "=========================================="
info "  Kurulum tamamlandı!"
info "=========================================="
echo ""
echo "  Kullanılabilir komutlar:"
echo ""
echo "    docker compose up              # Tüm servisleri başlat"
echo "    docker compose up app          # Sadece uygulamayı başlat"
echo "    docker compose up -d           # Arka planda başlat"
echo "    docker compose --profile security up sandbox  # CLI sandbox"
echo "    docker compose logs -f app     # Logları takip et"
echo "    docker compose down            # Tüm servisleri durdur"
echo ""
