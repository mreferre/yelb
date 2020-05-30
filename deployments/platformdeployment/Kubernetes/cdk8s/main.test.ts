import {YelbCdk8s} from './main';
import {Testing} from "cdk8s";

describe('Placeholder', () => {
    test('Empty', () => {
        const app = Testing.app();
        const chart = new YelbCdk8s(app, 'test-chart');
        const results = Testing.synth(chart)
        expect(results).toMatchSnapshot();
    });
});
