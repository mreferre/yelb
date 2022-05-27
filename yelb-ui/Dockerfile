FROM node:12.22

WORKDIR /

ADD clarity-seed clarity-seed 

WORKDIR /clarity-seed

RUN npm install  

RUN npx ng build --environment=prod --output-path=./prod/dist/ -aot -vc -cc -dop --buildOptimizer
RUN npx ng build --environment=test --output-path=./test/dist/
RUN npx ng build --environment=dev --output-path=./dev/dist/


FROM nginx:1.21.6

WORKDIR /

COPY --from=0 /clarity-seed/prod/dist /clarity-seed/prod/dist
COPY --from=0 /clarity-seed/test/dist /clarity-seed/test/dist
COPY --from=0 /clarity-seed/dev/dist /clarity-seed/dev/dist

ADD startup.sh startup.sh

ENV UI_ENV=prod 

RUN chmod +x startup.sh

CMD ["./startup.sh"]

