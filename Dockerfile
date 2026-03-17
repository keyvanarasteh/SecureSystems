# ============================================
# SecureSystems — Ana Uygulama Dockerfile
# ============================================
# Çok aşamalı (multi-stage) build:
#   1. Builder  → Bağımlılıkları kurar, uygulamayı derler
#   2. Runtime  → Sadece çalışma zamanında gereken dosyaları taşır
# ============================================

# ─── Aşama 1: Build ───
FROM node:22-alpine AS builder

WORKDIR /app

# Önce sadece bağımlılık dosyalarını kopyala (cache optimizasyonu)
COPY package.json package-lock.json* bun.lockb* ./

# Bağımlılıkları kur
RUN npm ci --omit=dev

# Kaynak kodu kopyala ve derle
COPY . .
RUN npm run build 2>/dev/null || echo "No build script configured yet"

# ─── Aşama 2: Runtime ───
FROM node:22-alpine AS runtime

# Güvenlik: root olmayan kullanıcı
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Builder'dan sadece gerekli dosyaları al
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/dist ./dist 2>/dev/null || true

# Ortam değişkenleri
ENV NODE_ENV=production
ENV PORT=3000

# Sağlık kontrolü
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

# Root olmayan kullanıcıya geç
USER appuser

EXPOSE ${PORT}

CMD ["node", "src/index.js"]
