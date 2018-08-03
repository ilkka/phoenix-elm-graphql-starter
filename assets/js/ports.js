/**
 * This module contains utility functions for setting up Elm ports.
 */
import * as AbsintheSocket from '@absinthe/socket';

import { createAbsintheSocket, createPhoenixSocket } from './socket';

const logEvent = (eventName) => (...args) => console.log(eventName, ...args);

/**
 * Attach ports appropriately. `app` is the mounted Elm program.
 */
export function attachPorts(app) {
  const phoenixSocket = createPhoenixSocket();
  const absintheSocket = createAbsintheSocket(phoenixSocket);

  // This port is for querying
  app.ports.query.subscribe((query) => {
    const notifier = AbsintheSocket.send(absintheSocket, { operation: query });
    // we observe what happens and tell the Elm app through
    // some port ports
    AbsintheSocket.observe(absintheSocket, notifier, {
      onAbort: (data) => {
        logEvent('Abort')(data);
        app.ports.socketAbort.send(JSON.stringify(data));
      },
      onError: (data) => {
        logEvent('Error')(data);
        app.ports.socketError.send(JSON.stringify(data));
      },
      onStart: (data) => {
        logEvent('Start')(data);
        app.ports.socketStart.send(JSON.stringify(data));
      },
      onResult: (data) => {
        logEvent('Result')(data);
        app.ports.socketResult.send(JSON.stringify(data));
      },
    });
  });

  // This port is for pushing a graphql doc to the backend
  app.ports.push.subscribe((doc) => {
    const notifier = AbsintheSocket.send(absintheSocket, doc);
    // we observe what happens and tell the Elm app through
    // some port ports
    AbsintheSocket.observe(absintheSocket, notifier, {
      onAbort: (data) => {
        logEvent('Abort')(data);
        app.ports.socketAbort.send(data);
      },
      onError: (data) => {
        logEvent('Error')(data);
        app.ports.socketError.send(data);
      },
      onStart: (data) => {
        logEvent('Start')(data);
        app.ports.socketStart.send(data);
      },
      onResult: (data) => {
        logEvent('Result')(data);
        app.ports.socketResult.send(data);
      },
    });
  });
}
