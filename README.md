# Xray (VLESS + WebSocket) для Apply.build

Docker-образ с Xray, готовый к деплою на Apply.build (и любой другой PaaS, который
проксирует HTTPS на контейнер и задаёт порт через переменную `$PORT`).

Схема работы: клиент идёт по TLS на `https://<твой-домен>` (сертификат и
терминацию TLS делает сам Apply.build), платформа проксирует уже обычный
WebSocket внутрь контейнера на `$PORT`. Поэтому в конфиге Xray TLS выключен —
включать его не нужно.

## Деплой на Apply.build

1. Залей этот репозиторий на GitHub.
2. В Apply.build создай сервис из этого репозитория (Dockerfile подхватится сам).
3. В настройках сервиса задай переменные окружения:
   - `UUID` — **обязательно**. Твой идентификатор клиента VLESS.
     Сгенерировать: `uuidgen` в терминале, или `cat /proc/sys/kernel/random/uuid`,
     или любым онлайн-генератором UUID v4.
   - `WS_PATH` — опционально, путь WebSocket. По умолчанию `/vless`.
   - `PORT` задаёт сама платформа, трогать не нужно.
4. Задеплой. Дождись, пока сервис станет зелёным (не 502).

## VLESS-ссылка для клиента

Подставь свои значения:

```
vless://UUID@HOST:443?encryption=none&security=tls&sni=HOST&type=ws&host=HOST&path=%2Fvless#Xray-Apply
```

- `UUID` — тот же, что в переменной окружения;
- `HOST` — твой домен, например `test2wpr.apps.apply.build`;
- `path=%2Fvless` — это закодированный `/vless` (если менял `WS_PATH` — закодируй свой путь);
- в клиенте (v2rayNG, Streisand, FoXray, Hiddify и т.п.) можно просто вставить эту
  строку как есть — разберётся сам.

## Проверка

```sh
curl -sS -o /dev/null -w "%{http_code}\n" https://HOST/
```

Пока Xray не поднят — будет `502`. Когда контейнер живой, обычный GET на корень
тоже вернёт ошибку Xray (это нормально — Xray ждёт WebSocket, а не браузер),
но уже не `502 Bad Gateway` от платформы.

## Локальный тест (необязательно)

```sh
UUID=$(cat /proc/sys/kernel/random/uuid) && echo "UUID=$UUID"
docker build -t xray-apply .
docker run --rm -e UUID="$UUID" -e PORT=8080 -p 8080:8080 xray-apply
```
