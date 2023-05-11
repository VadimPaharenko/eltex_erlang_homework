coursework

Добавил mnesia и доработал REST API. Пока не было времени, чтобы привести код в порядок, для abonent_http_handler нужно написать несколько внутренних функций, которые будут обрабатывать входные данные и отправлять ответы на запросы, пока код может повторяться, приведу в порядок чуть позже.

Примеры запросов к API

Правильный POST (если не указать один из параметров в теле, вернется код 400 с указанием ошибки)
curl -X POST 'http://localhost:8080/abonent'\
 --data '{
"num" : 1001,
"name": "Vadim"
}'
-H 'Content-type: application/json'\

Правильный GET abonent (если в урле не указать параметр number, вернется код 400 с указанием ошибки)
curl -X GET 'http://localhost:8080/abonent?number=1001
-H 'Content-type: application/json'\

Правильный DELETE (если в урле не указать параметр number, вернется код 400 с указанием ошибки)
curl -X DELETE 'http://localhost:8080/abonent?number=1001'\
 -H 'Content-type: application/json'\

GET abonents
curl -X GET 'http://localhost:8080/abonents'\
 -H 'Content-type: application/json'\
=====

An OTP application

Build
-----

    $ rebar3 compile
