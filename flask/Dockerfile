#FROM python:3
FROM frolvlad/alpine-python3

MAINTAINER "Mayank Koli"

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip3 install --no-cache-dir -r requirements.txt

COPY . .

CMD [ "flask", "run", "--host=0.0.0.0", "--port=80" ]
