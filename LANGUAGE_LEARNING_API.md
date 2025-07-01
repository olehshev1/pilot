# 🎓 Language Learning API Documentation

Цей API дозволяє створювати додаток для вивчення мов з AI-підтримкою. Система використовує OpenAI для генерації перекладів та прикладів використання слів.

## 🌟 **Основні можливості**

- ✅ Переклад слів з української на англійську/польську
- ✅ Генерація прикладів використання AI
- ✅ Створення навчальних завдань (tasks) із перекладами
- ✅ Відстеження прогресу вивчення слів
- ✅ Контекстуальні переклади з урахуванням теми

## 🏗️ **Архітектурна модель**

- **Projects** → **Language Learning Sessions** (навчальні сесії)
- **Tasks** → **Word Translations** (переклади слів з прикладами)

## 🔧 **Налаштування**

### 1. **Створення Learning Session (Project)**

```bash
curl -X POST http://localhost:3000/api/v1/projects \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -d '{
    "project": {
      "name": "English Study",
      "description": "Learning English vocabulary for IT professionals and daily communication",
      "source_language": "ukrainian",
      "target_languages": ["english", "polish"],
      "learning_context": "IT and business communication"
    }
  }'
```

### 2. **Тестування перекладу слова**

```bash
curl -X POST http://localhost:3000/api/v1/language_learning/translate_word \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -d '{
    "language_learning": {
      "word": "комп'\''ютер",
      "source_language": "ukrainian",
      "target_languages": ["english", "polish"],
      "context": "Information Technology"
    }
  }'
```

### 3. **Створення навчального завдання**

```bash
curl -X POST http://localhost:3000/api/v1/language_learning/create_word_task \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -d '{
    "language_learning": {
      "word": "програмування",
      "project_id": 1
    }
  }'
```

### 4. **Перегляд деталей перекладу**

```bash
curl -X GET http://localhost:3000/api/v1/language_learning/word_details/1 \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN"
```

### 5. **Просування в навчанні**

```bash
curl -X PATCH http://localhost:3000/api/v1/language_learning/advance_learning/1 \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN"
```

## 📝 **Приклади відповідей API**

### **Успішний переклад**
```json
{
  "success": true,
  "data": {
    "word": "комп'ютер",
    "source_language": "ukrainian",
    "target_languages": ["english", "polish"],
    "context": "Information Technology",
    "translations": {
      "english": ["computer", "PC"],
      "polish": ["komputer"]
    },
    "examples": {
      "english": {
        "examples": [
          {
            "translation": "computer",
            "sentences": [
              {
                "sentence": "I work on my computer every day.",
                "translation_back": "Я працюю на своєму комп'ютері щодня.",
                "context": "daily",
                "difficulty": "beginner"
              }
            ]
          }
        ],
        "learning_tips": ["Computer is the most common term"]
      }
    },
    "word_info": {
      "part_of_speech": "noun",
      "difficulty": "beginner"
    },
    "processing_stats": {
      "translations_count": 3,
      "examples_count": 4,
      "languages_processed": 2
    }
  }
}
```

### **Створене навчальне завдання**
```json
{
  "success": true,
  "data": {
    "task": {
      "id": 1,
      "name": "програмування → programming | programowanie",
      "description": "English: programming, coding\nPolish: programowanie\n\nPart of speech: noun | Difficulty: intermediate",
      "status": "not_started",
      "original_word": "програмування",
      "learning_status": "new",
      "learning_progress": 0,
      "translations": {
        "english": ["programming", "coding"],
        "polish": ["programowanie"]
      },
      "examples": {
        "english": {...},
        "polish": {...}
      }
    }
  }
}
```

### **Деталі слова**
```json
{
  "success": true,
  "data": {
    "task": {...},
    "original_word": "програмування",
    "translations": {
      "english": ["programming", "coding"],
      "polish": ["programowanie"]
    },
    "examples": {...},
    "learning_progress": 25,
    "can_advance": true,
    "project_context": {
      "name": "English Study",
      "language_pair": "ukrainian → english, polish",
      "learning_context": "IT and business communication"
    }
  }
}
```

## 🎯 **Learning Status Progression**

1. **new** (0%) → Нове слово
2. **learning** (25%) → Вивчається  
3. **practiced** (75%) → Практикується
4. **mastered** (100%) → Засвоєне

## 🔍 **Підтримувані мови**

- `ukrainian` (джерельна мова)
- `english` (цільова мова)
- `polish` (цільова мова)

## ⚡ **Використання в додатку**

### **Потік вивчення нового слова:**

1. **Створити learning session** (project)
2. **Додати слово** через `create_word_task`
3. **Переглянути переклади та приклади** через `word_details`
4. **Практикувати** та просувати статус через `advance_learning`

### **Тестування окремих слів:**

1. **Швидкий переклад** через `translate_word`
2. **Аналіз результатів** перед створенням завдання

## 🛡️ **Обробка помилок**

### **Неуспішний переклад**
```json
{
  "success": false,
  "errors": [
    "Unsupported language: french. Supported: ukrainian, english, polish"
  ],
  "word": "test"
}
```

### **Відсутність OpenAI ключа**
```json
{
  "success": false,
  "errors": [
    "Failed to communicate with OpenAI: API key not configured"
  ]
}
```

## 📊 **Моніторинг та аналітика**

- Відстеження прогресу через `learning_progress`
- Статистика обробки через `processing_stats`
- Контекстуальна інформація проекту

## 🔧 **Налаштування для розробки**

```bash
# 1. Додати OpenAI API ключ
EDITOR="code --wait" rails credentials:edit

# В credentials.yml:
openai:
  api_key: your_openai_api_key_here

# 2. Запустити сервер
docker compose up

# 3. Створити користувача та отримати токен
# (див. основні приклади аутентифікації)
```

## 🎓 **Приклади реальних сценаріїв**

### **Сценарій 1: Вивчення IT термінології**
```bash
# Створити IT learning session
curl -X POST .../projects -d '{
  "project": {
    "name": "IT Terms",
    "description": "Learning programming and computer science vocabulary",
    "learning_context": "Software development and computer science"
  }
}'

# Додати IT терміни
curl -X POST .../create_word_task -d '{"language_learning": {"word": "алгоритм", "project_id": 1}}'
curl -X POST .../create_word_task -d '{"language_learning": {"word": "база даних", "project_id": 1}}'
```

### **Сценарій 2: Повсякденна лексика**
```bash
# Створити побутовий словник
curl -X POST .../projects -d '{
  "project": {
    "name": "Daily Words",
    "description": "Common words for everyday conversations and travel",
    "learning_context": "Daily life and travel conversations"
  }
}'

# Додати повсякденні слова
curl -X POST .../create_word_task -d '{"language_learning": {"word": "їжа", "project_id": 2}}'
curl -X POST .../create_word_task -d '{"language_learning": {"word": "подорож", "project_id": 2}}'
```

---

🚀 **Language Learning API готовий для створення потужного додатку для вивчення мов!** 