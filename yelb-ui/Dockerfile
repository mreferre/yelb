FROM public.ecr.aws/bitnami/node:10.23.0
MAINTAINER massimo@it20.info

WORKDIR /app

ADD clarity-seed-newfiles /app/clarity-seed-newfiles 

RUN apt-get update && apt-get install -y git bzip2
RUN chown 1001:1001 /app

USER 1001
RUN git clone https://github.com/vmware/clarity-seed.git
WORKDIR /app/clarity-seed
RUN git checkout -b f3250ee26ceb847f61bb167a90dc957edf6e7f43

RUN cp /app/clarity-seed-newfiles/src/index.html /app/clarity-seed/src/index.html
RUN cp /app/clarity-seed-newfiles/src/styles.css /app/clarity-seed/src/styles.css
RUN cp /app/clarity-seed-newfiles/src/env.js /app/clarity-seed/src/env.js
RUN cp /app/clarity-seed-newfiles/src/app/app* /app/clarity-seed/src/app
RUN cp /app/clarity-seed-newfiles/src/app/env* /app/clarity-seed/src/app
RUN cp /app/clarity-seed-newfiles/src/environments/env* /app/clarity-seed/src/environments
RUN cp /app/clarity-seed-newfiles/package.json /app/clarity-seed/package.json
RUN cp /app/clarity-seed-newfiles/angular-cli.json /app/clarity-seed/.angular-cli.json
RUN rm -r /app/clarity-seed/src/app/home
RUN rm -r /app/clarity-seed/src/app/about

WORKDIR /app/clarity-seed/src

ENV HOME=/opt/bitnami
RUN npm install -g @angular/cli node-sass
RUN npm install

RUN ng build --environment=prod --output-path=./prod/dist/ -aot -vc -cc -dop --buildOptimizer
RUN ng build --environment=test --output-path=./test/dist/
RUN ng build --environment=dev --output-path=./dev/dist/


FROM public.ecr.aws/nginx/nginx:1.19
MAINTAINER massimo@it20.info

WORKDIR /
ADD startup.sh startup.sh

ENV UI_ENV=prod 

RUN chmod +x startup.sh

COPY --from=0 /app/clarity-seed/src/prod/dist /app/clarity-seed/prod/dist
COPY --from=0 /app/clarity-seed/src/test/dist /app/clarity-seed/test/dist
COPY --from=0 /app/clarity-seed/src/dev/dist /app/clarity-seed/dev/dist

CMD ["./startup.sh"]