# This is a multi-stage Dockerfile and requires >= Docker 17.05
# https://docs.docker.com/engine/userguide/eng-image/multistage-build/
FROM gobuffalo/buffalo:v0.15.3 as builder
ENV GO111MODULE=on

RUN mkdir -p $GOPATH/src/github.com/RedHatGov/ocdb
WORKDIR $GOPATH/src/github.com/RedHatGov/ocdb
RUN apt-get update && apt-get install -y libxml2-dev zlib1g-dev liblzma-dev libicu-dev

# this will cache the npm install step, unless package.json changes
ADD package.json .
ADD yarn.lock .
RUN yarn install --no-progress
ADD . .
RUN go get ./...
RUN buffalo build --ldflags '-linkmode external -extldflags "-static -lz -llzma -licuuc -licudata -ldl -lstdc++ -lm"' -o /bin/app

FROM alpine
RUN apk add --no-cache bash git
RUN apk add --no-cache ca-certificates

WORKDIR /bin/

COPY --from=builder /bin/app .

# Uncomment to run the binary in "production" mode:
# ENV GO_ENV=production

# Bind the app to 0.0.0.0 so it can be seen from outside the container
ENV ADDR=0.0.0.0

EXPOSE 3000

# Uncomment to run the migrations before running the binary:
# CMD /bin/app migrate; /bin/app
CMD exec /bin/app
