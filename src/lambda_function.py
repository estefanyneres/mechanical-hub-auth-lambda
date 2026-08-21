import datetime
import json
import os
import re

import jwt
import pg8000.native

_connection = None


def lambda_handler(event, context):
    body = json.loads(event.get("body") or "{}")
    cpf = body.get("cpf")
    placa = body.get("placa")

    if not _cpf_valido(cpf):
        return _resposta(400, {"erro": "CPF invalido"})

    conn = _get_connection()
    rows = conn.run(
        """
        SELECT c.id, c.name
        FROM customers c
        JOIN vehicles v ON v.customer_id = c.id
        WHERE c.document_number = :cpf
          AND c.document_type = 'CPF'
          AND v.license_plate = :placa
        """,
        cpf=cpf,
        placa=placa,
    )

    if not rows:
        return _resposta(401, {"erro": "Cliente ou veiculo nao encontrado"})

    customer_id = rows[0][0]

    token = jwt.encode(
        {
            "sub": str(customer_id),
            "type": "customer",
            "iss": "auth-api",
            "exp": datetime.datetime.now(datetime.timezone.utc)
            + datetime.timedelta(minutes=15),
        },
        os.environ["JWT_SECRET"],
        algorithm="HS256",
    )

    return _resposta(200, {"token": token})


def _get_connection():
    global _connection
    if _connection is None:
        _connection = pg8000.native.Connection(
            host=os.environ["DB_HOST"],
            port=int(os.environ.get("DB_PORT", "5432")),
            database=os.environ["DB_NAME"],
            user=os.environ["DB_USER"],
            password=os.environ["DB_PASSWORD"],
        )
    return _connection


def _cpf_valido(cpf):
    if not isinstance(cpf, str):
        return False

    digitos_str = re.sub(r"\D", "", cpf)
    if len(digitos_str) != 11 or digitos_str == digitos_str[0] * 11:
        return False

    digitos = [int(d) for d in digitos_str]

    def calcular_digito(fator_inicial):
        soma = sum(digitos[i] * (fator_inicial - i) for i in range(fator_inicial - 1))
        resto = (soma * 10) % 11
        return 0 if resto == 10 else resto

    return calcular_digito(10) == digitos[9] and calcular_digito(11) == digitos[10]


def _resposta(status_code, corpo):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(corpo),
    }
