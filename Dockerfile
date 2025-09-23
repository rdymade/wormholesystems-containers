FROM ubuntu:latest
LABEL authors="timkunze"

ENTRYPOINT ["top", "-b"]
