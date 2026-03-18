<h1>Документація по розгортанню</h1>

<h2>Налаштування середовища (віртуальної машини)</h2>

- OS: [Ubuntu 20.04 Server](https://ubuntu.com/download/server)
- Мінімальні виділені ресурси: 1 vCPU, 2 GB RAM для забезпечення стабільної роботи PostgreSQL, Nginx та .NET SDK
- Налаштування мережі:
    - Тип підключення: NAT
    - Прокид портів
        - TCP, порт хоста: 2222, гостьовий порт: 22 (для SSH)
        - TCP, порт хоста: 8080, гостьовий порт: 80 (для Nginx)
- Спеціальні налаштування: додаткова розбивка диску не потрібна.

Перевірено у середовищі [Oracle VirtualBox](https://www.virtualbox.org/)

<h2>Розгортання</h2>

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

<h2>Перевірка справності</h2>

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