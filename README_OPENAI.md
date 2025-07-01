# OpenAI Integration

Цей проект інтегрований з OpenAI API для надання AI-функціональності.

## Налаштування

### 1. Встановлення залежностей

```bash
bundle install
```

### 2. Конфігурація API ключа

Додайте ваш OpenAI API ключ до Rails credentials:

```bash
EDITOR="code --wait" rails credentials:edit
```

Додайте наступну конфігурацію:

```yaml
openai:
  api_key: your_openai_api_key_here
```

### 3. Перевірка конфігурації

API ключ автоматично валідується при запуску додатку в production/staging середовищах.

## Використання

### Сервіси

#### Openai::Chat

Базовий сервіс для чат-запитів до OpenAI.

```ruby
# Простий запит
service = Openai::Chat.call("Розкажи мені жарт")

if service.success?
  puts service.response_text
else
  puts service.errors
end

# З вказанням моделі
service = Openai::Chat.call("Що таке Ruby?", model: "gpt-4o")

if service.success?
  puts service.response_text
else
  puts service.errors
end
```

#### Параметри

- `prompt` (string, required) - Текст запиту для OpenAI
- `model` (string, optional) - Модель OpenAI (за замовчуванням: `gpt-4o-mini`)

#### Доступні атрибути

- `response_text` - Відповідь від OpenAI
- `prompt` - Оригінальний запит
- `model` - Використана модель
- `errors` - Масив помилок
- `success?` - Булеве значення успішності

### API Endpoints

#### POST /api/v1/openai/chat

Надсилає чат-запит до OpenAI.

**Аутентифікація:** Required

**Параметри:**
```json
{
  "openai": {
    "prompt": "Розкажи мені про Ruby on Rails",
    "model": "gpt-4o-mini"  // опціонально
  }
}
```

**Успішна відповідь (200):**
```json
{
  "success": true,
  "response": "Ruby on Rails - це веб-фреймворк...",
  "model": "gpt-4o-mini"
}
```

**Помилка (503):**
```json
{
  "success": false,
  "errors": ["Failed to communicate with OpenAI: Connection failed"]
}
```

## Доступні моделі

- `gpt-4o` - Найкраща модель для складних завдань
- `gpt-4o-mini` - Оптимізована модель (за замовчуванням)
- `gpt-3.5-turbo` - Швидка та економічна модель

## Обробка помилок

Сервіси автоматично обробляють:

- Помилки мережі (Faraday::Error)
- API помилки OpenAI
- Порожні відповіді
- Неочікувані помилки

Всі помилки логуються та додаються до `errors` масиву.

## Тестування

Запустіть тести для OpenAI функціональності:

```bash
# Всі OpenAI тести
rspec spec/services/openai/

# Конкретний тест
rspec spec/services/openai/chat_spec.rb

# Тести контролера
rspec spec/controllers/api/v1/openai_controller_spec.rb
```

## Приклади використання

### У контролері

```ruby
class MyController < ApplicationController
  def ask_ai
    service = Openai::Chat.call(params[:question])
    
    if service.success?
      render json: { answer: service.response_text }
    else
      render json: { errors: service.errors }, status: :service_unavailable
    end
  end
end
```

### У фонових завданнях

```ruby
class AiProcessingJob < ApplicationJob
  def perform(user_id, question)
    user = User.find(user_id)
    service = Openai::Chat.call(question)
    
    if service.success?
      user.update(ai_response: service.response_text)
    else
      Rails.logger.error("AI processing failed: #{service.errors.join(', ')}")
    end
  end
end
```

## Ліміти та Best Practices

1. **Rate Limiting**: OpenAI має ліміти на кількість запитів
2. **Токен ліміти**: Кожна модель має максимум токенів (встановлено 500)
3. **Timeout**: Налаштований timeout 30 секунд
4. **Caching**: Розгляньте кешування для повторюваних запитів
5. **Асинхронність**: Використовуйте фонові завдання для довгих запитів

## Моніторинг

- Всі помилки логуються через Rails.logger
- В development режимі помилки виводяться детально
- Використовуйте `service.success?` для перевірки статусу 