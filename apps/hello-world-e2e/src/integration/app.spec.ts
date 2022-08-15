import { getGreeting } from '../support/app.po';

describe('hello-world', () => {
  beforeEach(() => cy.visit('/'));

  it('should display welcome message', () => {
    getGreeting().contains('HELLO WORLD!');
  });
});
