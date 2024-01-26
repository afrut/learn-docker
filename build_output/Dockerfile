FROM debian:bookworm-slim AS venv
RUN apt update && \
    apt install python3 python3-venv python3-pip -y && \
    python3 -m venv env

# --mount allows files to be mounted when building so that they are not
# persisted in the final image
RUN --mount=type="bind",source="./requirements.in",target="./requirements.in" \
    chmod a+x ./env/bin/activate && \
    ./env/bin/pip install pip-tools && \
    ./env/bin/pip-compile requirements.in

FROM scratch AS final
COPY --from=venv requirements.txt out/requirements.txt