#!/bin/bash

echo "🔍 ================================"
echo "🔍 VERIFICACIÓN PRE-DEPLOY BACKEND"
echo "🔍 ================================"
echo ""

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar que estamos en la carpeta backend
if [ ! -f "index.js" ]; then
    echo -e "${RED}❌ Error: No se encuentra index.js${NC}"
    echo "   Ejecuta este script desde la carpeta backend/"
    exit 1
fi

echo -e "${GREEN}✅ Estás en la carpeta correcta${NC}"
echo ""

# Verificar package.json
echo "📦 Verificando package.json..."
if [ ! -f "package.json" ]; then
    echo -e "${RED}❌ No existe package.json${NC}"
    exit 1
fi

if grep -q '"start"' package.json; then
    echo -e "${GREEN}✅ Script 'start' encontrado${NC}"
    grep '"start"' package.json
else
    echo -e "${RED}❌ Falta script 'start' en package.json${NC}"
    echo "   Añade: \"start\": \"node index.js\""
    exit 1
fi

echo ""

# Verificar .gitignore
echo "📝 Verificando .gitignore..."
if [ ! -f ".gitignore" ]; then
    echo -e "${YELLOW}⚠️  No existe .gitignore${NC}"
    echo "   Creando .gitignore..."
    cat > .gitignore << 'EOF'
node_modules/
.env
*.log
.DS_Store
EOF
    echo -e "${GREEN}✅ .gitignore creado${NC}"
else
    echo -e "${GREEN}✅ .gitignore existe${NC}"
fi

echo ""

# Verificar .env
echo "🔐 Verificando .env..."
if [ ! -f ".env" ]; then
    echo -e "${RED}❌ No existe .env${NC}"
    exit 1
fi

# Verificar variables importantes
REQUIRED_VARS=("PORT" "DB_CNN" "JWT_SECRET" "GOOGLE_ID" "GOOGLE_SECRET")
MISSING_VARS=()

for var in "${REQUIRED_VARS[@]}"; do
    if grep -q "^$var=" .env; then
        echo -e "${GREEN}✅ $var configurado${NC}"
    else
        echo -e "${RED}❌ Falta $var en .env${NC}"
        MISSING_VARS+=("$var")
    fi
done

if [ ${#MISSING_VARS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Faltan variables en .env${NC}"
    exit 1
fi

echo ""

# Verificar index.js
echo "📄 Verificando index.js..."
if grep -q "app.get('/health'" index.js; then
    echo -e "${GREEN}✅ Endpoint /health encontrado${NC}"
else
    echo -e "${YELLOW}⚠️  No se encuentra endpoint /health${NC}"
    echo "   Se recomienda añadirlo para monitoreo"
fi

echo ""

# Verificar Git
echo "🔧 Verificando Git..."
if [ -d ".git" ]; then
    echo -e "${GREEN}✅ Repositorio Git inicializado${NC}"
    
    # Verificar que .env esté ignorado
    if git check-ignore .env > /dev/null 2>&1; then
        echo -e "${GREEN}✅ .env está en .gitignore${NC}"
    else
        echo -e "${RED}❌ .env NO está ignorado por Git${NC}"
        echo "   PELIGRO: Credenciales podrían subirse a GitHub"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Git no inicializado${NC}"
    echo "   Ejecuta: git init"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESUMEN"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ ${#MISSING_VARS[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ Backend listo para deploy${NC}"
    echo ""
    echo "Siguiente paso:"
    echo "  1. git add ."
    echo "  2. git commit -m 'Initial commit'"
    echo "  3. Crear repo en GitHub"
    echo "  4. git push origin main"
    echo "  5. Conectar con Render"
else
    echo -e "${RED}❌ Backend NO está listo${NC}"
    echo "   Corrige los errores arriba"
fi

echo ""