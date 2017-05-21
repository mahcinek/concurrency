# ZADANIE
Zadanie rekrutacyjne. Obsługuje ono na dwóch wątkach dwa różne api, jedno typu REST, drugie typu Websocket. Api Restowe dostarczone jest przez zewnętrzny serwis i pobierana jest z niego temperatura dla Warszawy, natomiast serwer Websocket jest uruchamiany lokalnie, więc można wprowadzić w nim zmiany, które umożliwią lepsze przetestowanie programu.

## Installation

Wymagania:
```
Python 2.7 + pip
Elixir >=1.4.4
Erlang >=19
git
```
Instalacja Elixira+Erlang: http://elixir-lang.org/install.html
Osobiście na linuxie polecam insalacje przez asdf.

Instrukcja 
1. Pobieramy cały projekt np. przez pobranie zipa lub git clone
2. Pobieramy https://github.com/mahcinek/WebhookServer
3. Instalujemy bibliotekę do serwera Websocket
```
pip install git+https://github.com/dpallot/simple-websocket-server.git
```
4. uruchamiamy jedyny plik pythona znajdujący się w projekcie serwera 
```
python WebhookApi.py
```
5. Wchodzimy do folderu gdzie znajduję się pobrany projekt samego zadania
6. Insalujemy dodatkowe biblioteki, jeżeli podczas tego elixir zapyta czy zainstalować cokolwiek należy się zgodzić:
```
mix deps.get
```
7. Kompilujemy projekt
```
mix compile
```
8. Uruchamiamy tryb interaktywny Elixira
```
iex -S mix
```
9. Uruchamiamy skompilowany wcześniej program
```
ZADANIE.start
```
10. Aby zatrzymać wykonanie używamy ctrl+C


Możliwości dostosowania działania:
1. Serwer Websocket:
    a) linia 11 time.sleep(randint(a,b)) - jak często wysyłane są wiadomości z serwera (w sekundach, jest to przedział od a do b) - domyślnie co 2 lub 3 sekundy
    b) linia 12 value=str(randint(a,b)) - jakie wartości temperatury mają być wysyłane przez serwer (przedział) - domyślnie od 5 do 29
2. Aplikacja /lib/zadanie.ex:
    a) linia 49  :timer.sleep(x) - x to czas co który (w milisekundach) jest wywoływane api REST
    b) linia 38 socket=Socket.Web.connect!("Y", 8000) - Y to domena z Api typu Websocket
