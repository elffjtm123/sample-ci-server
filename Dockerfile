# ---- Builder Stage ----
# 이 스테이지에서는 소스 코드를 빌드하는 데 필요한 모든 의존성을 설치하고 애플리케이션을 빌드합니다.
FROM node:20-alpine AS builder

WORKDIR /usr/src/app

# package.json과 package-lock.json을 먼저 복사하여 의존성 캐싱을 활용합니다.
COPY package*.json ./

# 모든 의존성 설치 (devDependencies 포함)
RUN npm ci

# 나머지 소스 코드 복사
COPY . .

# 애플리케이션 빌드
RUN npm run build

# ---- Production Stage ----
# 이 스테이지에서는 실제 운영에 필요한 의존성만 설치하고, 빌드 결과물만 복사하여 최종 이미지를 만듭니다.
FROM node:20-alpine

WORKDIR /usr/src/app

COPY package*.json ./
# 운영에 필요한 의존성만 설치
RUN npm ci --omit=dev

# Builder 스테이지에서 빌드된 결과물 복사
COPY --from=builder /usr/src/app/dist ./dist

# 애플리케이션이 실행될 포트 노출
EXPOSE 3000

# 애플리케이션 실행
CMD ["node", "dist/main.js"]