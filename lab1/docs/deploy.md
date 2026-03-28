<h1>Документація по розгортанню</h1>

<h2>Розгортання за допомогою bash (setup.sh) - лабораторна робота №1</h2>

<h3>Налаштування середовища (віртуальної машини)</h3>

- OS: [Ubuntu 24.04 Server](https://ubuntu.com/download/server)
- Мінімальні виділені ресурси: 1 vCPU, 2 GB RAM для забезпечення стабільної роботи PostgreSQL, Nginx та .NET SDK
- Налаштування мережі:
    - Тип підключення: NAT
    - Прокид портів
        - TCP, порт хоста: 2222, гостьовий порт: 22 (для SSH)
        - TCP, порт хоста: 8080, гостьовий порт: 80 (для Nginx)
- Спеціальні налаштування: додаткова розбивка диску не потрібна.

Перевірено у середовищі [Oracle VirtualBox](https://www.virtualbox.org/)

<h3>Розгортання</h3>

<i>При бажанні налаштування через SSH, для початку встановіть відповідний пакет за допомогою команди:</i>
```bash
sudo apt-get install openssh-server
```

<br>
Увійдіть на віртуальну машину (можливо через SSH) під користувачем root (або будь-яким із sudo правами)

```bash
git clone https://github.com/BalalaievMaxim/summer-2026-devops
cd summer-2026-devops/lab1/scripts
sudo bash ./setup.sh
```

<h3>Перевірка справності</h3>

Перейдіть за адресою [http://localhost](http://localhost) з будь-якої системи - ви повинні отримати сторінку з переліком усіх доступних ендпоінтів

На віртуальній машині (або через SSH) виконати:
```bash
sudo systemctl status mywebapp.service
```
Це перевіряє статус сервісу mywebapp.service

<br>

```bash
curl -i http://localhost:8000/health/ready
```
Оскільки напряму до /health/ready nginx блокує доступ, необхідно звертатись напряму до порта 8000

<h2> Розгортання за допомогою Docker - лабораторна робота №2</h2>
Перед виконанням переконайтеся, що у вас встановлені Docker та Docker Compose.

```bash
git clone https://github.com/BalalaievMaxim/summer-2026-devops
cd summer-2026-devops/lab1/
docker compose up -d
```

Після успішного запуску веб-застосунок буде доступний за адресою http://localhost
Також можна перевірити статус контейнерів командою:
```bash
docker compose ps
```