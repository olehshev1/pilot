# OpenAI API Curl Examples

## Аутентифікація
Спочатку потрібно отримати токен авторизації:

```bash
# Створити користувача
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123",
      "password_confirmation": "password123"
    }
  }'

# Увійти в систему
curl -X POST http://localhost:3000/api/v1/sign_in \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "email": "test@example.com",
      "password": "password123"
    }
  }'
```

## OpenAI Chat запити

### Базовий запит з токеном
```bash
curl -X POST http://localhost:3000/api/v1/openai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -d '{
    "openai": {
      "prompt": "Розкажи мені цікавий факт про програмування",
      "model": "gpt-4o-mini"
    }
  }'
```

### Запит з простим токеном аутентифікації
```bash
curl -X POST http://localhost:3000/api/v1/openai/chat \
  -H "Content-Type: application/json" \
  -H "X-User-Email: test@example.com" \
  -H "X-User-Token: USER_AUTHENTICATION_TOKEN" \
  -d '{
    "openai": {
      "prompt": "Напиши мені короткий жарт",
      "model": "gpt-4o-mini"
    }
  }'
```

### Запит з моделлю по замовчуванню
```bash
curl -X POST http://localhost:3000/api/v1/openai/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -d '{
    "openai": {
      "prompt": "Що таке Ruby on Rails?"
    }
  }'
```

## Очікувані відповіді

### Успішна відповідь
```json
{
  "success": true,
  "response": "Ruby on Rails - це веб-фреймворк...",
  "model": "gpt-4o-mini"
}
```

### Помилка авторизації
```json
{
  "error": "You need to sign in or sign up before continuing."
}
```

### Помилка OpenAI
```json
{
  "success": false,
  "errors": ["Failed to communicate with OpenAI: ...."]
}
```

## Примітки
- Замініть `YOUR_AUTH_TOKEN` на реальний токен з відповіді `/sign_in`
- Переконайтесь що OpenAI API ключ налаштований в `config/credentials.yml.enc`
- Сервер має бути запущений на `localhost:3000` 