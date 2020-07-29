import { Construct } from 'constructs';
import { App, Chart } from 'cdk8s';
import { Deployment, Service, IntOrString } from './imports/k8s';

export class YelbCdk8s extends Chart {
  constructor(scope: Construct, name: string) {
    super(scope, name);

    const yelbuilabel = { app: 'yelb-ui-deployment' };
    const yelbappserverlabel = { app: 'yelb-appserver-deployment' };
    const yelbdblabel = { app: 'yelb-db-deployment' };
    const redisserverlabel = { app: 'redis-server-deployment' };

    // -------------------------------------------------------------------- //

    new Service(this, 'yelb-ui', {
      metadata: { name: "yelb-ui"},
      spec: {
        type: 'LoadBalancer',
        ports: [ { port: 80, targetPort: IntOrString.fromNumber(80) } ],
        selector: yelbuilabel,
      }
    });

    new Deployment(this, 'yelb-ui-deployment', {
      spec: {
        replicas: 3,
        selector: {
          matchLabels: yelbuilabel
        },
        template: {
          metadata: { labels: yelbuilabel  },
          spec: {
            containers: [
              {
                name: 'yelb-ui-container',
                image: 'mreferre/yelb-ui:0.7',
                ports: [ { containerPort: 80 } ]
              }
            ]
          }
        }
      }
    });
    // -------------------------------------------------------------------- //

    // -------------------------------------------------------------------- //

    new Service(this, 'yelb-appserver', {
      metadata: { name: "yelb-appserver"},
      spec: {
        type: 'ClusterIP',
        ports: [ { port: 4567, targetPort: IntOrString.fromNumber(4567) } ],
        selector: yelbappserverlabel
      }
    });

    new Deployment(this, 'yelb-appserver-deployment', {
      spec: {
        replicas: 2,
        selector: {
          matchLabels: yelbappserverlabel
        },
        template: {
          metadata: { labels: yelbappserverlabel  },
          spec: {
            containers: [
              {
                name: 'yelb-appserver',
                image: 'mreferre/yelb-appserver:0.5'
              }
            ]
          }
        }
      }
    });

    // -------------------------------------------------------------------- //

    // -------------------------------------------------------------------- //

    new Service(this, 'yelb-db', {
      metadata: { name: "yelb-db"},
      spec: {
        type: 'ClusterIP',
        ports: [ { port: 5432, targetPort: IntOrString.fromNumber(5432) } ],
        selector: yelbdblabel,
      }
    });

    new Deployment(this, 'yelb-db-deployment', {
      spec: {
        replicas: 1,
        selector: {
          matchLabels: yelbdblabel
        },
        template: {
          metadata: { labels: yelbdblabel  },
          spec: {
            containers: [
              {
                name: 'yelb-db',
                image: 'mreferre/yelb-db:0.5'
              }
            ]
          }
        }
      }
    });

    // -------------------------------------------------------------------- //

    // -------------------------------------------------------------------- //

    new Service(this, 'redis-server', {
      metadata: { name: "redis-server"},
      spec: {
        type: 'ClusterIP',
        ports: [ { port: 6379, targetPort: IntOrString.fromNumber(6379) } ],
        selector: redisserverlabel,
      }
    });

    new Deployment(this, 'redis-server-deployment', {
      spec: {
        replicas: 1,
        selector: {
          matchLabels: redisserverlabel
        },
        template: {
          metadata: { labels: redisserverlabel  },
          spec: {
            containers: [
              {
                name: 'redis-server',
                image: 'redis:4.0.2'
              }
            ]
          }
        }
      }
    });

    // -------------------------------------------------------------------- //

  }
}

const app = new App();
new YelbCdk8s(app, 'yelb-cdk8sv2');
app.synth();
