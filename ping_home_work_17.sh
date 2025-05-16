#!/bin/bash

# Получение адреса от пользователя или использование переменной
TARGET="${1}"

if [ -z "$TARGET" ]; then
    read -rp "Введите IP или доменное имя для пинга: " TARGET
fi

# Счётчик неудачных попыток
fail_count=0

while true; do
    # Выполняем пинг и извлекаем время (в миллисекундах)
    output=$(ping -c 1 -W 1 "$TARGET")
    if [[ $? -eq 0 ]]; then
        # Сброс счётчика ошибок при успешном пинге
        fail_count=0

        # Извлекаем время пинга
        time_ms=$(echo "$output" | grep 'time=' | sed -E 's/.*time=([0-9.]+) ms.*/\1/')
        
        if (( $(echo "$time_ms > 100.0" | bc -l) )); then
            echo "ВНИМАНИЕ: Время пинга $TARGET составило ${time_ms} мс, что превышает 100 мс"
        else
            echo "OK: Время пинга $TARGET составило ${time_ms} мс"
        fi
    else
        # Увеличиваем счётчик ошибок
        ((fail_count++))
        echo "Ошибка пинга $TARGET (неудача №$fail_count)"
        
        if [ "$fail_count" -ge 3 ]; then
            echo "ВНИМАНИЕ: Не удалось выполнить пинг $TARGET три раза подряд"
            fail_count=0  # Сброс счётчика после сообщения
        fi
    fi

    sleep 1
done

